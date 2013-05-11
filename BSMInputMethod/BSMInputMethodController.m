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
        _markerMapping = @{@"1": @"一", @"2": @"丨", @"3": @"丿",
                           @"4": @"丶", @"5": @"亅", @"6": @"𠄌",
                           @"7": @"乂", @"8": @"八", @"9": @"十",
                           @"0": @"囗"};
        [self resetBuffer];
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
        if ([_inputBuffer length] > 0) {
            return [self selectFirstMatch:sender];
        }
    }
    return NO;
}

-(void) resetBuffer {
    self.composedString = @"";
    _inputBuffer = [NSMutableString string];
    _convertedInputBuffer = [NSMutableString string];
    _page = 0;
}

-(BOOL) appendBuffer:(NSString*)string client:(id)sender {
    [_inputBuffer appendString:string];

    NSString* marker = [_markerMapping objectForKey:string];
    [_convertedInputBuffer appendString:marker];
    
    [sender setMarkedText:_convertedInputBuffer
           selectionRange:NSMakeRange(0, [_convertedInputBuffer length])
         replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

    // set composed string
    BSMEngine* engine = [BSMAppDelegate sharedEngine];
    NSArray* matches = [engine match:_inputBuffer];
    if ([matches count] > 0) {
        BSMMatch* match = [matches objectAtIndex:0];
        self.composedString = match.word;
    }

    DDLogInfo(@" appendBuffer: %@ -> %@", _inputBuffer, _convertedInputBuffer);
//    IMKCandidates* candidates = [BSMAppDelegate sharedCandidates];
//    [candidates setSelectionKeys:@[]];
//    [candidates updateCandidates];
//    [candidates show:kIMKLocateCandidatesBelowHint];
    return YES;
}

- (BOOL) minusLastBuffer:(id)sender {
	if ([_inputBuffer length] > 0) {
        [_inputBuffer deleteCharactersInRange:NSMakeRange([_inputBuffer length]-1, 1)];
        [_convertedInputBuffer deleteCharactersInRange:NSMakeRange([_convertedInputBuffer length]-1, 1)];

        [sender setMarkedText:_convertedInputBuffer
               selectionRange:NSMakeRange(0, [_convertedInputBuffer length])
             replacementRange:NSMakeRange(NSNotFound,NSNotFound)];

        DDLogInfo(@" minusLastBuffer: %@ -> %@", _inputBuffer, _convertedInputBuffer);
        return YES;
	} else {
        return NO;
    }
}

- (void) clearInput:(id)sender {
    [self resetBuffer];
    [sender setMarkedText:_inputBuffer
           selectionRange:NSMakeRange(NSNotFound,NSNotFound)
         replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
    [self cancelComposition];
}

- (BOOL) selectFirstMatch:(id)sender {
    BSMEngine* engine = [BSMAppDelegate sharedEngine];
    NSArray* matches = [engine match:_inputBuffer];
    if ([matches count] > 0) {
        BSMMatch* match = [matches objectAtIndex:0];
        self.composedString = match.word;
        [self commitComposition:sender];
    } else {
        NSBeep();
    }

    return YES;
}

- (NSArray*)candidates:(id)sender {
    NSMutableArray* theCandidates = [NSMutableArray array];
    BSMEngine* engine = [BSMAppDelegate sharedEngine];
    
    if ([_inputBuffer length] > 0) {
        NSArray* matches = [engine match:_inputBuffer];
        [matches enumerateObjectsUsingBlock:^(BSMMatch* match, NSUInteger idx, BOOL *stop) {
            [theCandidates addObject:match.word];
        }];
        DDLogInfo(@"%ld candidates found: %@", [matches count], matches);
    }

	return theCandidates;
}

- (void) commitComposition:(id)client {
    DDLogVerbose(@"Call commitComposition:%@", client);
    [client insertText:self.composedString
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self resetBuffer];
}

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString {
    NSString* _candidateString = [candidateString string];
    DDLogInfo(@" selection: %@", _candidateString);

    [self.client setMarkedText:_candidateString
                selectionRange:NSMakeRange(0, [_candidateString length])
              replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
}

- (void)candidateSelected:(NSAttributedString*)candidateString {
    DDLogInfo(@" selected: %@", [candidateString string]);
	[self commitComposition:[self client]];
    [self resetBuffer];
}

@end
