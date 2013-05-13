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
        
        it(@"should append 6 char and delete twice", ^{
            [buffer appendBuffer:@"6"];
            [buffer appendBuffer:@"6"];
            [buffer appendBuffer:@"4"];
            [buffer appendBuffer:@"6"];
            [buffer appendBuffer:@"6"];
            [buffer appendBuffer:@"4"];
            [buffer deleteBackward];            
            expect(buffer.inputBuffer).to.equal(@"66466");
            expect(buffer.marker).to.equal(@"𠄌𠄌丶𠄌𠄌");

            [buffer deleteBackward];
            expect(buffer.inputBuffer).to.equal(@"6646");
            expect(buffer.marker).to.equal(@"𠄌𠄌丶𠄌");
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
    
    describe(@"-isEmpty", ^{
        it(@"should not empty if we append content", ^{
            expect([buffer isEmpty]).to.beTruthy();
            [buffer appendBuffer:@"1"];
            expect([buffer isEmpty]).to.beFalsy();

            [buffer deleteBackward];
            expect([buffer isEmpty]).to.beTruthy();
        });
    });
    
    describe(@"-candidates", ^{
        before(^{
            buffer = [[BSMBuffer alloc] initWithEngine:[[BSMEngine alloc] init]];
        });
        
        it(@"should return proper candidates", ^{
            [buffer appendBuffer:@"9"];
            [buffer appendBuffer:@"9"];
            [buffer appendBuffer:@"1"];
            [buffer appendBuffer:@"9"];
            expect(buffer.candidates).notTo.beNil();
            expect([buffer.candidates count]).to.equal(9U);
            [buffer appendBuffer:@"1"];
            expect([buffer.candidates count]).to.equal(4U);
            expect(buffer.composedString).to.equal(@"茸");
        });
    });
    
    describe(@"-possibleNextCode:", ^{
        it(@"should ask engine next possible code", ^{
            [buffer appendBuffer:@"1"];
            [buffer appendBuffer:@"2"];
            [buffer appendBuffer:@"3"];
            [[mockEngine expect] possibleNextCodeWithCode:@"123"];
            [buffer possibleNextCode];
            [mockEngine verify];            
        });
    });
    
    describe(@"-nextPage", ^{
        it(@"should move to next page and wrap", ^{
            buffer.numberOfPage = 3;
            expect([buffer currentPage]).to.equal(0);
            expect([buffer nextPage]).to.beFalsy();
            expect([buffer currentPage]).to.equal(1);
            expect([buffer nextPage]).to.beFalsy();
            expect([buffer currentPage]).to.equal(2);
            expect([buffer nextPage]).to.beTruthy();
            expect([buffer currentPage]).to.equal(0);
        });
    });
    
    describe(@"-previousPage", ^{
        it(@"should move to previous page and wrap", ^{
            buffer.numberOfPage = 3;
            expect([buffer currentPage]).to.equal(0);
            expect([buffer previousPage]).to.beTruthy();
            expect([buffer currentPage]).to.equal(2);
            expect([buffer previousPage]).to.beFalsy();
            expect([buffer currentPage]).to.equal(1);
            expect([buffer previousPage]).to.beFalsy();
            expect([buffer currentPage]).to.equal(0);
        });
    });
});

SpecEnd
