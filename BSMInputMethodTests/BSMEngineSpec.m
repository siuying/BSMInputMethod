//
//  BSMInputMethod - BSMEngineSpec.m
//  Copyright 2013年 Ignition Soft. All rights reserved.
//
//  Created by: Chong Francis
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "BSMEngine.h"
#import "BSMMatch.h"
#import <math.h>

SpecBegin(BSMEngine)

describe(@"BSMEngine", ^{
    __block BSMEngine* engine;

    beforeEach(^{
        engine = [[BSMEngine alloc] init];
    });

    afterEach(^{
        engine = nil;
    });

    describe(@"-match:", ^{
        it(@"should match input code", ^{
            NSArray* result = [engine match:@"121"];
            BSMMatch* expectMatch = [BSMMatch matchWithCode:@"121" word:@"工"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
            
            result = [engine match:@"53"];
            expectMatch = [BSMMatch matchWithCode:@"53" word:@"刀"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
            
            result = [engine match:@"32562"];
            expectMatch = [BSMMatch matchWithCode:@"32562" word:@"他"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
            
            result = [engine match:@"301453"];
            expectMatch = [BSMMatch matchWithCode:@"301453" word:@"的"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
        });

        it(@"should not return more than 9 matches", ^{
            NSArray* result = [engine match:@"1"];
            expect(result).notTo.beNil();
            expect([result count]).to.beLessThanOrEqualTo(9);
        });
    });
    
    describe(@"-match:", ^{
        it(@"should match input code", ^{
            NSArray* result = [engine match:@"121"];
            BSMMatch* expectMatch = [BSMMatch matchWithCode:@"121" word:@"工"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
            
            result = [engine match:@"53"];
            expectMatch = [BSMMatch matchWithCode:@"53" word:@"刀"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
            
            result = [engine match:@"32562"];
            expectMatch = [BSMMatch matchWithCode:@"32562" word:@"他"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
            
            result = [engine match:@"301453"];
            expectMatch = [BSMMatch matchWithCode:@"301453" word:@"的"];
            expect(result).notTo.beNil();
            expect(result).to.contain(expectMatch);
        });
        
        it(@"should be able to paginate", ^{
            NSArray* result = [engine match:@"1" page:0];
            expect(result).notTo.beNil();
            expect([result count]).to.beLessThanOrEqualTo(9);
            
            result = [engine match:@"1" page:1];
            expect(result).notTo.beNil();
            expect([result count]).to.beGreaterThan(0);
            expect([result count]).to.beLessThanOrEqualTo(9);
        });
    });
    
    
    describe(@"-numberOfMatchWithCode:", ^{
        it(@"should return number of matches", ^{
            NSUInteger matches = [engine numberOfMatchWithCode:@"99991"];
            expect(matches).to.equal(2U);
            
            matches = [engine numberOfMatchWithCode:@"11119"];
            expect(matches).to.equal(1U);
            
            matches = [engine numberOfMatchWithCode:@"11119111"];
            expect(matches).to.equal(0U);
        });

        it(@"should consistence with the actual matches returned", ^{
            NSUInteger matchesCount = [engine numberOfMatchWithCode:@"1234"];
            NSMutableArray* matches = [NSMutableArray array];;
            NSUInteger totalPage = ceil(matchesCount / 9.0);
            NSUInteger counter = 0;
            while(counter < totalPage) {
                [matches addObjectsFromArray:[engine match:@"1234" page:counter]];
                counter++;
            }
            expect([matches count]).to.equal(matchesCount);
        });
    });
});

SpecEnd
