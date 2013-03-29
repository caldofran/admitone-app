//
//  TorrentReactorTorrentFinder.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-06-23.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "HTTPRequestor.h"
#import "APMovieTorrentFinder.h"

@interface APReactorTorrentFinder : APMovieTorrentFinder <APMovieTorrentFinderProtocol>

+ (APReactorTorrentFinder*) sharedInstance;

@end
