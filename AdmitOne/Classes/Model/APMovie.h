//
//  APMovie.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APMovie : NSObject{
@private
    NSString *_id;
    NSString *_imdbId;
    NSString *_title;
    NSInteger _year;
    NSArray *_genres;
    NSString *_mppaRating;
    NSInteger _runtime;
    NSString *_synopsis;
    NSURL *_imageURL;
    NSDictionary *_cast;//2keys, name:NSString and characters:NSArray
    NSString *_director;
    NSString *_studio;
    
    NSString *_youtubeTrailer;
    NSString *_bestTorrent;
    
    //criticisms
    NSString *_criticsConsensus;
    NSString *_criticsRating;
    NSInteger _criticsScore;
    NSString *_audienceRating;
    NSInteger _audienceScore;
}

-(id) initWithDictionnary:(NSDictionary*)dict;

@property (nonatomic,retain) NSString *id;
@property (nonatomic,retain) NSString *imdbId;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *synopsis;
@property (assign) NSInteger year;
@property (nonatomic,retain) NSArray *genres;
@property (nonatomic,retain) NSString *mppaRating;
@property (assign) NSInteger runtime;
@property (nonatomic,retain) NSURL *imageURL;
@property (nonatomic,retain) NSDictionary *cast;
@property (nonatomic,retain) NSString *director;
@property (nonatomic,retain) NSString *studio;
@property (nonatomic,retain) NSString *youtubeTrailer;
@property (nonatomic,retain) NSString *bestTorrent;
@property (nonatomic,retain) NSString *criticsConsensus;
@property (nonatomic,retain) NSString *criticsRating;
@property (assign) NSInteger criticsScore;
@property (nonatomic,retain) NSString *audienceRating;
@property (assign) NSInteger audienceScore;


@end
