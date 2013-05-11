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
        return [self minusLastBuffer:sender];

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
    return YES;
}

- (BOOL) minusLastBuffer:(id)sender {
	if ([self.buffer.inputBuffer length] > 0) {
        [self.buffer deleteBackward];
        NSString* marker = self.buffer.marker;
        DDLogVerbose(@"%@", marker);

        [sender setMarkedText:marker
               selectionRange:NSMakeRange(0, [marker length])
             replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
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

@end
