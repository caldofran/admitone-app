//
//  APTorrent.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface APTorrent : NSObject{
@private
    NSURL *_url;
    NSInteger _seeds;
    NSInteger _peers;
    NSDictionary *_files; //2 keys, filename:NSString and size:NSNumber
    NSArray *_comments;
}
@end
