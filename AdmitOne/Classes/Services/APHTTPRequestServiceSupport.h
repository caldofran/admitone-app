//
//  HTTPServiceInterface.h
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

#import <Foundation/Foundation.h>

@interface APHTTPRequestServiceSupport : NSObject {

    NSString *_acceptHeader;
    NSString *_contentTypeHeader;
    NSString *_tokenKeyHeader;
    NSString *_tokenValueHeader;
    NSString *_username;
    NSString *_password;
}
- (NSDictionary *)performActionRequestToURL:(NSURL *)url withMethod:(NSString *)method body:(NSString *)body response:(NSURLResponse **)response andError:(NSError **)error;

@end
