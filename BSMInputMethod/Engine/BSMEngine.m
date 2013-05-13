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

#define kCacheObjects 100

static NSSet* _allCode;

@implementation BSMEngine

+(void) initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allCode = [NSSet setWithArray:@[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"]];
    });
}

+(NSSet*) allCode {
    return _allCode;
}

-(id) init {
    self = [super init];
    if (self) {

        self.cache = [[NSCache alloc] init];
        [self.cache setCountLimit:kCacheObjects];

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
    [self.cache removeAllObjects];
}

-(NSArray*) match:(NSString*)code {
    return [self match:code page:0];
}

-(NSArray*) match:(NSString*)code page:(NSUInteger) page {
    return [self match:code page:page itemsPerPage:9U];
}

-(NSArray*) match:(NSString*)code page:(NSUInteger) page itemsPerPage:(NSUInteger)itemsPerPage {
    NSAssert(code, @"code cannot be nil");
    NSAssert(itemsPerPage != 0, @"items per page must be > 1");

    @autoreleasepool {
        NSString* cacheKey = [NSString stringWithFormat:@"match.%@p%lu", code, page];
        NSMutableArray* result = [self.cache objectForKey:cacheKey];
        if (!result) {
            NSMutableArray* newResult = [NSMutableArray array];
            NSString* query = [NSString stringWithFormat:@"%@%%", [code stringByReplacingOccurrencesOfString:@"*" withString:@"%"]];
            NSUInteger minCodeLength = MAX([query length] - 1, 1);
            FMResultSet *rs;
            
            // if this is a wildcard search, we sort result by frequency first
            if ([code rangeOfString:@"*"].location != NSNotFound) {
                rs = [self.db executeQuery:@"select frequency, length(code) as len, word, code, min(id) as minid from ime where code LIKE ? and len >= ? group by word order by len, frequency LIMIT ? OFFSET ?", query, @(minCodeLength), @(itemsPerPage), @(page*itemsPerPage)];
            } else {
                rs = [self.db executeQuery:@"select length(code) as len, word, code, min(id) as minid from ime where code LIKE ? and len >= ? group by word order by len, minid LIMIT ? OFFSET ?", query, @(minCodeLength), @(itemsPerPage), @(page*9U)];
            }
            
            while ([rs next]) {
                NSString* word = [rs stringForColumn:@"word"];
                NSString* code = [rs stringForColumn:@"code"];
                [newResult addObject:[BSMMatch matchWithCode:code word:word]];
            }
            [rs close];

            result = [newResult copy];
            [self.cache setObject:result forKey:cacheKey];
        }

        return result;
    }
}

-(NSUInteger) numberOfMatchWithCode:(NSString*)code {
    NSAssert(code, @"code cannot be nil");
    @autoreleasepool {        
        NSString* cacheKey = [NSString stringWithFormat:@"matchcount.%@", code];
        NSNumber* result = [self.cache objectForKey:cacheKey];
        if (!result) {
            NSString* query = [NSString stringWithFormat:@"%@%%", [code stringByReplacingOccurrencesOfString:@"*" withString:@"%"]];
            NSUInteger minCodeLength = MAX([query length] - 1, 1);
            FMResultSet *rs = [self.db executeQuery:@"select count(*) from (select word, code, length(code) as len from ime where code LIKE ? and len >= ? group by word)", query, @(minCodeLength)];
            NSUInteger numberOfMatch = 0;
            if ([rs next]) {
                numberOfMatch = (NSUInteger) [rs intForColumnIndex:0];
            }
            [rs close];
            result = @(numberOfMatch);
            [self.cache setObject:result forKey:cacheKey];
        }
        return [result unsignedIntegerValue];
    }
}

-(NSSet*) possibleNextCodeWithCode:(NSString*)code {
    if ([code length] >= 6) {
        return [NSSet set];
    } else {
        NSMutableSet* possibleNextCodes = [NSMutableSet set];
        [[BSMEngine allCode] enumerateObjectsUsingBlock:^(NSString* nextCodeChar, BOOL *stop) {
            NSString* nextCode = [code stringByAppendingString:nextCodeChar];
            if ([self numberOfMatchWithCode:nextCode] > 0) {
                [possibleNextCodes addObject:nextCode];
            }
        }];
        return possibleNextCodes;
    }
}

@end
