//
//  NSButton+LinkLike.m
//  AdmitOne
//
//  Created by Anthony Plourde on 2013-03-29.
//  Copyright (c) 2013 Anthony Plourde. All rights reserved.
//

#import "NSButton+LinkLike.h"

@implementation NSButton (LinkLike)

- (void)resetCursorRects {
    [super resetCursorRects];
    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

@end
