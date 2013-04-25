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

#import "APAdmitOneTorrentFinder.h"

#import "APMovie.h"

@implementation APAdmitOneTorrentFinder

NSString *API_ENDPOINT = @"http://anthonyplourde.com:8080/"; //admitone api endpoint
NSString *API_RESOURCE = @"/admitone/api/torrents/movie?title=%@&year=%@&language=%@&quality=%@"; //admitone api resources

static APAdmitOneTorrentFinder *sharedInstance = nil;

+ (APAdmitOneTorrentFinder *)sharedInstance {

    @synchronized ([APAdmitOneTorrentFinder class]) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (id)init {

    if ((self = [super init])) {
        _acceptHeader = @"application/json";
    }
    return self;
}

- (NSDictionary *)findTorrentForMovie:(APMovie *)movie {

    NSString *title = movie.title;
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferedLanguage"] ? : @"english";
    NSString *quality = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hdQuality"] boolValue] ? @"hd" : @"sd";
    NSString *year = [NSString stringWithFormat:@"%ld",movie.year];
    
    NSString *urlString = [[API_ENDPOINT stringByAppendingFormat:API_RESOURCE, title, year, language, quality] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    NSLog(@"Making request to API : %@", urlString);
    
    NSURLResponse *response;
    NSError *error;
    NSDictionary *torrent = [self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error];

    return torrent;
}

@end
