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

#import "APMovieDatasourceFetcher.h"
#import "APMovie.h"

@implementation APMovieDatasourceFetcher

//ROTTEN TOMATOES
NSString *ROTTEN_TOMATOES_ENDPOINT = @"http://api.rottentomatoes.com/api/public/v1.0"; //rotten tomatoes api endpoint
NSString *RESOURCE_TOP_RENTALS = @"/lists/dvds/top_rentals.json?apikey=%@&limit=%d"; //rotten tomatoes api resources
NSString *RESOURCE_CURRENT_RELEASES = @"/lists/dvds/current_releases.json?apikey=%@&limit=%d";
NSString *RESOURCE_NEW_RELEASES = @"/lists/dvds/new_releases.json?apikey=%@&limit=%d";
NSString *ROTTEN_TOMATOES_RESOURCE_SEARCH = @"/movies.json?q=%@&apikey=%@&limit=%d";
NSString *ROTTEN_TOMATOES_API_KEY = @"4gvv9j6g6wp5x7zr4he9w6kr"; //rotten tomatoes api key

//THEMOVIEDB
NSString *THEMOVIEDB_ENDPOINT = @"http://api.themoviedb.org/2.1"; //themoviedb api endpoint
NSString *RESOURCE_SEARCH = @"/Movie.search/en/json/%@/%@"; //themoviedb api resources
NSString *RESOURCE_GET_ID = @"/Movie.getInfo/en/json/%@/%d";
NSString *RESOURCE_GET_IMDB = @"/Movie.imdbLookup/en/json/%@/%@";
NSString *THEMOVIEDB_API_KEY = @"5c7eb72a118791e6964844c84a6bea49"; //themoviedb api key

static APMovieDatasourceFetcher *sharedInstance = nil;

+ (APMovieDatasourceFetcher *)sharedInstance {

    @synchronized ([APMovieDatasourceFetcher class]) {
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

- (NSArray *)_moviesFromResource:(NSString *)resource withLimit:(NSUInteger)limit {

    NSString *urlString = [ROTTEN_TOMATOES_ENDPOINT stringByAppendingFormat:resource, ROTTEN_TOMATOES_API_KEY, limit];

    NSArray *arrayToUse;
    BOOL useCache = NO;

    //check if this request is cached
    NSDate *now = [NSDate date];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *cachedMovies = [ud objectForKey:urlString];

    //if it is cached, check if it is not too old
    if (cachedMovies) {
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *todayComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
        NSDate *oldDate = [NSDate dateWithString:[cachedMovies objectForKey:@"fetchedDate"]];
        NSDateComponents *earlierComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:oldDate];
        //checking if cache is too old or not
        useCache = todayComponents.day == earlierComponents.day &&
                todayComponents.month == earlierComponents.month &&
                todayComponents.year == earlierComponents.year;
        [cal release];
    }

    //if cache and not too old, we use it directly
    if (useCache) {

        arrayToUse = [cachedMovies objectForKey:@"movies"];

    } else { //if cache is too old, we need to fetch rotten tomatoes and save the new results to cache

        NSURLResponse *response;
        NSError *error;
        NSDictionary *movies = [self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:&error];
        arrayToUse = [movies objectForKey:@"movies"];

        //saving results to cache
        NSMutableDictionary *dictToCache = [[NSMutableDictionary alloc] initWithDictionary:movies];
        [dictToCache setObject:[now description] forKey:@"fetchedDate"];
        [ud setObject:dictToCache forKey:urlString];
        [ud synchronize];
        [dictToCache release];
    }

    //transforming dictionaries to movie objects
    NSMutableArray *returnedArray = [NSMutableArray arrayWithCapacity:limit];
    for (NSDictionary *dict in arrayToUse) {
        APMovie *movie = [[APMovie alloc] initWithDictionnary:dict];
        if (movie) {
            [returnedArray addObject:movie];
        }
        [movie release];
    }

    return returnedArray;
}

- (void)completeTrailerInfo:(APMovie *)movie {

    //getting the themobiedb id for that movie
    //trying to get with the imdb id
    NSString *urlString = [THEMOVIEDB_ENDPOINT stringByAppendingFormat:RESOURCE_GET_IMDB, THEMOVIEDB_API_KEY, [@"tt" stringByAppendingString:movie.imdbId]];
    NSArray *moviesFound = (id) [self performActionRequestToURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] withMethod:@"GET" body:nil response:nil andError:nil];

    int theMovieDbId = NSNotFound;
    if (moviesFound != nil && [moviesFound count] > 0 && [[moviesFound objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
        theMovieDbId = [[[moviesFound objectAtIndex:0] objectForKey:@"id"] intValue];
    }

    //if it fails with the imdb id, try with the title
    if (theMovieDbId == NSNotFound || theMovieDbId <= 0) {
        NSLog(@"failed getting by imdb, getting by title");
        NSString *title = [movie.title stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        title = [title stringByReplacingOccurrencesOfString:@":" withString:@" "];
        title = [title stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        urlString = [THEMOVIEDB_ENDPOINT stringByAppendingFormat:RESOURCE_SEARCH, THEMOVIEDB_API_KEY, title];
        moviesFound = (id) [self performActionRequestToURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] withMethod:@"GET" body:nil response:nil andError:nil];
        theMovieDbId = [[[moviesFound objectAtIndex:0] objectForKey:@"id"] intValue];
    }

    if (theMovieDbId == NSNotFound || theMovieDbId <= 0) {
        return;
    }

    //getting the movie info from themoviedb
    NSURLResponse *response;
    urlString = [THEMOVIEDB_ENDPOINT stringByAppendingFormat:RESOURCE_GET_ID, THEMOVIEDB_API_KEY, theMovieDbId];
    moviesFound = (id) [self performActionRequestToURL:[NSURL URLWithString:urlString] withMethod:@"GET" body:nil response:&response andError:nil];

    //filling youtube trailer info
    NSString *youtubeTrailer = [[moviesFound objectAtIndex:0] objectForKey:@"trailer"];
    if ([youtubeTrailer rangeOfString:@"youtube.com"].location != NSNotFound) {
        NSUInteger startPos = [youtubeTrailer rangeOfString:@"v="].location + 2;
        NSUInteger endPos = [youtubeTrailer rangeOfString:@"&"].location;

        NSString *youtubeId = [youtubeTrailer substringWithRange:NSMakeRange(startPos, endPos != NSNotFound ? endPos - startPos : youtubeTrailer.length - startPos)];

        movie.youtubeTrailer = [NSString stringWithFormat:@"http://www.youtube.com/v/%@&autoplay=1&autohide=1&showinfo=0&iv_load_policy=3&controls=0", youtubeId];
    }
}

- (NSArray *)topRentals:(NSUInteger)limit {
    return [self _moviesFromResource:RESOURCE_TOP_RENTALS withLimit:limit];
}

- (NSArray *)currentReleases:(NSUInteger)limit {
    return [self _moviesFromResource:RESOURCE_CURRENT_RELEASES withLimit:limit];
}

- (NSArray *)newReleases:(NSUInteger)limit {
    return [self _moviesFromResource:RESOURCE_NEW_RELEASES withLimit:limit];
}

- (NSArray *)searchMoviesWithKeywords:(NSString *)keywords {
    keywords = [keywords stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [self _moviesFromResource:[NSString stringWithFormat:ROTTEN_TOMATOES_RESOURCE_SEARCH, keywords, @"%@", @"%d"] withLimit:500];
}

@end
