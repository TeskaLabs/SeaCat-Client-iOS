//
//  SCFramePool.m
//  SeaCatClient
//
//  Created by Ales Teska on 30/11/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import "SeaCatInternals.h"
#import "SCFramePool.h"

#include <libkern/OSAtomic.h>

@implementation SCFramePool
{
    NSMutableArray * stack;

    int32_t lowWaterMark;
    int32_t highWaterMark;
    uint32_t frameCapacity;

    volatile int32_t totalCount;
}


-(SCFramePool *)init
{
    self = [super init];
	if (!self) return self;

    stack = [[NSMutableArray alloc] init];
    
    lowWaterMark = 16;     //TODO: Read this from configuration
    highWaterMark = 40960; //TODO: Read this from configuration
    frameCapacity = 16*1024;
    totalCount = 0;
    
    return self;
}


-(SCFrame *)borrow:(NSString *)reason
{
    SCFrame * frame = NULL;

    @synchronized (stack)
    {
        frame = [stack lastObject];
        if (frame != NULL) [stack removeLastObject];
    }

    if (frame == NULL)
    {
        // stack is empty ...
        frame = [self createFrame];

        //TODO: if (totalCount.intValue() >= highWaterMark) throw new IOException("No more available frames in the pool.");
    }

    return frame;
}


-(void)giveBack:(SCFrame *)frame
{
    assert(frame != NULL);

    if (totalCount > lowWaterMark)
    {
        [frame clear];
        OSAtomicDecrement32(&totalCount);

        // Discard frame
    }
    
    else
    {
        [frame clear];
        @synchronized(stack) {
            [stack addObject:frame];
        }
    }
}


-(SCFrame *)createFrame
{
    SCFrame * frame = [[SCFrame alloc] initWithCapacity:frameCapacity];
    if (frame != NULL) OSAtomicIncrement32(&totalCount);
    return frame;
}


-(NSUInteger)size
{
    return [stack count];
}


-(NSUInteger)capacity
{
    return totalCount;
}


-(void)heartBeat:(double)now
{
/*
	static double before = 0;
	if (now > (before + 5))
	{
		before = now;
		SCLOG_DEBUG(@"FramePool stats / size:%u capacity:%u", [self size], [self capacity]);
	}
*/
}

@end
