//
//  BSMInputMethodController.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>

@interface BSMInputMethodController : IMKInputController {
    /* what user entered in buffer */
    NSMutableString* _inputBuffer;

    /* user input converted into markers */
    NSMutableString* _convertedInputBuffer;

    /* current number of page, in the IME match candidate window */
    NSUInteger _page;

    BOOL _selectionMode;
    
    /* input code to marker mapping, e.g. 1 -> 一 */
    NSDictionary* _markerMapping;
}

@property (nonatomic, copy) NSString* composedString;

- (BOOL)appendBuffer:(NSString*)string client:(id)sender;
- (void) commitComposition:(id)client;

@end
