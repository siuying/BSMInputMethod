//
//  BSMInputMethodController.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Carbon/Carbon.h>

#import "BSMInputMethodController.h"
#import "BSMEngine.h"
#import "BSMMatch.h"
#import "BSMAppDelegate.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation BSMInputMethodController

- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        self.buffer = [[BSMBuffer alloc] initWithEngine:[BSMAppDelegate sharedEngine]];
    }
    return self;
}

-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    DDLogVerbose(@"Called inputText:%@ key:%ld modifiers:%lx client:%@", string, keyCode, flags, sender);

    if (keyCode == kVK_ANSI_KeypadDecimal) {
        if (self.buffer.inputBuffer.length > 0) {
            if (self.buffer.selectionMode) {
                // if user already in selection mode, beep!
                NSBeep();
            } else {
                // otehrwise enter selection mode
                [self appendBuffer:string client:sender];
            }
            return YES;
        }

    } else if (keyCode >= kVK_ANSI_Keypad0 && keyCode <= kVK_ANSI_Keypad9) {
        if (self.buffer.selectionMode) {
            // in selection mode, if user enter 1-9, apply the word
            if (keyCode > kVK_ANSI_Keypad0) {
                NSUInteger selectionIndex = keyCode - kVK_ANSI_Keypad1;
                if ([self.buffer setSelectedIndex:selectionIndex]) {
                    [self commitComposition:sender];
                } else {
                    NSBeep();
                }
                return YES;
            } else {
                NSBeep();
            }

            return YES;
        } else {
            return [self appendBuffer:string client:sender];
        }

    } else if (keyCode == kVK_ANSI_KeypadMinus) {
        return [self minusBuffer:sender];

    } else if (keyCode == kVK_ANSI_KeypadEnter) {
        if ([self.buffer.candidates count] > 0) {
            return [self selectFirstMatch:sender];
        }
    } else if (keyCode == kVK_ANSI_KeypadDivide) {
        if (self.buffer.inputBuffer.length > 0) {
            if ([self.buffer nextPage]) {
                NSBeep();
            }
            [self showCandidateWindowWithClient:sender];            
        }
        return YES;
    }
    
    return NO;
}

-(BOOL) appendBuffer:(NSString*)string client:(id)sender {
    @synchronized(self) {
        [self.buffer appendBuffer:string];

        NSString* marker = self.buffer.marker;
        DDLogVerbose(@"%@", marker);
        [sender setMarkedText:marker
               selectionRange:NSMakeRange(0, [marker length])
             replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        [self showCandidateWindowWithClient:sender];
        return YES;
    }
}

- (BOOL) minusBuffer:(id)sender {
    @synchronized(self) {
        if ([self.buffer.inputBuffer length] > 0) {
            [self.buffer deleteBackward];
            NSString* marker = self.buffer.marker;
            DDLogVerbose(@"%@", marker);

            [sender setMarkedText:marker
                   selectionRange:NSMakeRange(0, [marker length])
                 replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
            
            if ([marker length]) {
                [self showCandidateWindowWithClient:sender];
            } else {
                [self hideCandidateWindow];
            }
            return YES;
        } else {
            return NO;
        }
    }
}

- (void) clearInput:(id)sender {
    @synchronized(self) {
        DDLogVerbose(@"clear input");
        [sender setMarkedText:@""
               selectionRange:NSMakeRange(NSNotFound,NSNotFound)
             replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
        [self reset];
        [self cancelComposition];
    }
}

- (BOOL) selectFirstMatch:(id)sender {
    if ([self.buffer.candidates count] > 0 && self.buffer.composedString.length > 0) {
        [self commitComposition:sender];
    } else {
        NSBeep();
    }
    return YES;
}

- (NSArray*)candidates:(id)sender {
    NSMutableArray* theCandidates = [NSMutableArray array];
    [self.buffer.candidates enumerateObjectsUsingBlock:^(BSMMatch* match, NSUInteger idx, BOOL *stop) {
        [theCandidates addObject:match.word];
    }];
	return theCandidates;
}

- (void) commitComposition:(id)client {
    @synchronized(self) {
        DDLogVerbose(@"Call commitComposition:%@", client);
        [client insertText:self.buffer.composedString
          replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        [self reset];
        [self hideCandidateWindow];
    }
}

-(void) cancelComposition {
    @synchronized(self) {
        [super cancelComposition];
        [self reset];
        [self hideCandidateWindow];
    }
}

-(void) reset {
    [self.buffer reset];
}

#pragma mark - IMKStateSetting

- (void)activateServer:(id)client {
    [self.buffer reset];
}

- (void)deactivateServer:(id)client {
    BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
    [candidateWindow hideCandidates];
}

#pragma mark - Private

-(void) showCandidateWindowWithClient:(id)sender {
    BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
    @synchronized(candidateWindow) {
        // find the position of the window
        NSUInteger cursorIndex = self.selectionRange.location;
        if (cursorIndex == [self.buffer.marker length] && cursorIndex) {
            cursorIndex--;
        }
        DDLogInfo(@"showCandidateWindowWithClient: select range: %@",
                  NSStringFromRange(self.selectionRange));

        NSRect lineHeightRect = NSMakeRect(0.0, 0.0, 16.0, 16.0);
        @try {
            NSDictionary *attr = [sender attributesForCharacterIndex:cursorIndex lineHeightRectangle:&lineHeightRect];
            if (![attr count]) {
                [sender attributesForCharacterIndex:0 lineHeightRectangle:&lineHeightRect];
            }
        }
        @catch (NSException *exception) {
            DDLogError(@"Exception: cannot find string attribute: %@", [exception debugDescription]);
        }
        
        // show candidate window
        BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
        [candidateWindow updateCandidates:self.buffer.candidates];
        [candidateWindow setWindowTopLeftPoint:lineHeightRect.origin
             bottomOutOfScreenAdjustmentHeight:lineHeightRect.size.height + 4.0];
        [candidateWindow showCandidates];
        
        if (self.buffer.candidates.count == 0) {
            // beep when input made 0 possible candidate
            NSBeep();
        }
    }
}

-(void) hideCandidateWindow {
    BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
    @synchronized(candidateWindow) {
        [candidateWindow hideCandidates];
    }
}

@end
