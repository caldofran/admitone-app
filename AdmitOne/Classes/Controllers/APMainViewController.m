//
//  APMainWindowController.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Edovia. All rights reserved.
//

#import "APMainViewController.h"
#import "APMovieDatasourceFetcher.h"

@implementation APMainViewController

@synthesize topRentals = _topRentals,
            currentReleases = _currentReleases,
            newReleases = _newReleases;

-(void)awakeFromNib{

    [_loadingView setHidden:YES];
    
    self.topRentals = [[APMovieDatasourceFetcher sharedInstance] topRentals:50];
    self.currentReleases = [[APMovieDatasourceFetcher sharedInstance] currentReleases:50];
    self.newReleases = [[APMovieDatasourceFetcher sharedInstance] newReleases:50];
    
    [_collectionView setContent:self.topRentals];
}

-(void)showTopRentals{
    _titleContent.stringValue = @"Top DVD Rentals";
    [_collectionView setContent:self.topRentals];
}

-(void)showCurrentReleases{
    _titleContent.stringValue = @"Current DVD Releases";
    [_collectionView setContent:self.currentReleases];
}

-(void)showNewReleases{
    _titleContent.stringValue = @"New DVD Releases";
    [_collectionView setContent:self.newReleases];
}

-(void)showSearchForKeyWord:(NSString*)keywords sender:(id)sender{
    [_loadingView setHidden:NO];
    _titleContent.stringValue = [NSString stringWithFormat:@"Searching for \"%@\"...",keywords];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *searchResult = [[APMovieDatasourceFetcher sharedInstance]searchMoviesWithKeywords:keywords];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([keywords isEqualToString:[sender stringValue]]) {
                _titleContent.stringValue = [NSString stringWithFormat:@"%d movie(s) found for \"%@\"",[searchResult count],keywords];
                [_collectionView setContent:searchResult];
                [_loadingView setHidden:YES];
            }
        });
    });
}

@end
