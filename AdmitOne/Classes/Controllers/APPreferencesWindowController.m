//
//  PreferencesWindowController.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-06-23.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APPreferencesWindowController.h"
#import "Constants.h"

@implementation APPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)refreshValues{
    
    NSString *downloadFolder = [[[NSUserDefaults standardUserDefaults]objectForKey:kAPDownloadFolder] stringByExpandingTildeInPath];
    NSString *folderName = [downloadFolder lastPathComponent];
    NSImage *folderIcon = [[NSWorkspace sharedWorkspace]iconForFile:downloadFolder];
    [folderIcon setScalesWhenResized:YES];
    [folderIcon setSize:NSMakeSize([_downloadFolderPopupButton frame].size.height, [_downloadFolderPopupButton frame].size.height)];
    [[[_downloadFolderPopupButton itemArray]objectAtIndex:0] setTitle:folderName];
    [[[_downloadFolderPopupButton itemArray]objectAtIndex:0] setImage:folderIcon];
    [_downloadFolderPopupButton selectItemAtIndex:0];
    
    BOOL useSystemDefaultApp = [[[NSUserDefaults standardUserDefaults]objectForKey:kAPUseSystemAppToDownload] boolValue];
    if (useSystemDefaultApp) {
        [_torrentDownloaderApp selectCellAtRow:1 column:0];
    }
    else{
        [_torrentDownloaderApp selectCellAtRow:0 column:0];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self refreshValues];
    
}

- (IBAction)browseDownloadLocation:(id)sender;{
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *folderPath = [[panel URL] path];
            [[NSUserDefaults standardUserDefaults]setObject:folderPath forKey:kAPDownloadFolder];
            [self refreshValues];
        }
    }];
}

- (IBAction)selectTorrentDownloaderApp:(id)sender;{
    NSMatrix *matrix = sender;
    BOOL useSystemDefaultApp = [matrix selectedRow] == 1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:useSystemDefaultApp] forKey:kAPUseSystemAppToDownload];
}

@end
