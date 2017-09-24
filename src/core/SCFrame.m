//
//  SCFrame.m
//  SeaCatClient
//
//  Created by Ales Teska on 30/11/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import "SCFrame.h"
#include "spdy.h"

///

@interface SCFrame ()

// Redeclare publicly read-only properties
@property (readwrite) uint8_t * bytes;
@property (readwrite) uint16_t capacity;
@property (readwrite) uint16_t position;
@property (readwrite) uint16_t length;

@end

///

@implementation SCFrame
{
    NSMutableData * data;
}

@synthesize bytes;
@synthesize capacity;
@synthesize position;
@synthesize length;

-(SCFrame *)initWithCapacity:(const uint16_t)in_capacity
{
    self = [super init];
    if (!self) return self;

    data = [NSMutableData dataWithCapacity:in_capacity];
    bytes = (uint8_t *)[data bytes];
	capacity = in_capacity;

	[self clear];

    return self;
}


-(void)clear
{
	position = 0;
	length = capacity;
}

-(void)flip
{
	length = position;
	position = 0;
}

-(void)flip:(const uint16_t)in_length
{
	length = in_length;
	position = 0;
}


-(void)store8:(const uint8_t)value
{
	assert((position+sizeof(value)) <= length);
	
	bytes[position++] = value;
}


-(void)store16:(const uint16_t)value
{
	assert((position+sizeof(value)) <= length);

	bytes[position++] = 0xFF & (value >> 8);
	bytes[position++] = 0xFF & value;
}

-(void)store24:(const uint32_t)value
{
	assert((position+sizeof(value)-1) <= length);
	
	bytes[position++] = 0xFF & (value >> 16);
	bytes[position++] = 0xFF & (value >> 8);
	bytes[position++] = 0xFF & value;
}

-(void)store32:(const uint32_t)value
{
	assert((position+sizeof(value)) <= length);
	
	bytes[position++] = 0xFF & (value >> 24);
	bytes[position++] = 0xFF & (value >> 16);
	bytes[position++] = 0xFF & (value >> 8);
	bytes[position++] = 0xFF & value;

}


-(uint32_t)get32
{
	uint32_t ret = 0;
	assert((position+sizeof(uint32_t)) <= length);
	
	ret |= bytes[position++];
	ret <<= 8;
	ret |= bytes[position++];
	ret <<= 8;
	ret |= bytes[position++];
	ret <<= 8;
	ret |= bytes[position++];

	return ret;
}


-(uint8_t)get8at:(const uint8_t)in_position
{
	assert(in_position <= length);
	return bytes[in_position];
}


- (void)buildSPD3Ping:(const int32_t)pingId
{
	// It is SPDY v3 control frame
	[self store16:(0x8000 | SEACATCC_SPDY_CNTL_FRAME_VERSION_SPD3)];
	
	// Type
	[self store16:SEACATCC_SPDY_CNTL_TYPE_PING];
	
	// Flags
	[self store8:0];
	
	// Length
	[self store24:4];
	
	// Ping ID
	[self store32:pingId];
}

@end
