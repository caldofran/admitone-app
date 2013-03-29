//
//  APTorrentList.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-10.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "transmission.h"

@interface APTorrentList : NSObject{
@private
    NSMutableArray *_list;
    
    tr_session * fLib;
}

@property (nonatomic,retain) NSMutableArray *list;

+ (APTorrentList*) sharedInstance;

- (void)addTorrentsAtPaths:(NSArray*)paths;
- (void)addTorrentAtPath:(NSString*)path;
- (void)removeTorrentAtPath:(NSString*)path;

@end
