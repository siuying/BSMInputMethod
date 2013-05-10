//
//  BSMInputMethodController.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>

@interface BSMInputMethodController : IMKInputController {
    NSInteger _insertionIndex;
    NSMutableString* _inputBuffer;
    BOOL _selectionMode;
}

-(BOOL) appendBuffer:(NSString*)string client:(id)sender;

@end
