//
//  APDownloadViewController.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-09.
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

#import "APDownloadViewController.h"
#import "APDownloadCellView.h"
#import "Torrent.h"
#import "FileListNode.h"
#import "APTorrentList.h"

@implementation APDownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }

    return self;
}

#pragma mark - Private Methods -


#pragma - Public Methods -

- (void) awakeFromNib{
    [NSTimer scheduledTimerWithTimeInterval:2 target:_tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
}

- (void) refresh{
    [_tableView reloadData];
}

#pragma mark - IBActions -

-(IBAction)revealInFinder:(id)sender{
    NSInteger index = [[_tableView subviews] indexOfObject:[[sender superview]superview]];
    Torrent *currentTorrent = [[[APTorrentList sharedInstance]list]objectAtIndex:index];

    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: [NSArray arrayWithObject:[NSURL fileURLWithPath:[currentTorrent dataLocation]]]];

}

-(IBAction)togglePauseResume:(id)sender{
    NSInteger index = [[_tableView subviews] indexOfObject:[[sender superview]superview]];
    Torrent *currentTorrent = [[[APTorrentList sharedInstance]list]objectAtIndex:index];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([currentTorrent isActive]) {
        [sender setImage:[NSImage imageNamed:@"DownloadResume.tif"]];
        [[(APDownloadCellView*)[sender superview] progressBar] stopAnimation:nil];
        [ud setBool:NO forKey:[NSString stringWithFormat:@"IsActive - %@",[currentTorrent name]]];

        if([currentTorrent waitingToStart])//if waiting to start, we need to call it twice
            [currentTorrent stopTransfer];
        [currentTorrent stopTransfer];

    }
    else{
        [sender setImage:[NSImage imageNamed:@"DownloadStop.tif"]];
        [[(APDownloadCellView*)[sender superview] progressBar] startAnimation:nil];
        [ud setBool:YES forKey:[NSString stringWithFormat:@"IsActive - %@",[currentTorrent name]]];

        [currentTorrent startTransfer];
    }
}

-(IBAction)removeSelected:(id)sender{
    NSInteger index = [[_tableView subviews] indexOfObject:[[sender superview]superview]];
    Torrent *t = [[[APTorrentList sharedInstance]list]objectAtIndex:index];

    BOOL removeData = NO;
    if (![t isComplete]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Do you also want to delete incomplete movie data associated to that download ?" defaultButton:@"No" alternateButton:@"Yes" otherButton:nil informativeTextWithFormat:@"Data will be lost. This cannot be undone."];
        removeData = [alert runModal]==NSAlertAlternateReturn;
    }

    if ([t isActive]) {
        if ([t waitingToStart]) {
            [t stopTransfer];
        }
        [t closeRemoveTorrent:removeData];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[t originalFilename] error:nil];
}

-(IBAction)clearFinished:(id)sender{
    NSMutableArray *pathsToRemove = [NSMutableArray array];
    for (Torrent *t in [[APTorrentList sharedInstance]list]) {
        if ([t isComplete]) {
            [pathsToRemove addObject:[t torrentLocation]];
            [pathsToRemove addObject:[t originalFilename]];
            if ([t isActive]) {
                if ([t waitingToStart]) {
                    [t stopTransfer];
                }
                [t stopTransfer];
            }
        }
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *path in pathsToRemove) {

        [fm removeItemAtPath:path error:nil];
    }
}

#pragma mark - NSTableView Delegate and Datasource Methods -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [[[APTorrentList sharedInstance] list] count];
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{

    Torrent *currentTorrent = [[[APTorrentList sharedInstance] list]objectAtIndex:row];

    APDownloadCellView *cell = nil;
    if ([[tableView subviews] count]>row && [[[tableView subviews] objectAtIndex:row] isKindOfClass:[APDownloadCellView class]]) {
        cell = [[tableView subviews] objectAtIndex:row];
    }
    else{
        cell = [tableView makeViewWithIdentifier:@"DownloadCell" owner:self];
    }

    CGFloat previousProgress = [cell.progressBar doubleValue];
    BOOL wasDone = previousProgress == 100.0;
    [currentTorrent update];
    CGFloat newProgress = [currentTorrent progressDone];
    BOOL isDone = newProgress == 100.0;

    if(!wasDone && isDone){
        NSSound *sound = [NSSound soundNamed:@"Glass.aiff"];
        [sound play];
        [[NSApplication sharedApplication] requestUserAttention:NSCriticalRequest];
    }

    cell.textField.stringValue = [currentTorrent name];
    cell.imageView.image = [currentTorrent icon];

    if ([currentTorrent isActive]) {
        [cell.actionButton setImage:[NSImage imageNamed:@"DownloadStop.tif"]];
    }
    else{
        [cell.actionButton setImage:[NSImage imageNamed:@"DownloadResume.tif"]];
    }
    [cell.progressBar setDoubleValue:[currentTorrent progressDone]];
    [cell.progressBar displayIfNeeded];

    cell.detailField.stringValue = [currentTorrent progressString];
    cell.statusField.stringValue = [currentTorrent statusString];


    return cell;
}

@end
