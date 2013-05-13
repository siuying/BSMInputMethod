//
//  BSMInputMethodController.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>

#import "BSMBuffer.h"
#import "BSMCandidatesWindow.h"

@interface BSMInputMethodController : IMKInputController {
}

@property (nonatomic, strong) BSMBuffer* buffer;
@property (nonatomic, strong) BSMCandidatesWindow* candidateWindow;
@property (nonatomic, strong) id currentClient;

- (BOOL) appendBuffer:(NSString*)string client:(id)sender;

// select the first matching candidate
- (BOOL) selectFirstCandidate:(id)sender;

- (void) commitComposition:(id)client;

// notify something was wrong to user
// by default call beep on system
- (void) beep;

@end
