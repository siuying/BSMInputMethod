//
//  BSMAppDelegate.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMAppDelegate.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

static BSMEngine* _sharedEngine;

@implementation BSMAppDelegate

+(BSMEngine*) sharedEngine {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[BSMEngine alloc] init];
    });
    return _sharedEngine;
}

+(IMKServer*) sharedServer {
    BSMAppDelegate* delegate = [NSApp delegate];
    return delegate.server;
}

+(BSMCandidatesWindow*) sharedCandidatesWindow {
    BSMAppDelegate* delegate = [NSApp delegate];
    return delegate.candidateWindow;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupLogger];
}

-(void) setupLogger {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogInfo(@"logger configured.");
}

@end
