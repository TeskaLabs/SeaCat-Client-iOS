//
//  SeaCat.h
//  TeskaLabs SeaCat Client for iOS
//
//  Created by Ales Teska on 04/12/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

@protocol SeaCatPingDelegate <NSObject>

-(void)pong:(int32_t)pingId;

@optional
-(void)pingCanceled:(int32_t)pingId;

@end

@protocol SeaCatCSRDelegate <NSObject>
-(bool)submit:(NSError **)out_error;
@end

typedef NS_OPTIONS(NSUInteger, SCLogFlag) {
    SC_LOG_FLAG_DEBUG_GENERIC = (1 << 0), // => 0b00000001
};

@interface SeaCatClient : NSObject

+ (BOOL)isConfigured;
+ (void)configure;
+ (void)configureWithCSRDelegate:(id<SeaCatCSRDelegate>)CSRDelegate;

+ (void)ping:(id<SeaCatPingDelegate>)pong;

+ (BOOL)isReady;
+ (NSString *)getState;

+ (void)setLogMask:(SCLogFlag)mask;

+ (void)connect;
+ (void)disconnect;
+ (void)reset;
+ (void)renew;

+ (void)setApplicationId:(NSString*)appId;

+ (void)configureSocket:(unsigned int)port domain:(int)domain sock_type:(int)sock_type protocol:(int)protocol peerAddress:(NSString *)peerAddress  peerPort:(NSString *)peerPort;

// NSNotificationCenter part
+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName;
+ (id <NSObject>)addObserverForName:(NSString *)name queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block NS_AVAILABLE(10_6, 4_0);

+ (void)removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(NSString *)aName;

+ (NSString *)getClientTag;
+ (NSString *)getClientId;


@end


enum SeaCat_ErrorCodes
{
    SeaCat_ErrorCore_GENERIC = 99999,
};


// Notification
extern NSString *const SeaCat_Notification_StateChanged;
extern NSString *const SeaCat_Notification_GWConnReset;
extern NSString *const SeaCat_Notification_GWConnConnected;
extern NSString *const SeaCat_Notification_ClientIdChanged;


extern NSString * SeaCatErrorDomain;
extern NSString * SeaCatHostSuffix;
