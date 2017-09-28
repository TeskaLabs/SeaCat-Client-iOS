# SeaCat-Client-iOS
SeaCat Client for iOS

# Create a multiarchitecture framework
lipo -create -output "SeaCatiOSClient" "Debug-iphonesimulator/SeaCatiOSClient.framework/SeaCatiOSClient" "Debug-iphoneos/SeaCatiOSClient.framework/SeaCatiOSClient"
