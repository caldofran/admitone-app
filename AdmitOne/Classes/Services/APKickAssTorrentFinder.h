//
//  APKickAssTorrentFinder.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-14.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APMovieTorrentFinder.h"

@interface APKickAssTorrentFinder : APMovieTorrentFinder <APMovieTorrentFinderProtocol>

+ (APKickAssTorrentFinder*) sharedInstance;

@end