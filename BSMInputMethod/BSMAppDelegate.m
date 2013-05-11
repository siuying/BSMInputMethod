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

+(IMKCandidates*) sharedCandidates {
    BSMAppDelegate* delegate = [NSApp delegate];
    return delegate.candidates;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupLogger];
}

-(void) setupLogger {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24;
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:self.fileLogger];
    DDLogInfo(@"logger configured.");
}

@end
