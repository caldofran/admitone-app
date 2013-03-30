//
//  AppDelegate.h
//  AdmitOne
//
//  Created by Anthony Plourde on 11-12-22.
//  Copyright (c) 2011 Anthony Plourde. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GAJavaScriptTracker/GAJavaScriptTracker.h>

#import "SCEventListenerProtocol.h"

@class APMainViewController;
@class APMovieDetailsViewController;
@class APDownloadViewController;
@class APPreferencesWindowController;
@class APMovie;

@interface AppDelegate : NSObject <NSApplicationDelegate, SCEventListenerProtocol>{
    
    APMainViewController *_mainViewController;
    APMovieDetailsViewController *_detailsViewController;
    APDownloadViewController *_downloadViewController;
    APPreferencesWindowController *_preferencesWindowController;
    
    GAJavaScriptTracker *_tracker;
    
    IBOutlet NSButton *_topRentalsSectionButton;
    IBOutlet NSButton *_currentReleasesSectionButton;
    IBOutlet NSButton *_newReleasesSectionButton;
    IBOutlet NSButton *_backButton;
    IBOutlet NSButton *_downloadPopoverButton;
    IBOutlet NSPopover *_downloadPopover;
    IBOutlet NSSearchField *_searchField;
}

@property (assign) IBOutlet NSWindow *window;

-(void)showMovieDetails:(APMovie*)movie;
-(void)refreshApplicationBadgeLabel;
-(void)loadDefaultSettings;

-(IBAction)showPreferences:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)showTopRentals:(id)sender;
-(IBAction)showNewReleases:(id)sender;
-(IBAction)showCurrentReleases:(id)sender;
-(IBAction)showDownloads:(id)sender;
-(IBAction)search:(id)sender;

@end
