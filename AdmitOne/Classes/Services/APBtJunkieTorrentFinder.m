//
//  APBtJunkieTorrentFinder.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-14.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APBtJunkieTorrentFinder.h"
#import "APMovie.h"
#import "NSStringAdditions.h"

@implementation APBtJunkieTorrentFinder

//cinematorrents api endpoint
NSString *BTJUNKIE_ENDPOINT = @"http://btjunkie.org";

//cinematorrents api resources
NSString *BTJUNKIE_RESOURCE_SEARCH_BY_TITLE = @"/rss.xml?query=%@";

static APBtJunkieTorrentFinder *sharedInstance = nil;
+ (APBtJunkieTorrentFinder*) sharedInstance{
    @synchronized([APBtJunkieTorrentFinder class]){
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
    
    NSString *keywords = [super normalizeKeywordsForMovie:movie escapingSpaces:YES];
    
    NSString* urlString = [[BTJUNKIE_ENDPOINT stringByAppendingFormat:BTJUNKIE_RESOURCE_SEARCH_BY_TITLE,keywords]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURLResponse *response;
    NSError *error;
    NSDictionary *movies = [[[self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error] objectForKey:@"rss"] objectForKey:@"channel"];
    
    NSMutableArray *returnedArray = [NSMutableArray array];
    
    if ([[movies objectForKey:@"item"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in [movies objectForKey:@"item"]) {
            //getting number of seed
            NSString *endOfTitle = [[dict objectForKey:@"title"] substringFromIndex:[[dict objectForKey:@"title"] rangeOfString:@"  ["].location+3];
            NSInteger seed = [[endOfTitle substringToIndex:[endOfTitle rangeOfString:@"/"].location] integerValue];
            
            if ([super isTorrentTitle:[dict objectForKey:@"title"] andSize:[[[dict objectForKey:@"enclosure"] objectForKey:@"length"] integerValue] matchingMovie:movie] && seed>0) {
                NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc]init];
                [torrentDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
                [torrentDict setObject:[NSNumber numberWithInteger:seed] forKey:@"seeds"];
                [torrentDict setObject:[[dict objectForKey:@"enclosure"] objectForKey:@"url"] forKey:@"torrentLink"];
                [torrentDict setObject:[[dict objectForKey:@"enclosure"] objectForKey:@"length"] forKey:@"size"];
                [returnedArray addObject:torrentDict];
                [torrentDict release];
            }
        }
    }
    else if ([[movies objectForKey:@"item"] isKindOfClass:[NSDictionary class]]) {
        //getting number of seed
        NSString *endOfTitle = [[movies objectForKey:@"title"] substringFromIndex:[[movies objectForKey:@"title"] rangeOfString:@"  ["].location+3];
        NSInteger seed = [[endOfTitle substringToIndex:[endOfTitle rangeOfString:@"/"].location] integerValue];
        
        if ([super isTorrentTitle:[movies objectForKey:@"title"] andSize:[[[movies objectForKey:@"enclosure"] objectForKey:@"length"] integerValue] matchingMovie:movie] && seed>0) {
            NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc]init];
            [torrentDict setObject:[movies objectForKey:@"title"] forKey:@"title"];
            [torrentDict setObject:[NSNumber numberWithInteger:seed] forKey:@"seeds"];
            [torrentDict setObject:[[movies objectForKey:@"enclosure"] objectForKey:@"url"] forKey:@"torrentLink"];
            [torrentDict setObject:[[movies objectForKey:@"enclosure"] objectForKey:@"length"] forKey:@"size"];
            [returnedArray addObject:torrentDict];
            [torrentDict release];
        }
    }
    [returnedArray setArray:[returnedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 objectForKey:@"seeds"]>[obj2 objectForKey:@"seeds"]?NSOrderedAscending:NSOrderedDescending;
    }]];
    
//    int i = 0;
//    for (NSDictionary *d in returnedArray) {
//        NSLog(@"[BtJunkie]\n%@",d);
//        i++;
//        if (i>5) {
//            break;
//        }
//    }
    
    return returnedArray;
}

@end
