//
//  APMainWindowContentView.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Edovia. All rights reserved.
//

#import "APMainWindowContentView.h"

@implementation APMainWindowContentView

@synthesize backgroundColor;

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];

    if (self) {
        [self setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"navy_blue.png"]]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {

    dirtyRect = [self bounds];

    [NSGraphicsContext currentContext];
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
}

- (void)dealloc {
    [backgroundColor release];
    [super dealloc];
}

@end
