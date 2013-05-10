//
//  BSMInputMethodController.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "BSMInputMethodController.h"

@implementation BSMInputMethodController

- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        [self resetBuffer];
    }
    return self;
}

-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    if (keyCode >= kVK_ANSI_Keypad0 && keyCode <= kVK_ANSI_Keypad9) {
        [self appendBuffer:string client:sender];
        return YES;
    } else if (keyCode == kVK_ANSI_KeypadMinus) {
        [self minusLastBuffer:sender];
        return YES;
    } else if (keyCode == kVK_ANSI_KeypadDecimal) {

    } else if (keyCode == kVK_ANSI_KeypadEnter) {

    }
    return NO;
}

-(void) resetBuffer {
    _inputBuffer = [NSMutableString string];
    _insertionIndex = 0;
}

-(BOOL) appendBuffer:(NSString*)string client:(id)sender {
    // cannot accept more input if input is 6
    if ([_inputBuffer length] >= 6) {
        return NO;
    }

    [_inputBuffer appendString:string];
    _insertionIndex++;

    [sender setMarkedText:_inputBuffer
           selectionRange:NSMakeRange(0, [_inputBuffer length])
         replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

    return YES;
}

- (void)minusLastBuffer:(id)sender {
	if ( _insertionIndex > 0 && _insertionIndex <= [_inputBuffer length] ) {
		--_insertionIndex;
        [_inputBuffer deleteCharactersInRange:NSMakeRange(_insertionIndex,1)];
		[sender setMarkedText:_inputBuffer
               selectionRange:NSMakeRange(_insertionIndex, 0)
             replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
	}
}

@end
