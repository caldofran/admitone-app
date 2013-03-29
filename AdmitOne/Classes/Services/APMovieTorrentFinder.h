//
//  APMovieTorrentFinder.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-13.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequestor.h"

@class APMovie;

@protocol APMovieTorrentFinderProtocol <NSObject>
- (NSArray*)findTorrentsForMovie:(APMovie*)movie;
@end

@interface APMovieTorrentFinder : HTTPRequestor {
@private
    
}

- (NSDictionary*)performActionRequestToURL:(NSURL*)url withMethod:(NSString*)method body:(NSString*)body response:(NSURLResponse**)response andError:(NSError**)error;
- (NSString*)normalizeKeywordsForMovie:(APMovie*)movie escapingSpaces:(BOOL)escapeSpaces;
- (BOOL)isTorrentTitle:(NSString*)title andSize:(NSInteger)size matchingMovie:(APMovie*)movie;
@end