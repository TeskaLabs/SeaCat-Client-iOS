#!/bin/sh -e +v

###############################################################################
# Build script for Apple iOS platforms
#
# The purpose of this script is to build "fat" libraries for binarty distribution.
# Typically, this script is used for CocoaPods integration.
# 
# The result of the build process is one multi-architecture static library (also 
# called as "fat") with all supported microprocessor architectures in one file.
# 
#
# Use: CODE_SIGN_IDENTITY="TeskaLabs Ltd" ./build-ios.sh
#
# ----------------------------------------------------------------------------

ROOTDIR=$(dirname $0)
TMP_DIR="${ROOTDIR}/build"
XCODE_PROJECT="${ROOTDIR}/SeaCatClient.xcodeproj"

ARCHS=(i386 x86_64 armv7 armv7s arm64)
IOS_MIN_SDK_VERSION="6.0"
LIB_DIR="${ROOTDIR}/bin"

# Find various build tools
XCBUILD=`xcrun -sdk iphoneos -find xcodebuild`
LIPO=`xcrun -sdk iphoneos -find lipo`
if [ x$XCBUILD == x ]; then
	FAILURE "xcodebuild command not found."
fi
if [ x$LIPO == x ]; then
	FAILURE "lipo command not found."
fi


#####

# -----------------------------------------------------------------------------
# Performs xcodebuild command for a single platform (iphone / simulator)
# Parameters:
#   $1   - scheme name
#   $2   - configuration (Debug / Release)
#   $3   - architecture (i386, arm7, etc...)
#   $4   - command to execute. You can use 'build' or 'clean'

function BUILD_COMMAND
{
	SCHEME=$1
	CONF=$2
	ARCH=$3
	COMMAND=$4

	if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ]; then
		PLATFORM="iphonesimulator"
	else
		PLATFORM="iphoneos"
	fi

	echo "Executing ${COMMAND} / ${PLATFORM} / ${ARCH}"


	BUILD_DIR="${TMP_DIR}/${SCHEME}/${PLATFORM}-${ARCH}"
	ARCH_SETUP="VALID_ARCHS=${ARCH} ARCHS=${ARCH} CURRENT_ARCH=${ARCH} ONLY_ACTIVE_ARCH=NO"
	COMMAND_LINE="${XCBUILD} -project ${XCODE_PROJECT}"

	COMMAND_LINE="$COMMAND_LINE -scheme ${SCHEME} -sdk ${PLATFORM} ${ARCH_SETUP}"
	COMMAND_LINE="$COMMAND_LINE -configuration ${CONF}"
	COMMAND_LINE="$COMMAND_LINE -derivedDataPath ${TMP_DIR}/DerivedData"
	COMMAND_LINE="$COMMAND_LINE BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_DIR}" CODE_SIGNING_REQUIRED=NO ENABLE_BITCODE=YES OTHER_CFLAGS="-fembed-bitcode" ${COMMAND}"
	echo ${COMMAND_LINE}
	${COMMAND_LINE}

	if [ "${COMMAND}" == "clean" ] && [ -e "${BUILD_DIR}" ]; then
		$RM -r "${BUILD_DIR}"
	fi
}

# -----------------------------------------------------------------------------
# Build scheme for both plaforms
# Parameters:
#   $1   - scheme name
#   $2   - build configuration (e.g. Debug or Release)
# -----------------------------------------------------------------------------
function BUILD_SCHEME 
{
	SCHEME=$1
	CONF=$2

	echo "Building architectures..."
	for ARCH in ${ARCHS[@]}
	do
		BUILD_COMMAND $SCHEME $CONF $ARCH build
	done
}


# -----------------------------------------------------------------------------
# Create FAT framework
# Parameters:
#   $1   - scheme name
#   $2   - build configuration (e.g. Debug or Release)
#   $3   - Framework/library name
# -----------------------------------------------------------------------------
function FAT
{
	SCHEME=$1
	CONF=$2
	LIB=$3

	echo "FATalizing framework ${SCHEME} / ${CONF} / ${LIB}"

	FATLIB_DIR="${LIB_DIR}/ios-${CONF}/${LIB}.framework"
	PLATFORM_LIB1="./build/${SCHEME}/iphoneos-arm64/${CONF}-iphoneos/${LIB}.framework/${LIB}"

	PLATFORM_LIBS=${PLATFORM_LIB1}
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphoneos-armv7s/${CONF}-iphoneos/${LIB}.framework/${LIB}"
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphoneos-armv7/${CONF}-iphoneos/${LIB}.framework/${LIB}"
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphonesimulator-x86_64/${CONF}-iphonesimulator/${LIB}.framework/${LIB}"
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphonesimulator-i386/${CONF}-iphonesimulator/${LIB}.framework/${LIB}"

	rm -rf ${FATLIB_DIR}
	mkdir -p ${FATLIB_DIR}
	cp -r $(dirname ${PLATFORM_LIB1})/* "${FATLIB_DIR}/"
	rm "${FATLIB_DIR}/${LIB}"

	${LIPO} -create ${PLATFORM_LIBS} -output "${FATLIB_DIR}/${LIB}"

	echo "Output is in ${FATLIB_DIR}/${LIB}"
}


# -----------------------------------------------------------------------------
# Create FAT static libraries
# Parameters:
#   $1   - scheme name
#   $2   - build configuration (e.g. Debug or Release)
# -----------------------------------------------------------------------------
function FATstatic
{
	SCHEME=$1
	CONF=$2
	LIB=$3

	echo "FATalizing library ${SCHEME} / ${CONF} / ${LIB}"

	FATLIB_DIR="${LIB_DIR}/ios-${CONF}/${SCHEME}"
	
	PLATFORM_GLOBS=`printf "${TMP_DIR}/${SCHEME}/iphone*-%s/${CONF}-iphone*/${LIB} " ${ARCHS[@]}`
	PLATFORM_LIB1="./build/${SCHEME}/iphoneos-arm64/${CONF}-iphoneos/${LIB}"

	PLATFORM_LIBS=${PLATFORM_LIB1}
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphoneos-armv7s/${CONF}-iphoneos/${LIB}"
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphoneos-armv7/${CONF}-iphoneos/${LIB}"
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphonesimulator-x86_64/${CONF}-iphonesimulator/${LIB}"
	PLATFORM_LIBS+=" ./build/${SCHEME}/iphonesimulator-i386/${CONF}-iphonesimulator/${LIB}"

	rm -rf ${FATLIB_DIR}
	mkdir -p ${FATLIB_DIR}
	cp -r $(dirname ${PLATFORM_LIB1})/* "${FATLIB_DIR}/"
	rm "${FATLIB_DIR}/${LIB}"

	${LIPO} -create ${PLATFORM_LIBS} -output "${FATLIB_DIR}/${LIB}"

	echo "Output is in ${FATLIB_DIR}/${LIB}"
}



# -----------------------------------------------------------------------------
# Clear project for specific scheme
# Parameters:
#   $1  -   scheme name
# -----------------------------------------------------------------------------
function CLEAN_SCHEME
{
	SCHEME=$1
	echo "Cleaning architectures..."

	for ARCH in ${ARCHS[@]}
	do
		BUILD_COMMAND $SCHEME Debug $ARCH clean
	done
}

rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

BUILD_SCHEME SeaCatiOSClient Debug
BUILD_SCHEME SeaCatiOSClient Release

FAT SeaCatiOSClient Debug SeaCatClient
FAT SeaCatiOSClient Release SeaCatClient

rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

BUILD_SCHEME SeaCatiOSClient-Static Debug
FATstatic SeaCatiOSClient-Static Debug libseacatclientios.a

BUILD_SCHEME SeaCatiOSClient-Static Release
FATstatic SeaCatiOSClient-Static Release libseacatclientios.a

echo "Signing ..."
codesign -f -s "${CODE_SIGN_IDENTITY}" -vvv ./bin/ios-Release/SeaCatClient.framework
codesign -f -s "${CODE_SIGN_IDENTITY}" -vvv ./bin/ios-Debug/SeaCatClient.framework

