//
//  APMovie.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APMovie.h"
#import "APIsoHuntTorrentFinder.h"
#import "APKickAssTorrentFinder.h"
#import "APBtJunkieTorrentFinder.h"

@implementation APMovie

@synthesize id = _id,
            imdbId = _imdbId,
            title = _title,
            year = _year,
            mppaRating = _mppaRating,
            runtime = _runtime,
            genres = _genres,
            youtubeTrailer = _youtubeTrailer,
            bestTorrent = _bestTorrent,
            criticsConsensus = _criticsConsensus,
            criticsRating = _criticsRating,
            criticsScore = _criticsScore,
            audienceRating = _audienceRating,
            audienceScore = _audienceScore,
            synopsis = _synopsis,
            imageURL = _imageURL,
            cast = _cast,
            director = _director,
            studio = _studio;


-(id) initWithDictionnary:(NSDictionary*)dict{
    if ((self = [super init])) {
        
        self.id = [dict objectForKey:@"id"];
        self.imdbId = [[dict objectForKey:@"alternate_ids"] objectForKey:@"imdb"];
        self.title = [dict objectForKey:@"title"];
        self.year = [[dict objectForKey:@"year"] integerValue];
        self.mppaRating = [dict objectForKey:@"mpaa_rating"];
        self.runtime = [[dict objectForKey:@"runtime"]integerValue];
        self.criticsConsensus = [dict objectForKey:@"critics_consensus"];
        self.criticsRating = [[dict objectForKey:@"ratings"] objectForKey:@"critics_rating"];
        self.criticsScore = [[[dict objectForKey:@"ratings"] objectForKey:@"critics_score"] integerValue];
        self.audienceRating = [[dict objectForKey:@"ratings"] objectForKey:@"audience_rating"];
        self.audienceScore = [[[dict objectForKey:@"ratings"] objectForKey:@"audience_score"] integerValue];
        self.synopsis = [dict objectForKey:@"synopsis"];
        self.imageURL = [NSURL URLWithString:[[dict objectForKey:@"posters"]objectForKey:@"detailed"]];
        self.cast = [dict objectForKey:@"abridged_cast"];
        
        self.studio = [dict objectForKey:@"studio"];
        self.director = [dict objectForKey:@"director"];
        
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
}

-(NSString*)description{
    return self.title;
}

@end
