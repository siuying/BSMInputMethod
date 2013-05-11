//
//  BSMBuffer.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMBuffer.h"
#import "BSMMatch.h"

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
                           @"0": @"囗"};
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
}

- (void) appendBuffer:(NSString*)string {
    [_inputBuffer appendString:string];

    NSString* marker = [_markerMapping objectForKey:string];
    [_markerBuffer appendString:marker];

    _needsUpdateCandidates = YES;
}

-(void) deleteBackward {
    [_inputBuffer deleteCharactersInRange:NSMakeRange([_inputBuffer length]-1, 1)];
    [_markerBuffer deleteCharactersInRange:NSMakeRange([_markerBuffer length]-1, 1)];
    _needsUpdateCandidates = YES;

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
