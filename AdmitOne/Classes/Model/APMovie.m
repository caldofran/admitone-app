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

@synthesize imdbId = _imdbId, title = _title, mppaRating = _mppaRating, youtubeTrailer = _youtubeTrailer, bestTorrent = _bestTorrent, criticsConsensus = _criticsConsensus, criticsRating = _criticsRating, audienceRating = _audienceRating, audienceScore = _audienceScore, synopsis = _synopsis, imageURL = _imageURL;

- (id)initWithDictionnary:(NSDictionary *)dict {

    if ((self = [super init])) {
        self.imdbId = [dict objectForKey:@"imdbId"];
        self.title = [dict objectForKey:@"title"];
        self.year = [[dict objectForKey:@"year"] integerValue];
        self.mppaRating = [dict objectForKey:@"mppaRating"];
        self.runtime = [[dict objectForKey:@"runtime"] integerValue];
        self.criticsConsensus = [dict objectForKey:@"criticsConsensus"];
        self.criticsRating = [dict objectForKey:@"criticsRating"];
        self.criticsScore = [[dict objectForKey:@"criticsScore"] integerValue];
        self.audienceRating = [dict objectForKey:@"audienceRating"];
        self.audienceScore = [[dict objectForKey:@"audienceScore"] integerValue];
        self.synopsis = [dict objectForKey:@"synopsis"];
        self.imageURL = [NSURL URLWithString:[dict objectForKey:@"imageURL"]];
    }
    return self;
}

- (void)dealloc {
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
