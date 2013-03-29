//
//  APMainWindowContentView.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Edovia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APMainWindowContentView : NSView{
    NSColor *startingColor;
    NSColor *endingColor;
    int angle;
}
@property(nonatomic, retain) NSColor *startingColor;
@property(nonatomic, retain) NSColor *endingColor;
@property(assign) int angle;

@end
