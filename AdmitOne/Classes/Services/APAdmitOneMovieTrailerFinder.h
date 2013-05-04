//
//  APAdmitOneMovieTrailerFinder.h
//  AdmitOne
//
//  Created by Anthony Plourde on 2013-05-04.
//  Copyright (c) 2013 Anthony Plourde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APHTTPRequestServiceSupport.h"

@class APMovie;

@interface APAdmitOneMovieTrailerFinder : APHTTPRequestServiceSupport

+ (APAdmitOneMovieTrailerFinder *)sharedInstance;
- (void)completeTrailerInfo:(APMovie *)movie;

@end
