//
//  TorrentReactorTorrentFinder.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-06-23.
//  Copyright (c) 2012 Anthony Plourde.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "APReactorTorrentFinder.h"

#import "APMovie.h"

@implementation APReactorTorrentFinder

NSString *TORRENT_REACTOR_ENDPOINT = @"http://www.torrentreactor.net"; //torrent reactor api endpoint
NSString *TORRENT_REACTOR_RESOURCE_SEARCH_BY_TITLE = @"/rss.php?search=%@"; //torrent reactor api resources

static APReactorTorrentFinder *sharedInstance = nil;

+ (APReactorTorrentFinder *)sharedInstance {

    @synchronized ([APReactorTorrentFinder class]) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (id)init {

    if ((self = [super init])) {
        _acceptHeader = @"application/xml";
    }
    return self;
}

- (NSDictionary *)torrentDictionnaryFromServerDictionnary:(NSDictionary *)dict NS_RETURNS_RETAINED {

    NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc] init];

    NSArray *descriptionArray = [[dict objectForKey:@"description"] componentsSeparatedByString:@" "];
    NSNumber *size = [NSNumber numberWithInt:(int) ([[descriptionArray objectAtIndex:[descriptionArray indexOfObject:@"Size:"] + 1] floatValue] * 1000000)];
    NSNumber *seeds = [NSNumber numberWithInt:[[descriptionArray objectAtIndex:[descriptionArray indexOfObject:@"seeder,"] - 1] intValue]];

    [torrentDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
    [torrentDict setObject:seeds forKey:@"seeds"];
    [torrentDict setObject:[dict objectForKey:@"link"] forKey:@"torrentLink"];
    [torrentDict setObject:size forKey:@"size"];
    return torrentDict;
}

- (NSArray *)findTorrentsForMovie:(APMovie *)movie {

    NSString *keywords = [super normalizeKeywordsForMovie:movie escapingSpaces:NO];
    NSString *urlString = [[TORRENT_REACTOR_ENDPOINT stringByAppendingFormat:TORRENT_REACTOR_RESOURCE_SEARCH_BY_TITLE, keywords] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURLResponse *response;
    NSError *error;
    NSDictionary *movies = [[[self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error] objectForKey:@"rss"] objectForKey:@"channel"];

    NSMutableArray *returnedArray = [NSMutableArray array];

    if ([[movies objectForKey:@"item"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in [movies objectForKey:@"item"]) {
            if ([super isTorrentTitle:[dict objectForKey:@"title"] andSize:[[dict objectForKey:@"size"] integerValue] matchingMovie:movie]) {
                NSDictionary *torrentDict = [self torrentDictionnaryFromServerDictionnary:dict];
                [returnedArray addObject:torrentDict];
                [torrentDict release];
            }
        }
    }
    else if ([[movies objectForKey:@"item"] isKindOfClass:[NSDictionary class]]) {
        if ([super isTorrentTitle:[movies objectForKey:@"title"] andSize:[[movies objectForKey:@"size"] integerValue] matchingMovie:movie]) {
            NSDictionary *torrentDict = [self torrentDictionnaryFromServerDictionnary:movies];
            [returnedArray addObject:torrentDict];
            [torrentDict release];
        }
    }

    return returnedArray;
}

@end
