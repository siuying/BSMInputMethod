//
//  BSMMatch.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMMatch.h"

@implementation BSMMatch

-(id) initWithCode:(NSString*)code word:(NSString*)word {
    self = [super init];
    if (self) {
        self.code = code;
        self.word = word;
    }
    return self;
}

-(BOOL) isEqual:(id)object {
    if ([object class] != [BSMMatch class]) {
        return NO;
    }
    
    BSMMatch* another = (BSMMatch*) object;
    return [self.code isEqual:another.code] && [self.word isEqual:another.word];
}

- (NSUInteger)hash {
    return self.code.hash + self.word.hash;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<BSMMatch %@=%@>", self.code, self.word];
}

+(BSMMatch*) matchWithCode:(NSString*)code word:(NSString*)word {
    return [[BSMMatch alloc] initWithCode:code word:word];
}

@end
