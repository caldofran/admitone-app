//
//  APYoutubeTrailerView.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-12.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface APYoutubeTrailerView : NSView{
@private
    WebView *_webview;
    BOOL _htmlHasLoaded;
}

-(id) initWithYoutubeId:(NSString*)youtubeId;

@end
