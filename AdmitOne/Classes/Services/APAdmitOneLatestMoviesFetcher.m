//
//  APMovieDatasourceFetcher.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
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

#import "APAdmitOneLatestMoviesFetcher.h"
#import "APMovie.h"
#import "Constants.h"

@implementation APAdmitOneLatestMoviesFetcher

static APAdmitOneLatestMoviesFetcher *sharedInstance = nil;

+ (APAdmitOneLatestMoviesFetcher *)sharedInstance {

    @synchronized ([APAdmitOneLatestMoviesFetcher class]) {
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

- (NSArray *)_moviesFromResource:(NSString *)resource {

    NSString *urlString = [kAdmitOneApiEndPoint stringByAppendingString:resource];

    NSArray *movies = (id) [self performActionRequestToURL:[NSURL URLWithString:urlString] usingCache:TRUE withMethod:@"GET" body:nil response:nil andError:nil];

    //transforming dictionaries to movie objects
    NSMutableArray *returnedArray = [NSMutableArray arrayWithCapacity:[movies count]];
    for (NSDictionary *dict in movies) {
        APMovie *movie = [[APMovie alloc] initWithDictionnary:dict];
        if (movie) {
            [returnedArray addObject:movie];
        }
        [movie release];
    }

    return returnedArray;
}

- (NSArray *)topRentals:(NSUInteger)limit {
    return [self _moviesFromResource:kAdmitOneApiResourceTopRentals];
}

- (NSArray *)currentReleases:(NSUInteger)limit {
    return [self _moviesFromResource:kAdmitOneApiResourceCurrentReleases];
}

- (NSArray *)newReleases:(NSUInteger)limit {
    return [self _moviesFromResource:kAdmitOneApiResourceNewReleases];
}

- (NSArray *)searchMoviesWithKeywords:(NSString *)keywords {
    keywords = [keywords stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [self _moviesFromResource:[NSString stringWithFormat:kAdmitOneApiResourceSearch, keywords]];
}

@end
