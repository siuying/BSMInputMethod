//
//  BSMEngine.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月10日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMEngine.h"
#import "BSMMatch.h"
#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation BSMEngine

-(id) init {
    self = [super init];
    if (self) {
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        NSString* path = [bundle pathForResource:@"bsm" ofType:@"db"];
        self.db = [FMDatabase databaseWithPath:path];
        [self.db openWithFlags:SQLITE_OPEN_READONLY];
        [self.db executeQuery:@"PRAGMA fullfsync = OFF;"];
        [self.db executeQuery:@"PRAGMA temp_store = MEMORY;"];
        [self.db executeQuery:@"PRAGMA synchronous = OFF;"];
        [self.db executeQuery:@"PRAGMA journal_mode = MEMORY;"];
        [self.db executeQuery:@"PRAGMA temp_store = MEMORY;"];
        DDLogInfo(@"BSMEngine configured.");
    }
    return self;
}

-(void) dealloc {
    if (self.db) {
        [self.db close];
        self.db = nil;
    }
}

-(NSArray*) match:(NSString*)code {
    return [self match:code page:0];
}

-(NSArray*) match:(NSString*)code page:(NSUInteger) page {
    NSAssert(code, @"code cannot be nil");
    NSMutableArray* result = [NSMutableArray array];
    NSString* query = [NSString stringWithFormat:@"%@%%", [code stringByReplacingOccurrencesOfString:@"*" withString:@"%"]];
    NSUInteger minCodeLength = MAX([query length] - 1, 1);
    FMResultSet *rs;
    
    // if this is a wildcard search, we sort result by frequency first
    if ([code rangeOfString:@"*"].location != NSNotFound) {
        rs = [self.db executeQuery:@"select frequency, length(code) as len, word, code, min(id) as minid from ime where code LIKE ? and len >= ? group by word order by len, frequency LIMIT 9 OFFSET ?", query, @(minCodeLength), @(page*9U)];
    } else {
        rs = [self.db executeQuery:@"select length(code) as len, word, code, min(id) as minid from ime where code LIKE ? and len >= ? group by word order by len, minid LIMIT 9 OFFSET ?", query, @(minCodeLength), @(page*9U)];
    }
    
    while ([rs next]) {
        NSString* word = [rs stringForColumn:@"word"];
        NSString* code = [rs stringForColumn:@"code"];
        [result addObject:[BSMMatch matchWithCode:code word:word]];
    }
    [rs close];
    return result;
}

-(NSUInteger) numberOfMatchWithCode:(NSString*)code {
    NSAssert(code, @"code cannot be nil");
    NSString* query = [NSString stringWithFormat:@"%@%%", [code stringByReplacingOccurrencesOfString:@"*" withString:@"%"]];
    NSUInteger minCodeLength = MAX([query length] - 1, 1);
    FMResultSet *rs = [self.db executeQuery:@"select count(*) from (select word, code, length(code) as len from ime where code LIKE ? and len >= ? group by word)", query, @(minCodeLength)];
    NSUInteger numberOfMatch = 0;
    if ([rs next]) {
        numberOfMatch = (NSUInteger) [rs intForColumnIndex:0];
    }
    [rs close];
    return numberOfMatch;
}

@end
