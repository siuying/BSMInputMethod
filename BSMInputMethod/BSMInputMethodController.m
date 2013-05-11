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

    if (keyCode >= kVK_ANSI_Keypad0 && keyCode <= kVK_ANSI_Keypad9) {
        return [self appendBuffer:string client:sender];

    } else if (keyCode == kVK_ANSI_KeypadMinus) {
        return [self minusBuffer:sender];

    } else if (keyCode == kVK_ANSI_KeypadEnter) {
        if ([self.buffer.candidates count] > 0) {
            return [self selectFirstMatch:sender];
        } else {
            NSBeep();
            return YES;
        }
    }
    return NO;
}

-(BOOL) appendBuffer:(NSString*)string client:(id)sender {
    [self.buffer appendBuffer:string];
    NSString* marker = self.buffer.marker;
    DDLogVerbose(@"%@", marker);
    [sender setMarkedText:marker
           selectionRange:NSMakeRange(0, [marker length])
         replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self showCandidateWindowWithClient:sender];

    return YES;
}

- (BOOL) minusBuffer:(id)sender {
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

- (void) clearInput:(id)sender {
    DDLogVerbose(@"clear input");
    [self.buffer reset];
    [sender setMarkedText:@""
           selectionRange:NSMakeRange(NSNotFound,NSNotFound)
         replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
    [self cancelComposition];
}

- (BOOL) selectFirstMatch:(id)sender {
    if ([self.buffer.candidates count] > 0) {
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
    DDLogVerbose(@"Call commitComposition:%@", client);
    [client insertText:self.buffer.composedString
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self.buffer reset];
}

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString {
    NSString* _candidateString = [candidateString string];
    DDLogInfo(@" selection: %@", _candidateString);

    [self.client setMarkedText:_candidateString
                selectionRange:NSMakeRange(0, [_candidateString length])
              replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}

- (void)candidateSelected:(NSAttributedString*)candidateString {
//    DDLogInfo(@" selected: %@", [candidateString string]);
//	[self commitComposition:[self client]];
//    [self resetBuffer];
}

-(void) showCandidates {
    if (self.selectionRange.location != NSNotFound) {
        NSRange actualRange;
        NSRect rect = [self.client firstRectForCharacterRange:NSMakeRange(0, [self.buffer.marker length])
                                                  actualRange:&actualRange];
        DDLogVerbose(@" coordinate: %@, actualRange:%@", NSStringFromRect(rect),  NSStringFromRange(actualRange));
    } else {
        DDLogVerbose(@"no selection range");
    }
}

- (void)activateServer:(id)client {
    [self.buffer reset];
}

- (void)deactivateServer:(id)client {
    BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
    [candidateWindow hideCandidates];
}

#pragma mark - Private

-(void) showCandidateWindowWithClient:(id)sender {
    // find the position of the window
    NSUInteger cursorIndex = self.selectionRange.location;
    if (cursorIndex == [self.buffer.marker length] && cursorIndex) {
        cursorIndex--;
    }
    NSRect lineHeightRect = NSMakeRect(0.0, 0.0, 16.0, 16.0);
    @try {
        NSDictionary *attr = [sender attributesForCharacterIndex:cursorIndex lineHeightRectangle:&lineHeightRect];
        if (![attr count]) {
            [sender attributesForCharacterIndex:0 lineHeightRectangle:&lineHeightRect];
        }
    }
    @catch (NSException *exception) {
    }
    
    // show candidate window
    BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
    [candidateWindow updateCandidates:self.buffer.candidates];
    [candidateWindow setWindowTopLeftPoint:lineHeightRect.origin
         bottomOutOfScreenAdjustmentHeight:lineHeightRect.size.height + 4.0];
    [candidateWindow showCandidates];
}

-(void) hideCandidateWindow {
    BSMCandidatesWindow* candidateWindow = [BSMAppDelegate sharedCandidatesWindow];
    [candidateWindow hideCandidates];
}

@end
