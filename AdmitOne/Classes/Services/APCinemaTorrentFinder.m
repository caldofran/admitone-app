//
//  APCinemaTorrentsFetcher.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-12.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APCinemaTorrentFinder.h"
#import "APMovie.h"
#import "NSStringAdditions.h"

@implementation APCinemaTorrentFinder

//cinematorrents api endpoint
NSString *CINEMATORRENTS_ENDPOINT = @"http://cinematorrents.com";

//cinematorrents api resources
NSString *CINEMATORRENTS_RESOURCE_SEARCH_BY_TITLE = @"/feed/movies.xml?title=%@";

static APCinemaTorrentFinder *sharedInstance = nil;
+ (APCinemaTorrentFinder*) sharedInstance{
    @synchronized([APCinemaTorrentFinder class]){
        if (!sharedInstance) {
            sharedInstance = [[self alloc]init];
        }
        return sharedInstance;
    }
    return nil;
}

- (id)init{
    if ((self = [super init])) {
        _acceptHeader = @"application/xml";
    }
    return self;
}

- (NSArray*)findTorrentsForMovie:(APMovie*)movie{
    
    NSString *title = [movie.title keywordsByStrippingUselessCharacters];
    NSString* urlString = [[CINEMATORRENTS_ENDPOINT stringByAppendingFormat:CINEMATORRENTS_RESOURCE_SEARCH_BY_TITLE,title]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURLResponse *response;
    NSError *error;
    NSDictionary *movies = [[[super performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error] objectForKey:@"rss"] objectForKey:@"channel"];
    
    NSMutableArray *returnedArray = [NSMutableArray array];
    
    if ([[movies objectForKey:@"item"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in [movies objectForKey:@"item"]) {
            [returnedArray addObject:[[dict objectForKey:@"enclosure"] objectForKey:@"url"]];
        }
    }
    else if ([[movies objectForKey:@"item"] isKindOfClass:[NSDictionary class]]) {
        [returnedArray addObject:[[[movies objectForKey:@"item"] objectForKey:@"enclosure"] objectForKey:@"url"]];
    }
    
    return returnedArray;
}

@end
