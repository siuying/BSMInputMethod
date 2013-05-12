//
//  BSMInputMethod - BSMInputMethodController.m
//  Copyright 2013年 Ignition Soft. All rights reserved.
//
//  Created by: Chong Francis
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "OCMock.h"
#import <Carbon/Carbon.h>
#import <InputMethodKit/InputMethodKit.h>

#import "BSMInputMethodController.h"
#import "BSMCandidatesWindow.h"

SpecBegin(BSMInputMethodController)

describe(@"BSMInputMethodController", ^{
    __block BSMInputMethodController* controller;
    __block id mockServer;
    __block id mockClient;
    __block id mockBuffer;
    __block id mockController;
    __block id mockCandidateWindow;

    before(^{
        mockServer = [OCMockObject niceMockForClass:[IMKServer class]];
        mockClient = [OCMockObject niceMockForProtocol:@protocol(IMKTextInput)];
        controller = [[BSMInputMethodController alloc] initWithServer:nil delegate:nil client:nil];
        mockController = [OCMockObject partialMockForObject:controller];
        controller = mockController;
        
        mockCandidateWindow = [OCMockObject niceMockForClass:[BSMCandidatesWindow class]];
        controller.candidateWindow = mockCandidateWindow;

        mockBuffer = [OCMockObject partialMockForObject:controller.buffer];
        controller.buffer = mockBuffer;
    });
    after(^{
        mockServer = nil;
        mockClient = nil;
        mockController = nil;
        mockCandidateWindow = nil;
        mockBuffer = nil;
        [controller inputControllerWillClose];
        controller = nil;
    });
    
    describe(@"-inputText:key:modifiers:client:",^{
        describe(@"numbers key", ^{
            it(@"should enter input", ^{
                [((BSMBuffer*)[mockBuffer expect]) appendBuffer:@"8"];
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [mockBuffer verify];
            });
            
            it(@"should not allow enter more than 6 input key", ^{
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
                [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
                [controller inputText:@"9" key:kVK_ANSI_Keypad9 modifiers:0 client:mockClient];
                [controller inputText:@"4" key:kVK_ANSI_Keypad4 modifiers:0 client:mockClient];
                
                [[mockController expect] beep];
                BOOL handled = [controller inputText:@"9" key:kVK_ANSI_Keypad4 modifiers:0 client:mockClient];
                expect(handled).to.beTruthy();
                expect([[mockBuffer inputBuffer] length]).to.equal(6);
                [mockController verify];
            });
        });
        
        
        describe(@"* key", ^{
            it(@"should enter input", ^{
                [((BSMBuffer*)[mockBuffer expect]) appendBuffer:@"*"];
                [controller inputText:@"*" key:kVK_ANSI_KeypadMultiply modifiers:0 client:mockClient];
                [mockBuffer verify];
            });

            it(@"should not allow * key in selection mode", ^{
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [controller inputText:@"." key:kVK_ANSI_KeypadDecimal modifiers:0 client:mockClient];

                [[mockController expect] beep];
                [controller inputText:@"*" key:kVK_ANSI_KeypadMultiply modifiers:0 client:mockClient];
                [mockBuffer verify];
            });
        });

        describe(@"decimal key", ^{            
            it(@"should enter selection mode", ^{
                [[[mockBuffer expect] andForwardToRealObject] appendBuffer:@"8"];
                [[[mockBuffer expect] andForwardToRealObject] appendBuffer:@"."];
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [controller inputText:@"." key:kVK_ANSI_KeypadDecimal modifiers:0 client:mockClient];
                [mockBuffer verify];
                expect(controller.buffer.selectionMode).to.beTruthy();
            });

            it(@"should select candidate", ^{
                [[[mockBuffer expect] andForwardToRealObject] appendBuffer:@"8"];
                [[[mockBuffer expect] andForwardToRealObject] appendBuffer:@"."];
                [((BSMBuffer*)[[mockBuffer expect] andForwardToRealObject]) setSelectedIndex:7U];
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [controller inputText:@"." key:kVK_ANSI_KeypadDecimal modifiers:0 client:mockClient];
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [mockBuffer verify];
                
                [[[mockBuffer expect] andForwardToRealObject] appendBuffer:@"8"];
                [[[mockBuffer expect] andForwardToRealObject] appendBuffer:@"."];
                [((BSMBuffer*)[[mockBuffer expect] andForwardToRealObject]) setSelectedIndex:0U];
                [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
                [controller inputText:@"." key:kVK_ANSI_KeypadDecimal modifiers:0 client:mockClient];
                [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
                [mockBuffer verify];
            });
        });
    });
    
    describe(@"minus key", ^{
        it(@"should delete last input", ^{
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
            [controller inputText:@"-" key:kVK_ANSI_KeypadMinus modifiers:0 client:mockClient];
            expect([[mockBuffer inputBuffer] length]).to.equal(2);
        });
        
        it(@"should pass minus key to system if no word in buffer", ^{
            BOOL handled = [controller inputText:@"-" key:kVK_ANSI_KeypadMinus modifiers:0 client:mockClient];
            expect(handled).to.beFalsy();
        });
    });
    
    describe(@"enter key", ^{
        it(@"should pass enter key to system if no input", ^{
            BOOL handled = [controller inputText:@"\n" key:kVK_ANSI_KeypadEnter modifiers:0 client:mockClient];
            expect(handled).to.beFalsy();
        });

        it(@"should select first candidate", ^{
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];

            [((BSMInputMethodController*)[mockController expect]) selectFirstCandidate:mockClient];
            [controller inputText:@"\n" key:kVK_ANSI_KeypadEnter modifiers:0 client:mockClient];
            [mockController verify];
        });

        it(@"should beep if press enter when no match", ^{
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];

            [((BSMInputMethodController*)[mockController expect]) beep];
            BOOL handled = [controller inputText:@"\n" key:kVK_ANSI_KeypadEnter modifiers:0 client:mockClient];
            expect(handled).to.beTruthy();
            [mockController verify];
        });
    });
    
    describe(@"plus key", ^{
        it(@"should pass enter key to system if no input", ^{
            BOOL handled = [controller inputText:@"+" key:kVK_ANSI_KeypadPlus modifiers:0 client:mockClient];
            expect(handled).to.beFalsy();
        });
        
        it(@"should toggle candidate window", ^{
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
            NSValue* value = [NSNumber numberWithBool:NO];
            [[[mockCandidateWindow stub] andReturnValue:value] isShowingCandidatesCode];
            [[mockCandidateWindow expect] showCandidatesCode];

            BOOL handled = [controller inputText:@"+" key:kVK_ANSI_KeypadPlus modifiers:0 client:mockClient];
            expect(handled).to.beTruthy();
            [mockCandidateWindow verify];
        });
        
        it(@"should toggle candidate window", ^{
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"8" key:kVK_ANSI_Keypad8 modifiers:0 client:mockClient];
            [controller inputText:@"1" key:kVK_ANSI_Keypad1 modifiers:0 client:mockClient];
            BOOL handled = [controller inputText:@"+" key:kVK_ANSI_KeypadPlus modifiers:0 client:mockClient];
            expect(handled).to.beTruthy();

            NSValue* value = [NSNumber numberWithBool:YES];
            [[[mockCandidateWindow stub] andReturnValue:value] isShowingCandidatesCode];
            [[mockCandidateWindow expect] hideCandidatesCode];
            handled = [controller inputText:@"+" key:kVK_ANSI_KeypadPlus modifiers:0 client:mockClient];
            expect(handled).to.beTruthy();
            [mockCandidateWindow verify];
        });
    });
});

SpecEnd
