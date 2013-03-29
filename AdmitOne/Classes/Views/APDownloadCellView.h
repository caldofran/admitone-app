//
//  APDownloadCellView.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-09.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface APDownloadCellView : NSTableCellView{
@private
    IBOutlet NSButton *revealButton;
    IBOutlet NSButton *actionButton;
    IBOutlet NSProgressIndicator *progressBar;
    IBOutlet NSTextField *detailField;
    IBOutlet NSTextField *statusField;
}

@property (nonatomic,retain) NSButton *revealButton;
@property (nonatomic,retain) NSButton *actionButton;
@property (nonatomic,retain) NSProgressIndicator *progressBar;
@property (nonatomic,retain) NSTextField *detailField;
@property (nonatomic,retain) NSTextField *statusField;

@end
