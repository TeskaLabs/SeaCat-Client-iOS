//
//  AppDelegate.m
//  iOSDemoApp
//
//  Created by Ales Teska on 26/02/16.
//
//

#import "AppDelegate.h"
#import "SeaCatClient/SeaCatClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SeaCatClient setLogMask:SC_LOG_FLAG_DEBUG_GENERIC];
    [SeaCatClient setAuthLocalisedReason:@"SeaCat needs your auth!"];
    [SeaCatClient configure];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [SeaCatClient deauth];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
