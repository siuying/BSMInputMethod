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

// match give code with result, array of BSMMatch
-(NSArray*) match:(NSString*)code;

@end
