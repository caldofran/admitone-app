//
//  AppDelegate.h
//  AdmitOne
//
//  Created by Anthony Plourde on 11-12-22.
//  Copyright (c) 2012 Anthony Plourde.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import <GAJavaScriptTracker/GAJavaScriptTracker.h>

#import "SCEventListenerProtocol.h"

@class APMainViewController;
@class APMovieDetailsViewController;
@class APDownloadViewController;
@class APPreferencesWindowController;
@class APMovie;
@class SCEvents;

@interface AppDelegate : NSObject <NSApplicationDelegate, SCEventListenerProtocol> {

    APMainViewController *_mainViewController;
    APMovieDetailsViewController *_detailsViewController;
    APDownloadViewController *_downloadViewController;
    APPreferencesWindowController *_preferencesWindowController;

    GAJavaScriptTracker *_tracker;
    SCEvents *_directoryEvents;

    IBOutlet NSButton *_topRentalsSectionButton;
    IBOutlet NSButton *_currentReleasesSectionButton;
    IBOutlet NSButton *_newReleasesSectionButton;
    IBOutlet NSButton *_backButton;
    IBOutlet NSButton *_downloadPopoverButton;
    IBOutlet NSPopover *_downloadPopover;
    IBOutlet NSSearchField *_searchField;
    IBOutlet NSWindow *_window;
}

@property(assign) IBOutlet NSWindow *window;

- (void)showMovieDetails:(APMovie *)movie;

- (IBAction)showPreferences:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)showTopRentals:(id)sender;

- (IBAction)showNewReleases:(id)sender;

- (IBAction)showCurrentReleases:(id)sender;

- (IBAction)showDownloads:(id)sender;

- (IBAction)search:(id)sender;

@end
