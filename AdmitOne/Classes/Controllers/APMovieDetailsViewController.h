//
//  APMovieDetailsViewController.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
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
#import <WebKit/WebKit.h>
#import <Quartz/Quartz.h>

@class APMovie;

@interface APMovieDetailsViewController : NSViewController {

@private

    APMovie *_movie;

    NSInteger _webviewReceiveCount;

    IBOutlet NSTextField *_movieTitle;
    IBOutlet NSTextField *_mpaaRating;
    IBOutlet NSTextField *_runtime;
    IBOutlet NSTextField *_criticsRatingText;
    IBOutlet NSTextField *_audienceRatingText;

    IBOutlet NSImageView *_dvdCover;
    IBOutlet NSImageView *_criticsRatingImage;
    IBOutlet NSImageView *_audienceRatingImage;

    IBOutlet NSTextView *_synopsis;
    IBOutlet NSTextView *_criticsReview;

    IBOutlet NSView *_trailerView;
    IBOutlet WebView *_trailerWebView;

    IBOutlet NSButton *_trailerButton;
    IBOutlet NSButton *_downloadButton;
    IBOutlet NSProgressIndicator *_trailerSearching;
    IBOutlet NSProgressIndicator *_downloadSearching;

    IBOutlet NSPopUpButton *_languagePopup;
    IBOutlet NSSegmentedControl *_hdSwitch;

}

- (void)updateViewWithMovie:(APMovie *)movie;

- (IBAction)watchTrailer:(id)sender;

- (IBAction)download:(id)sender;

- (IBAction)closeTrailer:(id)sender;

- (IBAction)languageSelect:(id)sender;

- (IBAction)qualitySelect:(id)sender;

@end
