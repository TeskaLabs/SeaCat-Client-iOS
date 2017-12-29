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
# Script is using following folders (if not changed):
#
#    ./lib/Debug       - result of debug configuration
#    ./lib/Release     - result of release configuration
#    ./tmp             - for all temporary data
#
# ----------------------------------------------------------------------------

ROOTDIR=$(dirname $0)
TMP_DIR="${ROOTDIR}/build"
XCODE_PROJECT="${ROOTDIR}/SeaCatClient.xcodeproj"

ARCHS=(i386 x86_64 armv7 armv7s arm64)
LIBS=(SeaCatClient)
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
#   $2   - architecture (i386, arm7, etc...)
#   $3   - command to execute. You can use 'build' or 'clean'

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
	COMMAND_LINE="$COMMAND_LINE BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_DIR}" CODE_SIGNING_REQUIRED=NO ${COMMAND}"
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
# Create FAT libraries
# Parameters:
#   $1   - scheme name
#   $2   - build configuration (e.g. Debug or Release)
# -----------------------------------------------------------------------------
function FAT
{
	SCHEME=$1
	CONF=$2

	for LIB in ${LIBS[@]}
	do
		echo "FATalizing library ${SCHEME} / ${CONF} / ${LIB}"

		FATLIB_DIR="${LIB_DIR}/ios-${CONF}/${LIB}.framework"
		
		PLATFORM_GLOBS=`printf "${TMP_DIR}/${SCHEME}/iphone*-%s/${CONF}-iphone*/${LIB}.framework " ${ARCHS[@]}`
		PLATFORM_LIBS=(`find ${PLATFORM_GLOBS} -name ${LIB}`)

		rm -rf ${FATLIB_DIR}
		cp -r $(dirname ${PLATFORM_LIBS[0]}) "${FATLIB_DIR}/"
		rm "${FATLIB_DIR}/${LIB}"

		${LIPO} -create ${PLATFORM_LIBS[@]} -output "${FATLIB_DIR}/${LIB}"

	done
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

	for ARCH in "${ALL_ARCHITECTURES[@]}"
	do
		BUILD_COMMAND $SCHEME Debug $ARCH clean
	done
}

rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

BUILD_SCHEME SeaCatiOSClient Debug
BUILD_SCHEME SeaCatiOSClient Release

FAT SeaCatiOSClient Debug
FAT SeaCatiOSClient Release

