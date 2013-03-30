//
//  APMovie.m
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

#import "APMovie.h"

@implementation APMovie

@synthesize id = _id, imdbId = _imdbId, title = _title, mppaRating = _mppaRating, youtubeTrailer = _youtubeTrailer, bestTorrent = _bestTorrent, criticsConsensus = _criticsConsensus, criticsRating = _criticsRating, audienceRating = _audienceRating, audienceScore = _audienceScore, synopsis = _synopsis, imageURL = _imageURL;

- (id)initWithDictionnary:(NSDictionary *)dict {

    if ((self = [super init])) {
        self.id = [dict objectForKey:@"id"];
        self.imdbId = [[dict objectForKey:@"alternate_ids"] objectForKey:@"imdb"];
        self.title = [dict objectForKey:@"title"];
        self.year = [[dict objectForKey:@"year"] integerValue];
        self.mppaRating = [dict objectForKey:@"mpaa_rating"];
        self.runtime = [[dict objectForKey:@"runtime"] integerValue];
        self.criticsConsensus = [dict objectForKey:@"critics_consensus"];
        self.criticsRating = [[dict objectForKey:@"ratings"] objectForKey:@"critics_rating"];
        self.criticsScore = [[[dict objectForKey:@"ratings"] objectForKey:@"critics_score"] integerValue];
        self.audienceRating = [[dict objectForKey:@"ratings"] objectForKey:@"audience_rating"];
        self.audienceScore = [[[dict objectForKey:@"ratings"] objectForKey:@"audience_score"] integerValue];
        self.synopsis = [dict objectForKey:@"synopsis"];
        self.imageURL = [NSURL URLWithString:[[dict objectForKey:@"posters"] objectForKey:@"detailed"]];
    }
    return self;
}

- (void)dealloc {
    [_id release];
    [_imdbId release];
    [_title release];
    [_mppaRating release];
    [_youtubeTrailer release];
    [_bestTorrent release];
    [_criticsConsensus release];
    [_criticsRating release];
    [_audienceRating release];
    [_synopsis release];
    [_imageURL release];
    [super dealloc];
}

- (NSString *)description {
    return self.title;
}

@end
