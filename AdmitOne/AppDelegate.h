//
//  AppDelegate.h
//  AdmitOne
//
//  Created by Anthony Plourde on 11-12-22.
//  Copyright (c) 2011 Anthony Plourde. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"

@class APMainViewController;
@class APMovieDetailsViewController;
@class APDownloadViewController;
@class APMovie;
@class APPreferencesWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate, SCEventListenerProtocol>{
    APMainViewController *_mainViewController;
    APMovieDetailsViewController *_detailsViewController;
    APDownloadViewController *_downloadViewController;
    APPreferencesWindowController *_preferencesWindow;
    
    IBOutlet NSButton *_topRentals;
    IBOutlet NSButton *_currentReleases;
    IBOutlet NSButton *_newReleases;
    IBOutlet NSButton *_back;
    IBOutlet NSButton *_downloadPopoverButton;
    IBOutlet NSPopover *_downloadPopover;
    IBOutlet NSSearchField *_searchField;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)showPreferences:(id)sender;
-(void)showMovieDetails:(APMovie*)movie;
-(void)refreshApplicationBadgeLabel;
-(void)loadDefaultSettings;
-(IBAction)back:(id)sender;
-(IBAction)showTopRentals:(id)sender;
-(IBAction)showNewReleases:(id)sender;
-(IBAction)showCurrentReleases:(id)sender;
-(IBAction)showDownloads:(id)sender;
-(IBAction)search:(id)sender;

@end
