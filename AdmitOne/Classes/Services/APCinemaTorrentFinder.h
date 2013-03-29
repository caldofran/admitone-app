//
//  APCinemaTorrentsFetcher.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-12.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "HTTPRequestor.h"
#import "APMovieTorrentFinder.h"

@interface APCinemaTorrentFinder : APMovieTorrentFinder <APMovieTorrentFinderProtocol>

+ (APCinemaTorrentFinder*) sharedInstance;


@end
