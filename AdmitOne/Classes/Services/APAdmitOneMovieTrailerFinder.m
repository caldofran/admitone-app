//
//  APAdmitOneMovieTrailerFinder.m
//  AdmitOne
//
//  Created by Anthony Plourde on 2013-05-04.
//  Copyright (c) 2013 Anthony Plourde. All rights reserved.
//

#import "APAdmitOneMovieTrailerFinder.h"
#import "APMovie.h"
#import "Constants.h"

@implementation APAdmitOneMovieTrailerFinder

static APAdmitOneMovieTrailerFinder *sharedInstance = nil;

+ (APAdmitOneMovieTrailerFinder *)sharedInstance {
    
    @synchronized ([APAdmitOneMovieTrailerFinder class]) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (id)init {
    
    if ((self = [super init])) {
        _acceptHeader = @"text/plain";
    }
    return self;
}


- (void)completeTrailerInfo:(APMovie *)movie {
    
    //getting the themobiedb id for that movie
    //trying to get with the imdb id
    NSString *imdbId = [@"tt" stringByAppendingString:movie.imdbId];
    NSString *title = [movie.title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *urlString = [kAdmitOneApiEndPoint stringByAppendingFormat:kAdmitOneApiResourceTrailer, title, imdbId];
    
    NSString *youtubeTrailer = [(id) [self performActionRequestToURL:[NSURL URLWithString:urlString] usingCache:TRUE withMethod:@"GET" body:nil response:nil andError:nil] objectForKey:@"data"];
    
    if (youtubeTrailer != nil) {
        movie.youtubeTrailer = [NSString stringWithString:youtubeTrailer];
    }
}

@end
