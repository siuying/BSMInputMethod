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
#import <math.h>

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
                           @"0": @"囗", @".": @".", @"*": @"*"};
        self.engine = engine;
        [self reset];
    }
    return self;
}

-(void) reset {
    @synchronized(self) {
        _inputBuffer = [NSMutableString string];
        _marker = [NSMutableString string];
        _candidates = @[];
        _composedString = @"";
        _needsUpdateCandidates = NO;
        _selectionMode = NO;
        _numberOfPage = 0;
        _currentPage = 0;
    }
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

-(BOOL) nextPage {
    @synchronized(self) {
        DDLogVerbose(@"nextPage: (%lu/%lu)", _currentPage, _numberOfPage);
        if (_currentPage + 1 < _numberOfPage) {
            _currentPage++;
            _needsUpdateCandidates = YES;
            DDLogVerbose(@" current page is now: %lu", _currentPage);
            return NO;
        } else {
            _currentPage = 0;
            _needsUpdateCandidates = YES;
            DDLogVerbose(@" current page is now: %lu", _currentPage);
            return YES;
        }
    }
}

-(BOOL) previousPage {
    @synchronized(self) {
        DDLogVerbose(@"previousPage: (%lu/%lu)", _currentPage, _numberOfPage);
        if (_currentPage > 0) {
            _currentPage--;
            _needsUpdateCandidates = YES;
            DDLogVerbose(@" current page is now: %lu", _currentPage);
            return NO;
        } else {
            _currentPage = _numberOfPage - 1;
            _needsUpdateCandidates = YES;
            DDLogVerbose(@" current page is now: %lu", _currentPage);
            return YES;
        }
    }
}

-(NSString*) composedString {
    if (_needsUpdateCandidates || !_composedString) {
        [self candidates];
    }
    return _composedString;
}

-(BOOL) isEmpty {
    return !self.inputBuffer || self.inputBuffer.length == 0;
}

- (void) appendBuffer:(NSString*)string {
    @synchronized(self) {
        NSString* marker = [_markerMapping objectForKey:string];
        if (marker) {
            [self.marker appendString:marker];
        } else {
            NSAssert(@"Unexpected character: %@", string);
        }

        if ([string isEqualToString:@"."]) {
            _selectionMode = YES;
        } else {
            [_inputBuffer appendString:string];
            _needsUpdateCandidates = YES;
        }
    }
}

-(void) deleteBackward {
    @synchronized(self) {
        if ([self.marker length] > 0) {
            if ([self.marker hasSuffix:@"."]) {
                _selectionMode = NO;
            } else {
                [self.inputBuffer deleteCharactersInRange:[self.inputBuffer rangeOfComposedCharacterSequencesForRange:NSMakeRange([self.inputBuffer length]-1, 1)]];
                _needsUpdateCandidates = YES;
            }
            [self.marker deleteCharactersInRange:[self.marker rangeOfComposedCharacterSequencesForRange:NSMakeRange([self.marker length]-1, 1)]];
        }
    }
}

-(NSArray*) candidates {
    @synchronized(self) {
        if (_needsUpdateCandidates) {
            if ([_inputBuffer length] > 0) {
                NSUInteger numberOfMatches = [self.engine numberOfMatchWithCode:_inputBuffer];
                _numberOfPage = ceil(numberOfMatches / 9.0);
                _candidates = [self.engine match:_inputBuffer page:self.currentPage];

                DDLogVerbose(@"(%@): matches: %lu, pages: %lu", _inputBuffer, numberOfMatches, _numberOfPage);
                if ([_candidates count] > 0) {
                    BSMMatch* match = [_candidates objectAtIndex:0];
                    _composedString = match.word;
                } else {
                    _composedString = @"";
                }
            } else {
                _numberOfPage = 1;
                _candidates = @[];
                _composedString = @"";
            }
            _needsUpdateCandidates = NO;
        }
        return _candidates;
    }
}

-(NSSet*) possibleNextCode {
    if ([self isEmpty]) {
        return [BSMEngine allCode];
    } else {
        return [self.engine possibleNextCodeWithCode:self.inputBuffer];
    }
}

-(void) dealloc {
}

@end
