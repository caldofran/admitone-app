//
//  PreferencesWindowController.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-06-23.
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

#import "APPreferencesWindowController.h"
#import "Constants.h"

@implementation APPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window {

    self = [super initWithWindow:window];
    return self;
}

- (void)windowDidLoad {

    [super windowDidLoad];
    [self _refreshValues];
}

#pragma mark - IBActions -

- (IBAction)browseDownloadLocation:(id)sender {

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *folderPath = [[panel URL] path];
            [[NSUserDefaults standardUserDefaults] setObject:folderPath forKey:kAPDownloadFolder];
            [self _refreshValues];
        }
    }];
}

- (IBAction)selectTorrentDownloaderApp:(id)sender {

    NSMatrix *matrix = sender;
    BOOL useSystemDefaultApp = [matrix selectedRow] == 1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:useSystemDefaultApp] forKey:kAPUseSystemAppToDownload];
}

#pragma mark - Private Methods -

- (void)_refreshValues {

    NSString *downloadFolder = [[[NSUserDefaults standardUserDefaults] objectForKey:kAPDownloadFolder] stringByExpandingTildeInPath];
    NSString *folderName = [downloadFolder lastPathComponent];
    NSImage *folderIcon = [[NSWorkspace sharedWorkspace] iconForFile:downloadFolder];
    [folderIcon setScalesWhenResized:YES];
    [folderIcon setSize:NSMakeSize([_downloadFolderPopupButton frame].size.height, [_downloadFolderPopupButton frame].size.height)];
    [[[_downloadFolderPopupButton itemArray] objectAtIndex:0] setTitle:folderName];
    [[[_downloadFolderPopupButton itemArray] objectAtIndex:0] setImage:folderIcon];
    [_downloadFolderPopupButton selectItemAtIndex:0];

    BOOL useSystemDefaultApp = [[[NSUserDefaults standardUserDefaults] objectForKey:kAPUseSystemAppToDownload] boolValue];
    if (useSystemDefaultApp) {
        [_torrentDownloaderApp selectCellAtRow:1 column:0];
    }
    else {
        [_torrentDownloaderApp selectCellAtRow:0 column:0];
    }
}

@end
