//
//  TorrentReactorTorrentFinder.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-06-23.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APReactorTorrentFinder.h"

#import "APMovie.h"
#import "NSStringAdditions.h"

@implementation APReactorTorrentFinder

//kickasstorrent api endpoint
NSString *TORRENT_REACTOR_ENDPOINT = @"http://www.torrentreactor.net";

//kickasstorrent api resources
NSString *TORRENT_REACTOR_RESOURCE_SEARCH_BY_TITLE = @"/rss.php?search=%@";

static APReactorTorrentFinder *sharedInstance = nil;
+ (APReactorTorrentFinder*) sharedInstance{
    @synchronized([APReactorTorrentFinder class]){
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

- (NSDictionary*) torrentDictionnaryFromServerDictionnary:(NSDictionary*)dict{
    NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc]init];
    
    NSArray *descriptionArray = [[dict objectForKey:@"description"] componentsSeparatedByString:@" "];
    NSNumber *size = [NSNumber numberWithInt:[[descriptionArray objectAtIndex:[descriptionArray indexOfObject:@"Size:"]+1]floatValue]*1000000];
    NSNumber *seeds = [NSNumber numberWithInt:[[descriptionArray objectAtIndex:[descriptionArray indexOfObject:@"seeder,"]-1]intValue]];
    
    [torrentDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
    [torrentDict setObject:seeds forKey:@"seeds"];
    [torrentDict setObject:[dict objectForKey:@"link"] forKey:@"torrentLink"];
    [torrentDict setObject:size forKey:@"size"];
    return torrentDict;
}

- (NSArray*)findTorrentsForMovie:(APMovie*)movie{
    
    NSString *keywords = [super normalizeKeywordsForMovie:movie escapingSpaces:NO];
    NSString* urlString = [[TORRENT_REACTOR_ENDPOINT stringByAppendingFormat:TORRENT_REACTOR_RESOURCE_SEARCH_BY_TITLE,keywords]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURLResponse *response;
    NSError *error;
    NSDictionary *movies = [[[self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error] objectForKey:@"rss"] objectForKey:@"channel"];
    
    NSMutableArray *returnedArray = [NSMutableArray array];
    
    if ([[movies objectForKey:@"item"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in [movies objectForKey:@"item"]) {
            if ([super isTorrentTitle:[dict objectForKey:@"title"] andSize:[[dict objectForKey:@"size"]integerValue] matchingMovie:movie]) {
                NSDictionary *torrentDict = [self torrentDictionnaryFromServerDictionnary:dict];
                [returnedArray addObject:torrentDict];
                [torrentDict release];
            }
        }
    }
    else if ([[movies objectForKey:@"item"] isKindOfClass:[NSDictionary class]]){
        if ([super isTorrentTitle:[movies objectForKey:@"title"] andSize:[[movies objectForKey:@"size"]integerValue] matchingMovie:movie]) {
            NSDictionary *torrentDict = [self torrentDictionnaryFromServerDictionnary:movies];
            [returnedArray addObject:torrentDict];
            [torrentDict release];
        }
    }
    
    return returnedArray;
}

@end
