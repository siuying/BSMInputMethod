//
//  BSMBuffer.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSMEngine.h"

@interface BSMBuffer : NSObject {
    /* input code to marker mapping, e.g. 1 -> 一 */
    NSDictionary* _markerMapping;

    /* what user entered in buffer */
    NSMutableString* _inputBuffer;
    
    /* user input converted into markers */
    NSMutableString* _markerBuffer;
    
    /* candidates */
    NSArray* _candidates;
    
    /* composed string from input buffer */
    NSString* _composedString;

    BOOL _needsUpdateCandidates;
}

@property (nonatomic, strong) BSMEngine* engine;
@property (nonatomic, assign) BOOL selectionMode;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger numberOfPage;

-(id) initWithEngine:(BSMEngine*)engine;

-(void) appendBuffer:(NSString*)string;

-(void) deleteBackward;

-(void) reset;

-(BOOL) setSelectedIndex:(NSUInteger)index;

// Advance to next page
// @return YES if no next page, where the current page will reset to 0
-(BOOL) nextPage;

// Back to previous page
// @return YES if no previous page, where the current page will reset to last page
-(BOOL) previousPage;

-(NSString*) inputBuffer;

-(NSString*) marker;

-(NSArray*) candidates;

-(NSString*) composedString;

@end
