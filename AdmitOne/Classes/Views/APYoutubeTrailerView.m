//
//  APYoutubeTrailerView.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-12.
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

#import "APYoutubeTrailerView.h"

@implementation APYoutubeTrailerView

-(id) initWithYoutubeId:(NSString*)youtubeId{
    if ((self = [super init])) {
        _htmlHasLoaded = NO;
        [self setHidden:YES];
        _webview = [[WebView alloc]init];
        [_webview setMainFrameURL:[NSString stringWithFormat:@"http://www.youtube.com/v/%@&autoplay=1",youtubeId]];
        [_webview setResourceLoadDelegate:self];
    }
    return self;
}

-(void)webView:(WebView*)webView resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource{
    if(!_htmlHasLoaded){
        
        DOMRange *dom = [_webview selectedDOMRange];
        _htmlHasLoaded = YES;
    }
}

@end
