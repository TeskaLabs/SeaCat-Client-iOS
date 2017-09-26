//
//  SeaCatPlugin.m
//  SeaCatClient
//
//  Created by Ales Teska on 26.9.17.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import "SeaCatInternals.h"

@implementation SeaCatPlugin

+ (void)commitCharacteristics
{
    const char * characteristics[] = {NULL};
    

    seacatcc_characteristics_store(characteristics);
}

@end

