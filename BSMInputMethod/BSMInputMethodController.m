//
//  BSMInputMethodController.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMInputMethodController.h"

@implementation BSMInputMethodController

-(BOOL)inputText:(NSString*)string client:(id)sender {
    NSLog(@"%@", string);
    return NO;
}

@end
