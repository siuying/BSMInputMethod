//
//  BSMCandidateViewItem.m
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "BSMCandidateViewItem.h"

@implementation BSMCandidateViewItem

+(BSMCandidateViewItem*) itemWithOwner:(id)owner {
    NSArray *arrayOfViews;
    BOOL wasLoaded = [[NSBundle mainBundle] loadNibNamed:@"BSMCandidateViewItem" owner:owner topLevelObjects:&arrayOfViews];
    NSUInteger viewIndex = [arrayOfViews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[BSMCandidateViewItem class]];
    }];

    if (wasLoaded && viewIndex != NSNotFound) {
        return [arrayOfViews objectAtIndex:viewIndex];
    } else {
        NSAssert(false, @"cannot initialize view item from nib");
        return nil;
    }
}

-(void) setNumber:(NSUInteger)number word:(NSString*)word code:(NSString*)code {
    [self.numberText setStringValue:[[NSNumber numberWithUnsignedInteger:number] stringValue]];
    [self.wordText setStringValue:word];
    [self.codeText setStringValue:code];
}

@end
