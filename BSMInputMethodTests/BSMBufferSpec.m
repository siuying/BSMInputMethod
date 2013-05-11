//
//  BSMInputMethod - BSMBuffer.m
//  Copyright 2013年 Ignition Soft. All rights reserved.
//
//  Created by: Chong Francis
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "OCMock.h"

#import "BSMBuffer.h"
#import "BSMMatch.h"

SpecBegin(BSMBuffer)

describe(@"BSMBuffer", ^{
    __block BSMBuffer* buffer;
    __block id mockEngine;
    
    beforeEach(^{
        mockEngine = [OCMockObject mockForClass:[BSMEngine class]];
        buffer = [[BSMBuffer alloc] initWithEngine:mockEngine];
    });
    
    describe(@"-initWithEngine:", ^{
        it(@"should init state properly", ^{
            expect(buffer.composedString).to.equal(@"");
            expect(buffer.marker).to.equal(@"");
            expect(buffer.candidates).to.equal(@[]);
        });
    });
    
    describe(@"-deleteBackward:", ^{
        it(@"should update marker by delete", ^{
            [buffer appendBuffer:@"1"];
            [buffer appendBuffer:@"2"];
            expect(buffer.marker).to.equal(@"一丨");
            [buffer deleteBackward];
            expect(buffer.marker).to.equal(@"一");
        });
        
        it(@"should update selection mode by delete", ^{
            [buffer appendBuffer:@"1"];
            [buffer appendBuffer:@"2"];
            [buffer appendBuffer:@"."];
            expect(buffer.selectionMode).to.beTruthy();
            [buffer deleteBackward];
            expect(buffer.selectionMode).to.beFalsy();
        });
    });
    
    describe(@"-appendBuffer:", ^{
        it(@"should update marker by append number", ^{
            [buffer appendBuffer:@"1"];
            expect(buffer.marker).to.equal(@"一");
            
            [buffer appendBuffer:@"2"];
            expect(buffer.marker).to.equal(@"一丨");
        });
        
        it(@"should enter selection mode by append decimal", ^{
            [buffer appendBuffer:@"1"];
            expect(buffer.marker).to.equal(@"一");
            
            [buffer appendBuffer:@"2"];
            expect(buffer.marker).to.equal(@"一丨");
            expect(buffer.selectionMode).to.beFalsy();
            
            [buffer appendBuffer:@"."];
            expect(buffer.selectionMode).to.beTruthy();
        });
    });
    
    describe(@"-candidates", ^{
        before(^{
            buffer = [[BSMBuffer alloc] initWithEngine:[[BSMEngine alloc] init]];
        });

        it(@"should return proepr candidates", ^{
            [buffer appendBuffer:@"9"];
            [buffer appendBuffer:@"9"];
            [buffer appendBuffer:@"1"];
            [buffer appendBuffer:@"9"];
            expect(buffer.candidates).notTo.beNil();
            expect([buffer.candidates count]).to.equal(9U);
            [buffer appendBuffer:@"1"];
            expect([buffer.candidates count]).to.equal(4U);
        });

        it(@"should set composedString", ^{
            [buffer appendBuffer:@"9"];
            [buffer appendBuffer:@"9"];
            [buffer appendBuffer:@"1"];
            [buffer appendBuffer:@"9"];
            expect(buffer.composedString).notTo.beNil();
            expect(buffer.composedString).to.equal(@"苹");
            [buffer appendBuffer:@"1"];
            expect(buffer.composedString).to.equal(@"茸");
        });
    });
});

SpecEnd
