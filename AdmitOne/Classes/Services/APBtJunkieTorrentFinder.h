//
//  APBtJunkieTorrentFinder.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-14.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "HTTPRequestor.h"
#import "APMovieTorrentFinder.h"

@interface APBtJunkieTorrentFinder : APMovieTorrentFinder <APMovieTorrentFinderProtocol>

+ (APBtJunkieTorrentFinder*) sharedInstance;

@end
