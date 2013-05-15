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
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation BSMInputMethodController

- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        self.candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
        self.buffer = [[BSMBuffer alloc] initWithEngine:[BSMAppDelegate sharedEngine]];
    }
    return self;
}

-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    DDLogVerbose(@"Called inputText:%@ key:%ld modifiers:%lx client:%@", string, keyCode, flags, sender);

    if (keyCode == kVK_ANSI_KeypadDecimal) {
        if (![self.buffer isEmpty]) {
            if (self.buffer.selectionMode) {
                // if user already in selection mode, select the first word
                [self selectFirstCandidate:sender];
            } else {
                // otherwise enter selection mode
                [self appendBuffer:string client:sender];
            }
            return YES;
        }

    } else if ((keyCode >= kVK_ANSI_Keypad0 && keyCode <= kVK_ANSI_Keypad9) || keyCode == kVK_ANSI_KeypadMultiply) {
        if (self.buffer.selectionMode && keyCode != kVK_ANSI_KeypadMultiply) {
            // in selection mode, if user enter 1-9, apply the word
            if (keyCode > kVK_ANSI_Keypad0) {
                NSUInteger selectionIndex = 0;
                switch (keyCode) {
                    case kVK_ANSI_Keypad1:
                    case kVK_ANSI_Keypad2:
                    case kVK_ANSI_Keypad3:
                    case kVK_ANSI_Keypad4:
                    case kVK_ANSI_Keypad5:
                    case kVK_ANSI_Keypad6:
                    case kVK_ANSI_Keypad7:
                        selectionIndex = keyCode - kVK_ANSI_Keypad1;
                        break;
                    case kVK_ANSI_Keypad8:
                        selectionIndex = 7;
                        break;
                    case kVK_ANSI_Keypad9:
                        selectionIndex = 8;
                        break;
                    default:
                        break;
                }

                if ([self.buffer setSelectedIndex:selectionIndex]) {
                    [self commitComposition:sender];
                } else {
                    [self beep];
                }
                return YES;
            } else {
                [self beep];
            }

            return YES;
        } else if (self.buffer.inputBuffer.length < 6) {
            return [self appendBuffer:string client:sender];
        } else {
            [self beep];
            return YES;
        }

    } else if (keyCode == kVK_ANSI_KeypadMinus) {
        return [self minusBuffer:sender];

    } else if (keyCode == kVK_ANSI_KeypadPlus) {
        if (![self.buffer isEmpty]) {
            if ([self.candidateWindow isShowingCandidatesCode]) {
                [self.candidateWindow hideCandidatesCode];
            } else {
                [self.candidateWindow showCandidatesCode];
            }
            return YES;
        }

    } else if (keyCode == kVK_ANSI_KeypadEnter || keyCode == kVK_Space) {
        if (![self.buffer isEmpty]) {
            if (self.buffer.composedString.length > 0) {
                return [self selectFirstCandidate:sender];
            } else {
                [self beep];
                return YES;
            }
        }

    } else if (keyCode == kVK_ANSI_KeypadDivide) {
        if (![self.buffer isEmpty]) {
            if ([self.buffer nextPage]) {
                [self beep];
            }
            [self showCandidateWindowWithClient:sender];
            return YES;
        }

    } else if (keyCode == kVK_ANSI_KeypadEquals) {
        if (![self.buffer isEmpty]) {
            if ([self.buffer previousPage]) {
                [self beep];
            }
            [self showCandidateWindowWithClient:sender];
            return YES;
        }

    } else if (keyCode == kVK_ANSI_KeypadClear) {
        [self clearInput:sender];
        return YES;

    }

    return NO;
}

-(BOOL) appendBuffer:(NSString*)string client:(id)sender {
    DDLogVerbose(@"will append buffer: %@ + %@", self.buffer.inputBuffer, string);
    self.currentClient = sender;
    [self.buffer appendBuffer:string];
    [self updateMarkedText];
    [self showCandidateWindowWithClient:sender];
    return YES;
}

- (BOOL) minusBuffer:(id)sender {
    DDLogVerbose(@"will minus buffer: %@", self.buffer.inputBuffer);
    self.currentClient = sender;
    if (![self.buffer isEmpty]) {
        [self.buffer deleteBackward];

        [self updateMarkedText];

        if (self.buffer.composedString.length > 0) {
            [self showCandidateWindowWithClient:sender];
        } else {
            [self hideCandidateWindow];
        }
        return YES;
    } else {
        return NO;
    }
}

-(void) updateMarkedText {
    NSString* marker = self.buffer.marker;
    [self.currentClient setMarkedText:[self attrStringWithString:marker]
                       selectionRange:NSMakeRange(marker.length, 0)
                     replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}

- (void) clearInput:(id)sender {
    DDLogVerbose(@"will clear input");
    [sender setMarkedText:@""
           selectionRange:NSMakeRange(NSNotFound,NSNotFound)
         replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
    [self reset];
    [self cancelComposition];
}

- (BOOL) selectFirstCandidate:(id)sender {
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

- (void) commitComposition:(id)sender {
    DDLogVerbose(@"Call commitComposition:%@", sender);

    // fix the premature commit bug in Terminal.app since OS X 10.5
    if ([[sender bundleIdentifier] isEqualToString:@"com.apple.Terminal"] && ![NSStringFromClass([sender class]) isEqualToString:@"IPMDServerClientWrapper"]) {
        [self performSelector:@selector(updateMarkedText)
                   withObject:self.currentClient
                   afterDelay:0.0];
        return;
    }
    
    [sender insertText:self.buffer.composedString
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self reset];
    [self hideCandidateWindow];
}

-(void) cancelComposition {
    [super cancelComposition];
    [self reset];
    [self hideCandidateWindow];
}

-(NSAttributedString*) attrStringWithString:(NSString*)string {
    NSDictionary* attr = [self markForStyle:kTSMHiliteRawText atRange:NSMakeRange(0, string.length)];
    NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:string attributes:attr];
    return attrString;
}

-(void) reset {
    [self.buffer reset];
}

- (void) beep {
    NSBeep();
}

#pragma mark - IMKStateSetting

- (void)activateServer:(id)client {
    DDLogVerbose(@"will activate server");
}

- (void)deactivateServer:(id)client {
    DDLogVerbose(@"will deactivate server");

    // cleanup
    if (![self.buffer isEmpty]) {
        [self.buffer reset];
        [client setMarkedText:@""
               selectionRange:NSMakeRange(0, 0)
             replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }

    // commit any residue in the composing buffer
    [self commitComposition:client];
    
    [self.candidateWindow hideCandidates];

    self.currentClient = nil;
}

#pragma mark - Private

-(void) showCandidateWindowWithClient:(id)sender {
    // find the position of the window
    NSUInteger cursorIndex = self.selectionRange.location;
    if (cursorIndex == [self.buffer.marker length] && cursorIndex) {
        cursorIndex--;
    }
    DDLogInfo(@"showCandidateWindowWithClient: select range: %@",
              NSStringFromRange(self.selectionRange));

    NSRect lineHeightRect = NSMakeRect(0.0, 0.0, 16.0, 16.0);
    // some apps (e.g. Twitter for Mac's search bar) handle this call incorrectly, hence the try-catch
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
    [self.candidateWindow updateCandidates:self.buffer.candidates];
    [self.candidateWindow setWindowTopLeftPoint:lineHeightRect.origin
         bottomOutOfScreenAdjustmentHeight:lineHeightRect.size.height + 4.0];
    [self.candidateWindow showCandidates];
}

-(void) hideCandidateWindow {
    @synchronized(self.candidateWindow) {
        [self.candidateWindow hideCandidates];
    }
}

@end
