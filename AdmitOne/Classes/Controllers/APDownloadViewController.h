//
//  APDownloadViewController.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-09.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APDownloadViewController : NSViewController <NSTableViewDelegate,NSTableViewDataSource>{
@private
    IBOutlet NSTableView *_tableView;
}

-(void)refresh;
-(IBAction)revealInFinder:(id)sender;
-(IBAction)togglePauseResume:(id)sender;
-(IBAction)removeSelected:(id)sender;
-(IBAction)clearFinished:(id)sender;

@end
