//
//  APMovieDetailsViewController.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <Quartz/Quartz.h>

@class APMovie;

@interface APMovieDetailsViewController : NSViewController{
@private
    APMovie *_movie;
    
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
    
    NSInteger _webviewReceiveCount;
    
    
}

-(void)updateViewWithMovie:(APMovie*)movie;

-(IBAction)watchTrailer:(id)sender;
-(IBAction)download:(id)sender;
-(IBAction)closeTrailer:(id)sender;
-(IBAction)languageSelect:(id)sender;
-(IBAction)qualitySelect:(id)sender;

@end
