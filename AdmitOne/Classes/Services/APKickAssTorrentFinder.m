//
//  APKickAssTorrentFinder.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-14.
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

#import "APKickAssTorrentFinder.h"

#import "APMovie.h"
#import "NSStringAdditions.h"

@implementation APKickAssTorrentFinder

//kickasstorrent api endpoint
NSString *KICKASS_ENDPOINT = @"http://www.kat.ph";

//kickasstorrent api resources
NSString *KICKASS_RESOURCE_SEARCH_BY_TITLE = @"/search/%@/?rss=1&field=seeders&sorder=desc";

static APKickAssTorrentFinder *sharedInstance = nil;
+ (APKickAssTorrentFinder*) sharedInstance{
    @synchronized([APKickAssTorrentFinder class]){
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

- (NSString*)torrentUrlFromDictionary:(NSDictionary*)dict{
    NSString *returnedString = [[dict objectForKey:@"enclosure"] objectForKey:@"url"];
    if ([returnedString rangeOfString:@"torcache.net"].location!=NSNotFound) {
        returnedString = [NSString stringWithFormat:@"http://torrage.com/torrent/%@.torrent",[dict objectForKey:@"infoHash"]];
    }
    return returnedString;
}

- (NSArray*)findTorrentsForMovie:(APMovie*)movie{
    
    NSString *keywords = [super normalizeKeywordsForMovie:movie escapingSpaces:NO];
    NSString* urlString = [[KICKASS_ENDPOINT stringByAppendingFormat:KICKASS_RESOURCE_SEARCH_BY_TITLE,keywords]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURLResponse *response;
    NSError *error;
    NSDictionary *movies = [[[self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error] objectForKey:@"rss"] objectForKey:@"channel"];
    
    NSMutableArray *returnedArray = [NSMutableArray array];
    
    if ([[movies objectForKey:@"item"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in [movies objectForKey:@"item"]) {
            if ([super isTorrentTitle:[dict objectForKey:@"title"] andSize:[[dict objectForKey:@"size"]integerValue] matchingMovie:movie] && 
                [[dict objectForKey:@"seeds"] integerValue]>0) {
                NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc]init];
                [torrentDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
                [torrentDict setObject:[dict objectForKey:@"seeds"] forKey:@"seeds"];
                [torrentDict setObject:[self torrentUrlFromDictionary:dict] forKey:@"torrentLink"];
                [torrentDict setObject:[dict objectForKey:@"length"] forKey:@"size"];
                [returnedArray addObject:torrentDict];
                [torrentDict release];
            }
        }
    }
    else if ([[movies objectForKey:@"item"] isKindOfClass:[NSDictionary class]]){
        if ([super isTorrentTitle:[movies objectForKey:@"title"] andSize:[[movies objectForKey:@"size"]integerValue] matchingMovie:movie] && 
            [[movies objectForKey:@"seeds"] integerValue]>0) {
            NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc]init];
            [torrentDict setObject:[movies objectForKey:@"title"] forKey:@"title"];
            [torrentDict setObject:[movies objectForKey:@"seeds"] forKey:@"seeds"];
            [torrentDict setObject:[self torrentUrlFromDictionary:movies] forKey:@"torrentLink"];
            [torrentDict setObject:[movies objectForKey:@"size"] forKey:@"size"];
            [returnedArray addObject:torrentDict];
            [torrentDict release];
        }
    }
    
//    int i = 0;
//    for (NSDictionary *d in returnedArray) {
//        NSLog(@"[KickAss]\n%@",d);
//        i++;
//        if (i>5) {
//            break;
//        }
//    }
    
    return returnedArray;
}

@end
