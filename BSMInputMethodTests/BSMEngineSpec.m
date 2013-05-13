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
        
        it(@"should use * as wildcard", ^{
            NSUInteger numberOfMatch = [engine numberOfMatchWithCode:@"325*2"];
            expect(numberOfMatch).to.beGreaterThanOrEqualTo(1);

            NSUInteger totalPage = ceil(numberOfMatch / 9.0);
            NSUInteger counter = 0;

            BSMMatch* expectMatch = [BSMMatch matchWithCode:@"32562" word:@"他"];
            BOOL hasTarget = NO;
            while(counter < totalPage) {
                NSArray* currentPageMatches = [engine match:@"325*2" page:counter];
                if ([currentPageMatches containsObject:expectMatch]) {
                    hasTarget = YES;
                }
                counter++;
            }
            expect(hasTarget).to.beTruthy();
        });
        
        it(@"should not match 3252 if enter 325*2", ^{
            NSUInteger numberOfMatch = [engine numberOfMatchWithCode:@"325*2"];
            expect(numberOfMatch).to.beGreaterThanOrEqualTo(1);
            
            NSUInteger totalPage = ceil(numberOfMatch / 9.0);
            NSUInteger counter = 0;
            
            BSMMatch* expectMatch = [BSMMatch matchWithCode:@"3252" word:@"師"];
            BOOL hasTarget = NO;
            while(counter < totalPage) {
                NSArray* currentPageMatches = [engine match:@"325*2" page:counter];
                if ([currentPageMatches containsObject:expectMatch]) {
                    hasTarget = YES;
                }
                counter++;
            }
            expect(hasTarget).to.beFalsy();
        });
        
        it(@"should order result by frequency", ^{
            NSUInteger numberOfMatch = [engine numberOfMatchWithCode:@"1*8"];
            expect(numberOfMatch).to.beGreaterThanOrEqualTo(1);
            BSMMatch* expectMatch = [BSMMatch matchWithCode:@"118" word:@"天"];
            NSArray* currentPageMatches = [engine match:@"1*8" page:0];
            expect([currentPageMatches containsObject:expectMatch]).to.beTruthy();
        });
        
        it(@"should return single word", ^{
            NSArray* currentPageMatches = [engine match:@"4" page:0];
            BSMMatch* firstMatch = [currentPageMatches objectAtIndex:0];
            expect(firstMatch.word).to.equal(@"這");
        });
    });
    
    describe(@"-match:page:", ^{
        it(@"should be able to paginate", ^{
            NSArray* result = [engine match:@"1" page:0];
            expect(result).notTo.beNil();
            expect([result count]).to.beLessThanOrEqualTo(9);
            
            result = [engine match:@"1" page:1];
            expect(result).notTo.beNil();
            expect([result count]).to.beGreaterThan(0);
            expect([result count]).to.beLessThanOrEqualTo(9);
        });
        
        it(@"should return 9 result every page (except the last)", ^{
            NSUInteger matchesCount = [engine numberOfMatchWithCode:@"122"];
            NSMutableArray* matches = [NSMutableArray array];;
            NSUInteger totalPage = ceil(matchesCount / 9.0);
            NSUInteger counter = 0;
            while(counter < totalPage) {
                NSArray* currentPageMatches = [engine match:@"122" page:counter];
                if (counter + 1 < totalPage) {
                    expect(currentPageMatches.count).to.equal(9);
                }
                [matches addObjectsFromArray:currentPageMatches];
                counter++;
            }
            expect([matches count]).to.equal(matchesCount);
        });
    });
    
    describe(@"-match:page:", ^{        
        it(@"should return number of result we specify", ^{
            NSArray* matches = [engine match:@"1" page:0 itemsPerPage:20];
            expect(matches).haveCountOf(20);
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
    });
});

SpecEnd
