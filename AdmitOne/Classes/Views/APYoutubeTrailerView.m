//
//  APYoutubeTrailerView.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-12.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
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
