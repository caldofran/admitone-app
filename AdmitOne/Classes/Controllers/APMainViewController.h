//
//  APMainViewController.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Edovia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface APMainViewController : NSViewController <NSCollectionViewDelegate>{
@private
    NSArray *_topRentals;
    NSArray *_currentReleases;
    NSArray *_newReleases;
    
    IBOutlet NSCollectionView *_collectionView;
    IBOutlet NSView *_loadingView;
    IBOutlet NSTextField *_titleContent;
    
}

@property (nonatomic,retain) NSArray *topRentals;
@property (nonatomic,retain) NSArray *currentReleases;
@property (nonatomic,retain) NSArray *newReleases;

-(void)showTopRentals;
-(void)showCurrentReleases;
-(void)showNewReleases;
-(void)showSearchForKeyWord:(NSString*)keywords sender:(id)sender;

@end
