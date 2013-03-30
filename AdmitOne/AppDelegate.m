//
//  AppDelegate.m
//  AdmitOne
//
//  Created by Anthony Plourde on 11-12-22.
//  Copyright (c) 2011 Anthony Plourde. All rights reserved.
//

#import "AppDelegate.h"
#import "APPreferencesWindowController.h"
#import "APMovieDatasourceFetcher.h"
#import "APMainViewController.h"
#import "APMovieDetailsViewController.h"
#import "APDownloadViewController.h"
#import "APMovie.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "APTorrentList.h"
#import "Torrent.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile:
                                                              [[NSBundle mainBundle] pathForResource: @"Defaults" ofType: @"plist"]]];
    
    [self loadDefaultSettings];
    
    _mainViewController = [[APMainViewController alloc]initWithNibName:@"APMoviesMainView" bundle:nil];
    _detailsViewController = [[APMovieDetailsViewController alloc]initWithNibName:@"APMovieDetailsView" bundle:nil];
    _downloadViewController = [[APDownloadViewController alloc]initWithNibName:@"APDownloadView" bundle:nil];
    
    [self.window.contentView addSubview:_mainViewController.view];
    [self.window.contentView addSubview:_detailsViewController.view];
    
    [_mainViewController.view setFrame:[self.window.contentView frame]];
    [_detailsViewController.view setFrame:[self.window.contentView frame]];

    [self showTopRentals:nil];
    
    //creating "Application Support/AdmitOne/Torrents" directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *torrentFilesDirectory =  [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/Temp"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:torrentFilesDirectory]) {
        [fm createDirectoryAtPath:torrentFilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *externalTorrentFilesDirectory =  [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/OpenWithSystemApp"];
    fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:externalTorrentFilesDirectory]) {
        [fm createDirectoryAtPath:externalTorrentFilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //listening "Application Support/AdmitOne/Temp" directory
    SCEvents *events = [SCEvents new];
    [events setDelegate:self];
    [events startWatchingPaths:[NSArray arrayWithObject:torrentFilesDirectory]];

    //load torrents in list
    [[APTorrentList sharedInstance] addTorrentsAtPaths:[fm contentsOfDirectoryAtPath:torrentFilesDirectory error:nil]];
    
    //GoogleAnalytics
    _tracker = [GAJavaScriptTracker trackerWithAccountID:@"UA-28515259-1"];
    if(!_tracker.isRunning) {
        [_tracker start];
    }
    [_tracker trackEvent:@"AdmitOne Mac App" action:@"launched" label:@"AdmitOne Mac App Launched" value:-1 withError:nil];
    
    //refresh badge on dock icon every 2 seconds
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshApplicationBadgeLabel) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    if(_tracker.isRunning) {
        [_tracker stop];
    }
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    [self.window makeKeyAndOrderFront:nil];
    return YES;
}

-(void)showMovieDetails:(APMovie*)movie{
    [_mainViewController.view setHidden:YES];
    [_detailsViewController.view setHidden:NO];
    [_detailsViewController updateViewWithMovie:movie];
    [_backButton setHidden:NO];
}

#pragma mark - IBActions - 

-(IBAction)back:(id)sender{
    if ([_topRentalsSectionButton state]) {
        [self showTopRentals:nil];
    }
    else if ([_currentReleasesSectionButton state]) {
        [self showCurrentReleases:nil];
    }
    else if ([_newReleasesSectionButton state]) {
        [self showNewReleases:nil];
    }
    else{
        [self search:nil];
    }
}

-(IBAction)showTopRentals:(id)sender{
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

-(IBAction)showCurrentReleases:(id)sender{
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
-(IBAction)showNewReleases:(id)sender{
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

-(IBAction)showDownloads:(id)sender{
    [_downloadPopover showRelativeToRect:[_downloadPopoverButton frame] ofView:_downloadPopoverButton preferredEdge:NSMinYEdge];
    [_downloadViewController refresh];
}

-(IBAction)search:(id)sender{
//    [NSThread cancelPreviousPerformRequestsWithTarget:_mainViewController];
    [_detailsViewController closeTrailer:nil];
    [_mainViewController.view setHidden:NO];
    [_detailsViewController.view setHidden:YES];
    
    [_topRentalsSectionButton setState:0];
    [_currentReleasesSectionButton setState:0];
    [_newReleasesSectionButton setState:0];
    [_backButton setHidden:YES];
//    [_mainViewController performSelectorInBackground:@selector(showSearchForKeyWord:) withObject:[_searchField stringValue]];
    [_mainViewController showSearchForKeyWord:[_searchField stringValue] sender:sender];
}

-(IBAction)showPreferences:(id)sender{
    if(!_preferencesWindowController){
        _preferencesWindowController = [[APPreferencesWindowController alloc]initWithWindowNibName:@"APPreferences"];
    }
    [[_preferencesWindowController window] makeKeyAndOrderFront:nil];
}

#pragma mark - SCEventListenerProtocol Methods -

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event{
    
//    NSLog(@"Change Occured : %@",event);
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory =  [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/Temp"];
    NSMutableArray *fileList = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:applicationSupportDirectory error:nil]];
    
    //first remove all non .torrent files
    NSIndexSet *nonTorrentFiles = [fileList indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ![obj hasSuffix:@".torrent"];
    }];
    [fileList removeObjectsAtIndexes:nonTorrentFiles];
    
    //indexes of fileList that need to be added to APTorrentList
    NSIndexSet *newIndexes = [fileList indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL isNew = YES;
        for (Torrent *t in [[APTorrentList sharedInstance]list]) {
            if([obj isEqualToString:[[t originalFilename]lastPathComponent]]){
                isNew = NO;
                break;
            }
        }
        if (isNew) {
//            NSLog(@"Adding torrent : %@",obj);
        }
        return isNew;
    }];
    
    //indexes of APTorrentList that need to be remove because they are not in the folder anymore
    NSIndexSet *removedIndexes = [[[APTorrentList sharedInstance]list] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL isOld = YES;
        for (NSString *s in fileList) {
            if ([s isEqualToString:[[(Torrent*)obj originalFilename]lastPathComponent]]) {
                isOld = NO;
                break;
            }
        }
        if (isOld) {
//            NSLog(@"Removing torrent : %@",[[(Torrent*)obj originalFilename]lastPathComponent]);
        }
        return isOld;
    }];


    if ([removedIndexes count]>0) {
        [[[APTorrentList sharedInstance]list]removeObjectsAtIndexes:removedIndexes];
        [_downloadViewController refresh];
    }
    if ([newIndexes count]>0) {
        [[APTorrentList sharedInstance]addTorrentsAtPaths:[fileList objectsAtIndexes:newIndexes]];
        [_downloadViewController refresh];
    }
    
}

- (void)loadDefaultSettings{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if(![settings objectForKey:kAPDownloadFolder]){
        [settings setObject:kAPDownloadFolderDefault forKey:kAPDownloadFolder];
    }
    if(![settings objectForKey:kAPUseSystemAppToDownload]){
        [settings setObject:kAPUseSystemAppToDownloadDefault forKey:kAPUseSystemAppToDownload];
    }
    
}

- (void)refreshApplicationBadgeLabel{
    
    CGFloat sizeTotal = 0;
    CGFloat doneTotal = 0;
    int torrentCount = [[[APTorrentList sharedInstance]list] count];
    for (Torrent *torrent in [[APTorrentList sharedInstance]list]) {
        doneTotal += [torrent downloadedTotal];
        sizeTotal += [torrent size];
    }
    CGFloat totalProgress = doneTotal / sizeTotal * 100.0;
    
    NSString * badgeLabel = @"";
    if(torrentCount>0)
        badgeLabel = [NSString stringWithFormat:@"%d%%",(int)totalProgress];
    
    [[[NSApplication sharedApplication] dockTile]setBadgeLabel:badgeLabel];
}


@end
