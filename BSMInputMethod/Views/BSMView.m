//
//  BSMView.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMView.h"

@implementation BSMView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [NSColor whiteColor];
    }
    return self;
}

-(void) setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
