//
//  BSMBuffer.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMBuffer.h"
#import "BSMMatch.h"
#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation BSMBuffer

- (id)init {
    return [self initWithEngine:[[BSMEngine alloc] init]];
}

-(id) initWithEngine:(BSMEngine*)engine {
    self = [super init];
    if (self) {
        _markerMapping = @{@"1": @"一", @"2": @"丨", @"3": @"丿",
                           @"4": @"丶", @"5": @"亅", @"6": @"𠄌",
                           @"7": @"乂", @"8": @"八", @"9": @"十",
                           @"0": @"囗", @".": @"."};
        self.engine = engine;
        [self reset];
    }
    return self;
}

-(void) reset {
    _inputBuffer = [NSMutableString string];
    _markerBuffer = [NSMutableString string];
    _candidates = @[];
    _composedString = @"";
    _needsUpdateCandidates = NO;
    _selectionMode = NO;
}

-(BOOL) setSelectedIndex:(NSUInteger)index {
    if (self.selectionMode && self.candidates.count > index) {
        BSMMatch* candidate = self.candidates[index];
        _composedString = candidate.word;
        DDLogVerbose(@"selected index: %lu, word: %@", (unsigned long) index, candidate.word);
        return YES;
    } else {
        return NO;
    }
}

- (void) appendBuffer:(NSString*)string {
    NSString* marker = [_markerMapping objectForKey:string];
    [_markerBuffer appendString:marker];

    if ([string isEqualToString:@"."]) {
        self.selectionMode = YES;
    } else {
        [_inputBuffer appendString:string];
        _needsUpdateCandidates = YES;
    }
}

-(void) deleteBackward {
    if ([_markerBuffer length] > 0) {
        NSString* lastInput = [_markerBuffer substringFromIndex:[_markerBuffer length]-1];
        [_markerBuffer deleteCharactersInRange:NSMakeRange([_markerBuffer length]-1, 1)];

        if ([lastInput isEqualToString:@"."]) {
            self.selectionMode = NO;
        } else {
            [_inputBuffer deleteCharactersInRange:NSMakeRange([_inputBuffer length]-1, 1)];
            _needsUpdateCandidates = YES;
        }
    }
}

-(NSString*) inputBuffer {
    return _inputBuffer;
}

-(NSString*) marker {
    return [_markerBuffer copy];
}

-(NSArray*) candidates {
    if (_needsUpdateCandidates) {
        _candidates = [self.engine match:_inputBuffer];
        if ([_candidates count] > 0) {
            BSMMatch* match = [_candidates objectAtIndex:0];
            _composedString = match.word;
        } else {
            _composedString = nil;
        }
        _needsUpdateCandidates = NO;
    }
    return _candidates;
}

-(NSString*) composedString {
    return _composedString;
}

-(void) dealloc {
    _composedString = nil;
    _candidates = nil;
    _markerBuffer = nil;
    _inputBuffer = nil;
    _engine = nil;
}

@end
