//
//  HTTPServiceInterface.m
//  incidents
//
//  Created by Anthony Plourde on 11-11-18.
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

#import "APHTTPRequestServiceSupport.h"
#import "RKXMLParserLibXML.h"
#import "SBJSON.h"
#import "NSData+Base64.h"

@implementation APHTTPRequestServiceSupport

- (void)dealloc {
    [_cache release];
    [super dealloc];
}

- (NSString*) cacheFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *cacheFiledPath = [[paths objectAtIndex:0] stringByAppendingString:@"/AdmitOne/cache.plist"];
    return cacheFiledPath;
}

- (void) cacheResponse:(NSDictionary *)response url:(NSURL*)url {

    NSMutableDictionary *mutableResponse = [[NSMutableDictionary alloc] init];
    [mutableResponse setObject:response forKey:@"response"];
    [mutableResponse setObject:[[NSDate date] description] forKey:@"requestDate"];
    [_cache setObject:mutableResponse forKey:[url absoluteString]];
    [_cache writeToFile:[self cacheFilePath] atomically:YES];
    [mutableResponse release];
}

- (id) responseFromCache:(NSURL *)url {

    if(_cache == nil) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *cacheFilePath = [self cacheFilePath];
        if ([fm fileExistsAtPath:cacheFilePath]) {
            _cache = [[NSMutableDictionary alloc] initWithContentsOfFile:[self cacheFilePath]];
        } else {
            _cache = [[NSMutableDictionary alloc] init];
            return nil;
        }
    }

    NSDictionary *cachedResponse = [_cache objectForKey:[url absoluteString]];

    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *oldDate = [NSDate dateWithString:[cachedResponse objectForKey:@"requestDate"]];
    NSDateComponents *earlierComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:oldDate];
    //checking if cache is too old or not
    BOOL useCache = todayComponents.day == earlierComponents.day &&
            todayComponents.month == earlierComponents.month &&
            todayComponents.year == earlierComponents.year;
    [cal release];
    if(useCache) {
        return [cachedResponse objectForKey:@"response"];
    }
    return nil;
}

- (NSDictionary *)performActionRequestToURL:(NSURL *)url usingCache:(BOOL)usingCache withMethod:(NSString *)method body:(NSString *)body response:(NSURLResponse **)response andError:(NSError **)error {

    if(usingCache) {
        NSDictionary *cachedResponse = [self responseFromCache:url];
        if(cachedResponse != nil) {
            NSLog(@"using cache for : %@",url);
            return cachedResponse;
        }
    }
    NSLog(@"NOT using cache for : %@",url);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:15];

    //setting up method, can be GET, POST, PUT, DELETE
    [request setHTTPMethod:method];

    //setting up URL to hit
    [request setURL:url];

    //setting up header and credentials if applies
    if ([_acceptHeader length] > 0)
        [request setValue:_acceptHeader forHTTPHeaderField:@"Accept"];
    if ([_contentTypeHeader length] > 0)
        [request setValue:_contentTypeHeader forHTTPHeaderField:@"Content-Type"];
    if ([_tokenKeyHeader length] > 0 && [_tokenValueHeader length] > 0)
        [request setValue:_tokenValueHeader forHTTPHeaderField:_tokenKeyHeader];

    //setting up basic http authentication if applies
    if ([_username length] > 0 && [_password length] > 0) {
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

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    //parsing response to nsdictionary
    NSDictionary *dict = nil;
    if ([responseString length] > 3) {
        if ([_acceptHeader rangeOfString:@"xml"].location != NSNotFound || [[url description] rangeOfString:@"atom"].location != NSNotFound) {
            RKXMLParserLibXML *xmlParser = [[RKXMLParserLibXML alloc] init];
            dict = [[xmlParser parseXML:responseString] retain];
            [xmlParser autorelease];
        }
        else if ([_acceptHeader rangeOfString:@"json"].location != NSNotFound) {
            SBJSON *jsonParser = [[SBJSON alloc] init];
            dict = [[jsonParser objectWithString:responseString error:NULL] retain];
            [jsonParser autorelease];
        }
    }
    [pool drain];

    [responseString release];
    [request release];

    [self cacheResponse:dict url:url];

    return [dict autorelease];
}

@end
