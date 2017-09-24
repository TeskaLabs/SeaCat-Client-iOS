//
//  SCFrame.h
//  SeaCatClient
//
//  Created by Ales Teska on 30/11/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCFrame : NSObject

@property (readonly) uint8_t * bytes;
@property (readonly) uint16_t capacity;
@property (readonly) uint16_t position;
@property (readonly) uint16_t length;

-(SCFrame *)initWithCapacity:(const uint16_t)capacity;

-(void)flip;
-(void)flip:(const uint16_t)length;
-(void)clear;

-(void)store8:(const uint8_t)value;
-(void)store16:(const uint16_t)value;
-(void)store24:(const uint32_t)value;
-(void)store32:(const uint32_t)value;

-(uint8_t)get8at:(const uint8_t)position;

-(uint32_t)get32;

-(void)buildSPD3Ping:(const int32_t)pingId;

@end
