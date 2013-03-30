//
//  APMovie.h
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

#import <Foundation/Foundation.h>

@interface APMovie : NSObject {
@private
    NSString *_id;
    NSString *_imdbId;
    NSString *_title;
    NSString *_mppaRating;
    NSString *_synopsis;
    NSURL *_imageURL;

    NSString *_youtubeTrailer;
    NSString *_bestTorrent;

    NSString *_criticsConsensus;
    NSString *_criticsRating;
    NSString *_audienceRating;
    NSInteger _audienceScore;
}

- (id)initWithDictionnary:(NSDictionary *)dict;

@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *imdbId;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *synopsis;
@property(assign) NSInteger year;
@property(nonatomic, retain) NSString *mppaRating;
@property(assign) NSInteger runtime;
@property(nonatomic, retain) NSURL *imageURL;
@property(nonatomic, retain) NSString *youtubeTrailer;
@property(nonatomic, retain) NSString *bestTorrent;
@property(nonatomic, retain) NSString *criticsConsensus;
@property(nonatomic, retain) NSString *criticsRating;
@property(assign) NSInteger criticsScore;
@property(nonatomic, retain) NSString *audienceRating;
@property(assign) NSInteger audienceScore;

@end
