//
//  APMovieDatasourceFetcher.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequestor.h"

@class APMovie;

@interface APMovieDatasourceFetcher : HTTPRequestor{
@private
    
}

+ (APMovieDatasourceFetcher*) sharedInstance;

- (NSArray*) topRentals:(NSInteger)limit;
- (NSArray*) currentReleases:(NSInteger)limit;
- (NSArray*) newReleases:(NSInteger)limit;
- (NSArray*) searchMoviesWithKeywords:(NSString*)keywords;
- (void) completeTrailerInfo:(APMovie*)movie;

@end
