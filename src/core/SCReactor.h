//
//  Reactor.h
//  SeaCatClient
//
//  Created by Ales Teska on 30/11/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCPingFactory;
@class SCFramePool;

#import "SCFrameProviderProtocol.h"

@interface SCReactor : NSObject

@property (readonly) SCPingFactory * pingFactory;
@property (readonly) SCFramePool * framePool;

-(void)start;

-(void)registerFrameProvider:(id<SCFrameProviderProtocol>)provider single:(bool)single;

-(void)postNotificationName:(NSString *)notificationName;

@end

extern SCReactor * SeaCatReactor;
