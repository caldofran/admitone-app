//
//  APMainWindowController.m
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

#import "APMainViewController.h"
#import "APAdmitOneLatestMoviesFetcher.h"

@implementation APMainViewController

@synthesize topRentals = _topRentals, currentReleases = _currentReleases, newReleases = _newReleases;

- (void)dealloc {

    [_topRentals release];
    [_currentReleases release];
    [_newReleases release];
    [super dealloc];
}

- (void)awakeFromNib {

    [_loadingView setHidden:YES];

    self.topRentals = [[APAdmitOneLatestMoviesFetcher sharedInstance] topRentals:50];
    self.currentReleases = [[APAdmitOneLatestMoviesFetcher sharedInstance] currentReleases:50];
    self.newReleases = [[APAdmitOneLatestMoviesFetcher sharedInstance] newReleases:50];

    [_collectionView setContent:self.topRentals];
}

- (void)showTopRentals {

    _titleContent.stringValue = @"Top DVD Rentals";
    [_collectionView setContent:self.topRentals];
    [_loadingView setHidden:YES];
}

- (void)showCurrentReleases {

    _titleContent.stringValue = @"Current DVD Releases";
    [_collectionView setContent:self.currentReleases];
    [_loadingView setHidden:YES];
}

- (void)showNewReleases {

    _titleContent.stringValue = @"New DVD Releases";
    [_collectionView setContent:self.newReleases];
    [_loadingView setHidden:YES];
}

- (void)showSearchForKeyWord:(NSString *)keywords sender:(id)sender {

    if (sender == nil) {
        return;
    }

    [_loadingView setHidden:NO];
    _titleContent.stringValue = [NSString stringWithFormat:@"Searching for \"%@\"...", keywords];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray *searchResult = [[APAdmitOneLatestMoviesFetcher sharedInstance] searchMoviesWithKeywords:keywords];

        dispatch_async(dispatch_get_main_queue(), ^{

            if ([keywords isEqualToString:[sender stringValue]]) {

                _titleContent.stringValue = [NSString stringWithFormat:@"%lu movie(s) found for \"%@\"", [searchResult count], keywords];
                [_collectionView setContent:searchResult];
                [_loadingView setHidden:YES];
                [CATransaction flush];
            }
        });
    });
}

@end
