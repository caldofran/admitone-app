//
//  HTTPServiceInterface.h
//  incidents
//
//  Created by Anthony Plourde on 11-11-18.
//  Copyright (c) 2011 Edovia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPRequestor : NSObject{
    NSString *_acceptHeader;
    NSString *_contentTypeHeader;
    NSString *_tokenKeyHeader;
    NSString *_tokenValueHeader;
    NSString *_username;
    NSString *_password;
}
- (NSDictionary*)performActionRequestToURL:(NSURL*)url withMethod:(NSString*)method body:(NSString*)body response:(NSURLResponse**)response andError:(NSError**)error;
@end
