//
//  BSMAppDelegate.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BSMEngine.h"

@interface BSMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

+(BSMEngine*) sharedEngine;

@end
