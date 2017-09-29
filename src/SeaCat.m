//
//  SeaCat.m
//  SeaCatClient
//
//  Created by Ales Teska on 29/11/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import "SeaCatInternals.h"
#import "SCPingFactory.h"

static void _SCLogFnct(char level, const char * message)
{
    _SCLog(level, [NSString stringWithUTF8String:message]);
}

static NSString * SeaCatApplicationId = nil;

@implementation SeaCat

// This method is called automatically after the Sea is loaded into a memory
+ (void)load
{
    // Configure logging
    seacatcc_log_setfnct(_SCLogFnct);
}


+ (BOOL)_reactorReady
{
    if (SeaCatReactor == NULL)
    {
        SCLOG_ERROR(@"SeaCat reactor is not initialized.");
        return FALSE;
    }
    return TRUE;
}


+ (void)configure
{
    if (SeaCatReactor == NULL)
    {
        if (SeaCatApplicationId == nil)
        {
            NSBundle *bundle = [NSBundle mainBundle];
            NSDictionary *info = [bundle infoDictionary];
            SeaCatApplicationId = [info objectForKey:(NSString*)kCFBundleIdentifierKey];
        }

        // Create reactor
        SeaCatReactor = [[SCReactor alloc] init:SeaCatApplicationId];
    }

    [SeaCatReactor start];

    [SeaCatPlugin commitCharacteristics];
    
    // Register HTTP protocol class
    [NSURLProtocol registerClass:[SCURLProtocol class]];
}


+ (void)ping:(id<SeaCatPingDelegate>)delegate
{
    if (![self _reactorReady]) return;

	[SeaCatReactor.pingFactory ping:delegate reactor:SeaCatReactor];
}

+ (BOOL)isReady
{
    if (![self _reactorReady]) return FALSE;

    char state_buf[SEACATCC_STATE_BUF_SIZE];
    seacatcc_state(state_buf);
    
    if ((state_buf[3] == 'Y') && (state_buf[4] == 'N') && (state_buf[0] != 'f')) return TRUE;
    return FALSE;
}

+ (NSString *)getState
{
    if (![self _reactorReady]) return @"??????";
    char state_buf[SEACATCC_STATE_BUF_SIZE];
    seacatcc_state(state_buf);
    return [NSString stringWithUTF8String:state_buf];
}


+ (void)disconnect
{
    if (![self _reactorReady]) return;

    int rc = seacatcc_yield('d');
    NSError * error = SCCheckRC(rc, @"seacatcc_yield/disconnect");
    if (error != NULL) SCLOG_ERROR(@"%@", error);
}


+ (void)reset
{
    if (![self _reactorReady]) return;

    int rc = seacatcc_yield('r');
    NSError * error = SCCheckRC(rc, @"seacatcc_yield/reset");
    if (error != NULL) SCLOG_ERROR(@"%@", error);
}


+ (void)renew
{
    if (![self _reactorReady]) return;

    int rc = seacatcc_yield('n');
    NSError * error = SCCheckRC(rc, @"seacatcc_yield/renew");
    if (error != NULL) SCLOG_ERROR(@"%@", error);
}

+ (void)setApplicationId:(NSString*)appId
{
    SeaCatApplicationId = appId;
}

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName
{
    if (![self _reactorReady]) return;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:observer selector:aSelector name:aName object:SeaCatReactor];
}

+ (id <NSObject>)addObserverForName:(NSString *)name queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block NS_AVAILABLE(10_6, 4_0)
{
    if (![self _reactorReady]) return nil;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    return [center addObserverForName:name object:SeaCatReactor queue:queue usingBlock:block];
}

+ (void)removeObserver:(id)observer
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:observer];
}

+ (void)removeObserver:(id)observer name:(NSString *)aName
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:observer name:aName object:SeaCatReactor];
}


@end
