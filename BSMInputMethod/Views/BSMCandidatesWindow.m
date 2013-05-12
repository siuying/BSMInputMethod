//
//  BSMCandidatesWindow.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>

#import "BSMCandidatesWindow.h"
#import "BSMCandidateViewItem.h"
#import "DDLog.h"
#import "BSMMatch.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define kCandidateWindowWidthWithoutCode 50
#define kCandidateWindowWidthWithCode 120

@implementation BSMCandidatesWindow

-(void) awakeFromNib {
    [super awakeFromNib];
    [self setLevel:NSPopUpMenuWindowLevel];
    
    self.view.backgroundColor = [NSColor whiteColor];
    self.listView.backgroundColor = [NSColor whiteColor];
}

#pragma mark - Public

-(void) updateCandidates:(NSArray*)candidates {
    DDLogVerbose(@"update candidates: %lu", [candidates count]);
    self.candidates = [candidates copy];
    [self.listView reloadData];
}

-(void) showCandidates {
    DDLogVerbose(@"will show candidates");
    [self makeKeyAndOrderFront:self];
}

-(void) hideCandidates {
    DDLogVerbose(@"will hide candidates");
    [self close];
}

-(void) showCandidatesCode {
    DDLogInfo(@"will show candidate code");
    if (!_isShowingCandidatesCode) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[self animator] setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, kCandidateWindowWidthWithCode, self.frame.size.height) display:YES];
        [NSAnimationContext endGrouping];
        _isShowingCandidatesCode = YES;
    }
}

-(void) hideCandidatesCode {
    DDLogInfo(@"will show candidate code");
    if (_isShowingCandidatesCode) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[self animator] setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, kCandidateWindowWidthWithoutCode, self.frame.size.height) display:YES];
        [NSAnimationContext endGrouping];
        _isShowingCandidatesCode = NO;
    }
}

- (void)setWindowTopLeftPoint:(NSPoint)topLeftPoint bottomOutOfScreenAdjustmentHeight:(CGFloat)height {
    NSPoint adjustedPoint = topLeftPoint;
    CGFloat adjustedHeight = height;
    
    // first, locate the screen the point is in
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
    
    for (NSScreen *screen in [NSScreen screens]) {
        NSRect frame = [screen visibleFrame];
        if (topLeftPoint.x >= NSMinX(frame) && topLeftPoint.x <= NSMaxX(frame)) {
            screenFrame = frame;
            break;
        }
    }
    
    // make sure we don't have any erratic value
    if (adjustedHeight > screenFrame.size.height / 2.0) {
        adjustedHeight = 0.0;
    }
    
    NSSize windowSize = [self frame].size;
    
    // bottom beneath the screen?
    if (adjustedPoint.y - windowSize.height < NSMinY(screenFrame)) {
        adjustedPoint.y = topLeftPoint.y + adjustedHeight + windowSize.height;
    }
    
    // top over the screen?
    if (adjustedPoint.y >= NSMaxY(screenFrame)) {
        adjustedPoint.y = NSMaxY(screenFrame) - 1.0;
    }
    
    // right
    if (adjustedPoint.x + windowSize.width >= NSMaxX(screenFrame)) {
        adjustedPoint.x = NSMaxX(screenFrame) - windowSize.width;
    }
    
    // left
    if (adjustedPoint.x < NSMinX(screenFrame)) {
        adjustedPoint.x = NSMinX(screenFrame);
    }
    
    [self setFrameTopLeftPoint:adjustedPoint];
}

#pragma mark - JAListViewDataSource

- (NSUInteger)numberOfItemsInListView:(JAListView *)listView {
    return [self.candidates count];
}

- (JAListViewItem *)listView:(JAListView *)listView viewAtIndex:(NSUInteger)index {
    BSMMatch* match = self.candidates[index];
    BSMCandidateViewItem* item = [BSMCandidateViewItem itemWithOwner:self];
    [item setNumber:(index+1) word:match.word code:match.code];
    return item;
}

@end
