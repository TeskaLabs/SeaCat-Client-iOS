//
//  SeaCatPlugin.m
//  SeaCatClient
//
//  Created by Ales Teska on 26.9.17.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import "SeaCatInternals.h"

static NSMutableArray * SeaCatPlugins = nil;

@implementation SeaCatPlugin

- (instancetype)init
{
    self = [super init];
    if (self == nil) return nil;

    if (SeaCatPlugins == nil) SeaCatPlugins = [NSMutableArray new];
    [SeaCatPlugins addObject:self];

    return self;
}

+ (void)commitCharacteristics
{
    NSMutableDictionary * characteristics = [NSMutableDictionary new];

    for(id plugin in SeaCatPlugins)
    {
        if (![plugin isKindOfClass:[SeaCatPlugin class]])
        {
            NSLog(@"%@ is not SeaCatPlugin", plugin);
            continue;
        }
        NSDictionary * pchrs = [plugin getCharacteristics];
        if (pchrs == nil) continue;
        [characteristics addEntriesFromDictionary:pchrs];
    }
    


    const char * characteristics_c[[characteristics count]+1];
    int i=0;
    for (NSString* key in characteristics)
    {
        characteristics_c[i] = [[NSString stringWithFormat:@"%@\037%@", key, [characteristics objectForKey:key]] UTF8String];
        i += 1;
    }
    characteristics_c[i] = NULL; // Final terminator
    seacatcc_characteristics_store(characteristics_c);
}

@end

