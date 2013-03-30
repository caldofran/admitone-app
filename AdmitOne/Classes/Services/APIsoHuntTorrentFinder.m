//
//  APIsoHuntTorrentFinder.m
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

#import "APIsoHuntTorrentFinder.h"

#import "APMovie.h"
#import "NSStringAdditions.h"

@implementation APIsoHuntTorrentFinder

//isohunt api endpoint
NSString *ISOHUNT_ENDPOINT = @"http://isohunt.com/js";

//isohunt api resources
NSString *ISOHUNT_RESOURCE_SEARCH_BY_TITLE = @"/json.php?ihq=%@";

static APIsoHuntTorrentFinder *sharedInstance = nil;
+ (APIsoHuntTorrentFinder*) sharedInstance{
    @synchronized([APIsoHuntTorrentFinder class]){
        if (!sharedInstance) {
            sharedInstance = [[self alloc]init];
        }
        return sharedInstance;
    }
    return nil;
}

- (id)init{
    if ((self = [super init])) {
        _acceptHeader = @"application/json";
    }
    return self;
}

- (NSArray*)findTorrentsForMovie:(APMovie*)movie{
    
    NSString *keywords = [super normalizeKeywordsForMovie:movie escapingSpaces:YES];
    NSString* urlString = [[ISOHUNT_ENDPOINT stringByAppendingFormat:ISOHUNT_RESOURCE_SEARCH_BY_TITLE,keywords]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURLResponse *response;
    NSError *error;
    NSDictionary *movies = [[[self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error] objectForKey:@"items"] objectForKey:@"list"];
    
    NSMutableArray *returnedArray = [NSMutableArray array];
    
    for (NSDictionary *dict in movies) {
        if ([super isTorrentTitle:[dict objectForKey:@"title"] andSize:[[dict objectForKey:@"length"]integerValue] matchingMovie:movie] && 
            [[dict objectForKey:@"Seeds"] integerValue]>0) {
            NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc]init];
            [torrentDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
            [torrentDict setObject:[dict objectForKey:@"Seeds"] forKey:@"seeds"];
            [torrentDict setObject:[dict objectForKey:@"enclosure_url"] forKey:@"torrentLink"];
            [torrentDict setObject:[dict objectForKey:@"length"] forKey:@"size"];
            [returnedArray addObject:torrentDict];
            [torrentDict release];
        }
    }
    
//    int i = 0;
//    for (NSDictionary *d in returnedArray) {
//        NSLog(@"[IsoHunt]\n%@",d);
//        i++;
//        if (i>5) {
//            break;
//        }
//    }
    
    return returnedArray;
}

@end
