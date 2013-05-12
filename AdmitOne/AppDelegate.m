//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "APPreferencesWindowController.h"
#import "APMainViewController.h"
#import "APMovieDetailsViewController.h"
#import "APDownloadViewController.h"
#import "APMovie.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "APTorrentList.h"
#import "Constants.h"
#import "TRTorrent.h"
#import "Reachability.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc {

    [_downloadViewController release];
    [_detailsViewController release];
    [_mainViewController release];
    [_directoryEvents release];
    [_preferencesWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    NSUInteger theFlags = [NSEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    if(theFlags & NSAlternateKeyMask) {
        [self _resetAll];
    }

    [self _checkInternet];
    [self _initializeDefaultSettings];
    [self _initializeMainViews];

    NSString *torrentFilesDirectory = [self _ensureDirectoryInApplicationSupport:@"temp"];
    [self _startWatchingDirectory:torrentFilesDirectory];

    [self _loadTorrentsInDirectory:torrentFilesDirectory];

    [self _startGoogleAnalytics];
}

- (void)applicationWillTerminate:(NSNotification *)notification {

    [self _stopGoogleAnalytics];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {

    [self.window makeKeyAndOrderFront:nil];
    return YES;
}

- (void)showMovieDetails:(APMovie *)movie {

    [_mainViewController.view setHidden:YES];
    [_detailsViewController.view setHidden:NO];
    [_detailsViewController updateViewWithMovie:movie];
    [_backButton setHidden:NO];
}

#pragma mark - IBActions - 

- (IBAction)back:(id)sender {

    if ([_topRentalsSectionButton state]) {
        [self showTopRentals:nil];
    }
    else if ([_currentReleasesSectionButton state]) {
        [self showCurrentReleases:nil];
    }
    else if ([_newReleasesSectionButton state]) {
        [self showNewReleases:nil];
    }
    else {
        [self search:nil];
    }
}

- (IBAction)showTopRentals:(id)sender {

    [_searchField setStringValue:@""];
    [_detailsViewController closeTrailer:nil];
    [_mainViewController.view setHidden:NO];
    [_detailsViewController.view setHidden:YES];

    [_topRentalsSectionButton setState:1];
    [_currentReleasesSectionButton setState:0];
    [_newReleasesSectionButton setState:0];
    [_backButton setHidden:YES];

    [_mainViewController showTopRentals];
}

- (IBAction)showCurrentReleases:(id)sender {

    [_searchField setStringValue:@""];
    [_detailsViewController closeTrailer:nil];
    [_mainViewController.view setHidden:NO];
    [_detailsViewController.view setHidden:YES];

    [_topRentalsSectionButton setState:0];
    [_currentReleasesSectionButton setState:1];
    [_newReleasesSectionButton setState:0];
    [_backButton setHidden:YES];

    [_mainViewController showCurrentReleases];
}

- (IBAction)showNewReleases:(id)sender {

    [_searchField setStringValue:@""];
    [_detailsViewController closeTrailer:nil];
    [_mainViewController.view setHidden:NO];
    [_detailsViewController.view setHidden:YES];

    [_topRentalsSectionButton setState:0];
    [_currentReleasesSectionButton setState:0];
    [_newReleasesSectionButton setState:1];
    [_backButton setHidden:YES];

    [_mainViewController showNewReleases];
}

- (IBAction)showDownloads:(id)sender {

    [_downloadPopover showRelativeToRect:[_downloadPopoverButton frame] ofView:_downloadPopoverButton preferredEdge:NSMinYEdge];
    [_downloadViewController refresh];
}

- (IBAction)search:(id)sender {

    [_detailsViewController closeTrailer:nil];
    [_mainViewController.view setHidden:NO];
    [_detailsViewController.view setHidden:YES];

    [_topRentalsSectionButton setState:0];
    [_currentReleasesSectionButton setState:0];
    [_newReleasesSectionButton setState:0];
    [_backButton setHidden:YES];
    [_mainViewController showSearchForKeyWord:[_searchField stringValue] sender:sender];
}

- (IBAction)showPreferences:(id)sender {

    if (!_preferencesWindowController) {
        _preferencesWindowController = [[APPreferencesWindowController alloc] initWithWindowNibName:@"APPreferences"];
    }
    [[_preferencesWindowController window] makeKeyAndOrderFront:nil];
}

#pragma mark - SCEventListenerProtocol Methods -

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/Temp"];
    NSMutableArray *fileList = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportDirectory error:nil]];

    //first remove all non .torrent files
    NSIndexSet *nonTorrentFiles = [fileList indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ![obj hasSuffix:@".torrent"];
    }];
    [fileList removeObjectsAtIndexes:nonTorrentFiles];

    //indexes of fileList that need to be added to APTorrentList
    NSIndexSet *newIndexes = [fileList indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL isNew = YES;
        for (TRTorrent *t in [[APTorrentList sharedInstance] list]) {
            if ([obj isEqualToString:[[t originalFilename] lastPathComponent]]) {
                isNew = NO;
                break;
            }
        }
        return isNew;
    }];

    //indexes of APTorrentList that need to be remove because they are not in the folder anymore
    NSIndexSet *removedIndexes = [[[APTorrentList sharedInstance] list] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL isOld = YES;
        for (NSString *s in fileList) {
            if ([s isEqualToString:[[(TRTorrent *) obj originalFilename] lastPathComponent]]) {
                isOld = NO;
                break;
            }
        }
        return isOld;
    }];

    if ([removedIndexes count] > 0) {
        [[[APTorrentList sharedInstance] list] removeObjectsAtIndexes:removedIndexes];
        [_downloadViewController refresh];
    }
    if ([newIndexes count] > 0) {
        [[APTorrentList sharedInstance] addTorrentsAtPaths:[fileList objectsAtIndexes:newIndexes]];
        [_downloadViewController refresh];
    }
}

#pragma mark -- Private Methods --

- (void)_startGoogleAnalytics {

    _tracker = [GAJavaScriptTracker trackerWithAccountID:@"UA-28515259-1"];
    if (!_tracker.isRunning) {
        [_tracker start];
    }
    [_tracker trackEvent:@"AdmitOne Mac App" action:@"launched" label:@"AdmitOne Mac App Launched" value:-1 withError:nil];
}

- (void)_stopGoogleAnalytics {
    if (_tracker.isRunning) {
        [_tracker stop];
    }
}

- (void)_loadTorrentsInDirectory:(NSString *)torrentFilesDirectory {

    [[APTorrentList sharedInstance] addTorrentsAtPaths:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:torrentFilesDirectory error:nil]];
}

- (void)_initializeMainViews {

    _mainViewController = [[APMainViewController alloc] initWithNibName:@"APMoviesMainView" bundle:nil];
    _detailsViewController = [[APMovieDetailsViewController alloc] initWithNibName:@"APMovieDetailsView" bundle:nil];
    _downloadViewController = [[APDownloadViewController alloc] initWithNibName:@"APDownloadView" bundle:nil];

    [self.window.contentView addSubview:_mainViewController.view];
    [self.window.contentView addSubview:_detailsViewController.view];

    [_mainViewController.view setFrame:[self.window.contentView frame]];
    [_detailsViewController.view setFrame:[self.window.contentView frame]];

    [self showTopRentals:nil];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(_refreshApplicationBadgeLabel) userInfo:nil repeats:YES];
}

- (NSString *)_ensureDirectoryInApplicationSupport:(NSString *)path {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *torrentFilesDirectory = [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/%@", path];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:torrentFilesDirectory]) {
        [fm createDirectoryAtPath:torrentFilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return torrentFilesDirectory;
}

- (void)_startWatchingDirectory:(NSString *)path {

    if (_directoryEvents == nil) {
        _directoryEvents = [SCEvents new];
        [_directoryEvents setDelegate:self];
    }
    [_directoryEvents startWatchingPaths:[NSArray arrayWithObject:path]];
}

- (void)_initializeDefaultSettings {

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    NSString *transmissionDefaultSettingsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    [settings registerDefaults:[NSDictionary dictionaryWithContentsOfFile:transmissionDefaultSettingsPath]];

    if (![settings objectForKey:kAPDownloadFolder]) {
        [settings setObject:kAPDownloadFolderDefault forKey:kAPDownloadFolder];
    }
    if (![settings objectForKey:kAPUseSystemAppToDownload]) {
        [settings setObject:[NSNumber numberWithBool:kAPUseSystemAppToDownloadDefault] forKey:kAPUseSystemAppToDownload];
    }

}

- (void)_refreshApplicationBadgeLabel {

    CGFloat sizeTotal = 0;
    CGFloat doneTotal = 0;

    int torrentCount = [[[APTorrentList sharedInstance] list] count];
    for (TRTorrent *torrent in [[APTorrentList sharedInstance] list]) {
        doneTotal += [torrent downloadedTotal];
        sizeTotal += [torrent size];
    }
    CGFloat totalProgress = doneTotal / sizeTotal * 100.0;

    NSString *badgeLabel = @"";
    if (torrentCount > 0)
        badgeLabel = [NSString stringWithFormat:@"%d%%", (int) totalProgress];

    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:badgeLabel];
}

- (void)_resetAll {

    NSAlert *alert = [NSAlert alertWithMessageText:@"Reset application data" defaultButton:@"No" alternateButton:@"Yes" otherButton:nil informativeTextWithFormat:@"Starting the application with the Alt/Option modifier key will reset the application data. You might loose incomplete downloads. Are you sure you want to continue ?"];
    BOOL doReset = [alert runModal] == NSAlertAlternateReturn;
    if (doReset) {
        //reseting NSUserDefaults
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [defs dictionaryRepresentation];
        for (id key in dict) {
            [defs removeObjectForKey:key];
        }
        [defs synchronize];
        
        //reseting Application Support data
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne"];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:applicationSupportDirectory error:nil];
    }
}

- (void)_checkInternet {
    
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    if([reach currentReachabilityStatus] == NotReachable) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Unreachable Internet" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"AdmitOne needs an internet connection in order to work. Please make sure you are connected to the internet and launch AdmitOne again."];
        [alert runModal];
        [NSApp terminate: nil];
    }
}


@end
