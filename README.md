# SeaCat-Client-iOS
SeaCat Client for iOS

# Create a multiarchitecture framework
lipo -create -output "SeaCatClient" "Debug-iphonesimulator/SeaCatClient.framework/SeaCatClient" "Debug-iphoneos/SeaCatClient.framework/SeaCatClient"
