//
//  BSMMatch.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

// Model object, represent a pair of IME code and word
@interface BSMMatch : NSObject

// the ime code
@property (nonatomic, strong) NSString* code;

// the word
@property (nonatomic, strong) NSString* word;

+(BSMMatch*) matchWithCode:(NSString*)code word:(NSString*)word;

-(id) initWithCode:(NSString*)code word:(NSString*)word;

-(BOOL) isEqual:(id)object;

- (NSUInteger)hash;

@end
