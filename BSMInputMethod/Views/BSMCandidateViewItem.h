//
//  BSMCandidateViewItem.h
//  BSMInputMethod
//
//  Created by Chong Francis on 13年5月11日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JAListViewItem.h"

@interface BSMCandidateViewItem : JAListViewItem

@property (weak, nonatomic) IBOutlet NSTextField* numberText;
@property (weak, nonatomic) IBOutlet NSTextField* wordText;
@property (weak, nonatomic) IBOutlet NSTextField* codeText;

+(BSMCandidateViewItem*) itemWithOwner:(id)owner;

-(void) setNumber:(NSUInteger)number word:(NSString*)word code:(NSString*)code;

@end
