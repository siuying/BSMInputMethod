//
//  BSMAppDelegate.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMAppDelegate.h"

static BSMEngine* _sharedEngine;

@implementation BSMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

+(BSMEngine*) sharedEngine {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[BSMEngine alloc] init];
    });
    return _sharedEngine;
}

@end
