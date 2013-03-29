//
//  HTTPServiceInterface.m
//  incidents
//
//  Created by Anthony Plourde on 11-11-18.
//  Copyright (c) 2011 Anthony Plourde. All rights reserved.
//

#import "HTTPRequestor.h"
#import "RKXMLParserLibXML.h"
#import "SBJSON.h"
#import "NSData+Base64.h"

@implementation HTTPRequestor

- (NSDictionary*)performActionRequestToURL:(NSURL*)url withMethod:(NSString*)method body:(NSString*)body response:(NSURLResponse**)response andError:(NSError**)error{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setTimeoutInterval:15];
    
    //setting up method, can be GET, POST, PUT, DELETE
    [request setHTTPMethod:method];
    
    //setting up URL to hit
    [request setURL:url];
    
    //setting up header and credentials if applies
    if([_acceptHeader length]>0)
        [request setValue:_acceptHeader forHTTPHeaderField:@"Accept"];
    if([_contentTypeHeader length]>0)
        [request setValue:_contentTypeHeader forHTTPHeaderField:@"Content-Type"];
    if([_tokenKeyHeader length]>0 && [_tokenValueHeader length]>0)
        [request setValue:_tokenValueHeader forHTTPHeaderField:_tokenKeyHeader];
    
    //setting up basic http authentication if applies
    if ([_username length]>0 && [_password length]>0) {
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", _username, _password];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    //setting up body content
    if (body)
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //performing request
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"Executed Query on URL : %@",[url description]);
//    NSLog(@"Result length : %lu",[responseString length]);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //parsing response to nsdictionary
    NSDictionary *dict = nil;
    if ([responseString length]>3) {
        if ([_acceptHeader rangeOfString:@"xml"].location!=NSNotFound || [[url description] rangeOfString:@"atom"].location!=NSNotFound) {
            RKXMLParserLibXML *xmlParser = [[RKXMLParserLibXML alloc]init];
            dict = [[xmlParser parseXML:responseString] retain];
            [xmlParser autorelease];
        }
        else if([_acceptHeader rangeOfString:@"json"].location!=NSNotFound){
            SBJSON *jsonParser = [[SBJSON alloc]init];
            dict = [[jsonParser objectWithString:responseString error:NULL] retain];
            [jsonParser autorelease];
        }
    }
    [pool drain];
    
    [responseString release];
    [request release];
    
    return [dict autorelease];
}

@end
