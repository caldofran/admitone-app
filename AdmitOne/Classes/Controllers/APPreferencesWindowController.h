//
//  PreferencesWindowController.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-06-23.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APPreferencesWindowController : NSWindowController{
@private
    IBOutlet NSPopUpButton *_downloadFolderPopupButton;
    IBOutlet NSMatrix *_torrentDownloaderApp;
}

- (IBAction)browseDownloadLocation:(id)sender;;
- (IBAction)selectTorrentDownloaderApp:(id)sender;;

@end
