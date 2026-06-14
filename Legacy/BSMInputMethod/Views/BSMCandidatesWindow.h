//
//  BSMCandidatesWindow.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JAListView.h"
#import "BSMView.h"

@interface BSMCandidatesWindow : NSWindow <JAListViewDataSource>

@property (strong, nonatomic) NSArray* candidates;

@property (assign, nonatomic) BOOL isShowingCandidatesCode;
@property (weak, nonatomic) IBOutlet BSMView* view;
@property (weak, nonatomic) IBOutlet JAListView* listView;

-(void) updateCandidates:(NSArray*)candidates;

-(void) showCandidates;

-(void) hideCandidates;

-(void) showCandidatesCode;

-(void) hideCandidatesCode;

-(void) setWindowTopLeftPoint:(NSPoint)topLeftPoint bottomOutOfScreenAdjustmentHeight:(CGFloat)height;

@end
