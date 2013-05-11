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

-(NSArray*) match:(NSString*)code page:(NSUInteger) page{
    NSMutableArray* result = [NSMutableArray array];
    FMResultSet *rs = [self.db executeQuery:@"select word, code from ime where code LIKE ? LIMIT 10 OFFSET ?",
                       [NSString stringWithFormat:@"%@%%", code],
                       [NSNumber numberWithUnsignedInteger:(page)*10]];
    while ([rs next]) {
        NSString* word = [rs stringForColumn:@"word"];
        NSString* code = [rs stringForColumn:@"code"];
        [result addObject:[BSMMatch matchWithCode:code word:word]];
    }
    [rs close];
    return result;
}

@end
