//
//  APMainViewController.h
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
#import <Quartz/Quartz.h>

@interface APMainViewController : NSViewController <NSCollectionViewDelegate> {

@private
    NSArray *_topRentals;
    NSArray *_currentReleases;
    NSArray *_newReleases;

    IBOutlet NSCollectionView *_collectionView;
    IBOutlet NSView *_loadingView;
    IBOutlet NSTextField *_titleContent;
}

@property(nonatomic, retain) NSArray *topRentals;
@property(nonatomic, retain) NSArray *currentReleases;
@property(nonatomic, retain) NSArray *newReleases;

- (void)showTopRentals;

- (void)showCurrentReleases;

- (void)showNewReleases;

- (void)showSearchForKeyWord:(NSString *)keywords sender:(id)sender;

@end
