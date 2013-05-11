//
//  BSMAppDelegate.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

#import "BSMEngine.h"
#import "DDFileLogger.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface BSMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign, nonatomic) IBOutlet NSWindow *window;
@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) IMKServer* server;
@property (strong, nonatomic) IMKCandidates* candidates;

+(BSMEngine*) sharedEngine;

@end
