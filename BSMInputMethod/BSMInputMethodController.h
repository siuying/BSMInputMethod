//
//  BSMInputMethodController.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>
#import "BSMBuffer.h"

@interface BSMInputMethodController : IMKInputController {
    /* current number of page, in the IME match candidate window */
    NSUInteger _page;

    BOOL _selectionMode;
}

@property (nonatomic, strong) BSMBuffer* buffer;

- (BOOL) appendBuffer:(NSString*)string client:(id)sender;

- (void) commitComposition:(id)client;

@end
