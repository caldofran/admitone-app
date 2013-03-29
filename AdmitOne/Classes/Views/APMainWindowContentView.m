//
//  APMainWindowContentView.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APMainWindowContentView.h"

@implementation APMainWindowContentView

@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setEndingColor:[NSColor colorWithDeviceRed:12.0/255.0 green:13.0/255.0 blue:12.0/255.0 alpha:1.0]];
        [self setStartingColor:[NSColor blackColor]];
        [self setAngle:270];
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    if (endingColor == nil || [startingColor isEqual:endingColor]) {
        // Fill view with a standard background color
        [startingColor set];
        NSRectFill(rect);
    }
    else {
        // Fill view with a top-down gradient
        // from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc]
                                 initWithStartingColor:startingColor
                                 endingColor:endingColor];
        [aGradient drawInRect:[self bounds] angle:angle];
    }
}

@end
