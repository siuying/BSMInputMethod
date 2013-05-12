//
//  BSMEngine.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface BSMEngine : NSObject

@property (nonatomic, strong) FMDatabase* db;
@property (nonatomic, strong) NSCache* cache;

// match given code with BSMMatch
// @param code ime code
// @return array of BSMMatch
-(NSArray*) match:(NSString*)code;

// match given code with BSMMatch
// @param code ime code
// @param number of page, begin with 0
// @return array of BSMMatch
-(NSArray*) match:(NSString*)code page:(NSUInteger) page;

// Number of match by given code
// @return number of matches
-(NSUInteger) numberOfMatchWithCode:(NSString*)code;

@end
