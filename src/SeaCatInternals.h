//
//  SeaCatInternals.h
//  SeaCatClient
//
//  Created by Ales Teska on 30/11/15.
//  Copyright © 2015 TeskaLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "seacatcc.h"

#import "SeaCatClient.h"
#import "SeaCatPlugin.h"
#import "SCReactor.h"
#import "SCFramePool.h"
#import "SCCSR.h"

#include "spdy.h"

// HTTP protocol
#import "SCURLProtocol.h"

// Error checking
NSError * SCCheckRC(int rc, NSString * message);
NSError * SCError(enum SeaCat_ErrorCodes, NSString * message);

// Logging
void _SCLog(char level, NSString * message);
void _SCLogV(char level, NSString *format, ...);

#define SCLOG_FATAL(...) _SCLogV('F', __VA_ARGS__)
#define SCLOG_ERROR(...) _SCLogV('E', __VA_ARGS__)
#define SCLOG_WARN(...) _SCLogV('W', __VA_ARGS__)
#define SCLOG_INFO(...) _SCLogV('I', __VA_ARGS__)

#ifdef DEBUG
#define SCLOG_DEBUG(...) _SCLogV('D', __VA_ARGS__)
#else
#define SCLOG_DEBUG(...)
#endif
