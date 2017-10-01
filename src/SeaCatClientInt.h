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

+ (void)disconnect;
+ (void)reset;
+ (void)renew;

+ (void)setApplicationId:(NSString*)appId;

// NSNotificationCenter part
+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName;
+ (id <NSObject>)addObserverForName:(NSString *)name queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block NS_AVAILABLE(10_6, 4_0);

+ (void)removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(NSString *)aName;

@end


enum SeaCat_ErrorCodes
{
    SeaCat_ErrorCore_GENERIC = 99999,
};


// Notification
extern NSString *const SeaCat_Notification_StateChanged;


extern NSString * SeaCatErrorDomain;
extern NSString * SeaCatHostSuffix;
