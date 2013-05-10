//
//  main.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

const NSString* kConnectionName = @"BSMInputMethod_Connection";

static IMKServer* server;

int main(int argc, char *argv[])
{
    //find the bundle identifier and then initialize the input method server
    NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];

    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:identifier];
    
    NSApplication* app = [NSApplication sharedApplication];
	
    //load the bundle explicitly because in this case the input method is a background only application
	[NSBundle loadNibNamed:@"MainMenu" owner:app];
	
	//finally run everything
	[app run];
	
    return 0;
}
