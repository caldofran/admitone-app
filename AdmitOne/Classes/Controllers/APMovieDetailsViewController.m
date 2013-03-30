//
//  APMovieDetailsViewController.m
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

#import "APMovieDetailsViewController.h"
#import "APMovie.h"
#import "APMovieDatasourceFetcher.h"
#import "APReactorTorrentFinder.h"
#import "APIsoHuntTorrentFinder.h"
#import "APKickAssTorrentFinder.h"
#import "Constants.h"
#import "AppDelegate.h"


@implementation APMovieDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)awakeFromNib {

    [_trailerWebView setDrawsBackground:NO];
    [_trailerWebView setResourceLoadDelegate:self];

    [_languagePopup setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"preferedLanguage"] ? : @"English"];
    [_hdSwitch setSelectedSegment:[[[NSUserDefaults standardUserDefaults] objectForKey:@"hdQuality"] integerValue]];
}

- (void)updateViewWithMovie:(APMovie *)movie {

    _movie = movie;
    _movieTitle.stringValue = movie.title;
    _mpaaRating.stringValue = [NSString stringWithFormat:@"Rating : %@", movie.mppaRating];
    _runtime.stringValue = [NSString stringWithFormat:@"Runtime : %li min", movie.runtime];
    _criticsRatingText.stringValue = [NSString stringWithFormat:@"%li%% %@", movie.criticsScore, movie.criticsRating];
    _audienceRatingText.stringValue = [NSString stringWithFormat:@"%li%% %@", movie.audienceScore, movie.audienceRating];

    NSImage *image = [[NSImage alloc] initWithContentsOfURL:movie.imageURL];
    _dvdCover.image = image;
    [image release];

    NSString *criticsImageName = movie.criticsScore >= 60 ?
            ([movie.criticsRating isEqualToString:@"Certified Fresh"] ?
                    @"RTCriticsCertifiedFresh.png"
                    : @"RTCriticsGood.png")
            : @"RTCriticsBad.png";
    _criticsRatingImage.image = [NSImage imageNamed:criticsImageName];

    NSString *audienceImageName = movie.audienceScore >= 60 ? @"RTAudienceGood.png" : @"RTAudienceBad.png";
    _audienceRatingImage.image = [NSImage imageNamed:audienceImageName];

    _synopsis.string = movie.synopsis ? : @"N/A";
    _synopsis.textColor = [NSColor whiteColor];
    _criticsReview.string = movie.criticsConsensus ? : @"N/A";
    _criticsReview.textColor = [NSColor whiteColor];

    [self _findTrailer];
    [self _findDownloadForCurrentLanguage];
}

#pragma mark - IBActions -

- (IBAction)watchTrailer:(id)sender {

    if ([[sender title] isEqualToString:@"WATCH TRAILER"]) {
        _webviewReceiveCount = 0;
        _trailerWebView.mainFrameURL = _movie.youtubeTrailer;
        [_trailerWebView setHidden:YES];
        [_trailerView setHidden:NO];
    }
}

- (IBAction)closeTrailer:(id)sender {

    _trailerWebView.mainFrameURL = @"about:blank";
    [_trailerView setHidden:YES];
}

- (IBAction)download:(id)sender {

    if ([[sender title] isEqualToString:@"DOWNLOAD"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_movie.bestTorrent]];
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if ([response statusCode] != 200) {
            NSString *errorMessagePattern = @"URL : %@ \n\n Make sure you are not on a network that blocks torrent downloads. Check by trying to download a torrent file manualy, on http://kat.ph for example.";
            [[NSAlert alertWithMessageText:[error description] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:errorMessagePattern, _movie.bestTorrent] runModal];
        }

        BOOL useSystemAppToDownload = [[[NSUserDefaults standardUserDefaults] objectForKey:kAPUseSystemAppToDownload] boolValue];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *path = nil;

        if (!useSystemAppToDownload) {
            path = [[paths objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/Temp/%@", _movie.bestTorrent.lastPathComponent];
        }
        else {
            NSString *downloadFolder = [[NSUserDefaults standardUserDefaults] objectForKey:kAPDownloadFolder];
            path = [downloadFolder stringByAppendingFormat:@"/%@", _movie.bestTorrent.lastPathComponent];
        }

        if (![path hasSuffix:@".torrent"]) {
            path = [path stringByAppendingString:@".torrent"];
        }
        if ([data writeToFile:path options:NSAtomicWrite error:nil] == NO) {
            NSLog(@"writeToFile error at path %@", path);
        }

        if (!useSystemAppToDownload) {
            [(AppDelegate *) [[NSApplication sharedApplication] delegate] showDownloads:nil];
        }
        else {
            [[NSWorkspace sharedWorkspace] openFile:path];
        }
    }
}

- (IBAction)languageSelect:(id)sender {

    [[NSUserDefaults standardUserDefaults] setObject:[_languagePopup titleOfSelectedItem] forKey:@"preferedLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _movie.bestTorrent = nil;
    [self _findDownloadForCurrentLanguage];
}

- (IBAction)qualitySelect:(id)sender {

    [[NSUserDefaults standardUserDefaults] setBool:(BOOL) [sender selectedSegment] forKey:@"hdQuality"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _movie.bestTorrent = nil;
    [self _findDownloadForCurrentLanguage];
}

#pragma mark - WebViewResource Delegate Methods -

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {

    _webviewReceiveCount++;
    [_trailerWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background='#000'"];
    if (_trailerWebView.isHidden && _webviewReceiveCount > 4 /*&& _gotTrailerURL*/) {
        //just to avoid White flash !
        [_trailerWebView setHidden:NO];
    }
}

#pragma mark - Private Methods -

- (void)_findTrailer {

    [_trailerButton setTitle:@"SEARCHING TRAILER"];
    [_trailerSearching startAnimation:nil];

    if (_movie.imdbId) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            [[APMovieDatasourceFetcher sharedInstance] completeTrailerInfo:_movie];

            dispatch_async(dispatch_get_main_queue(), ^{

                if ([_movie.youtubeTrailer length] > 0) {
                    [_trailerButton setTitle:@"WATCH TRAILER"];
                }
                else {
                    [_trailerButton setTitle:@"NO TRAILER FOUND"];
                }
                [_trailerSearching stopAnimation:nil];
                [CATransaction flush];
            });
        });
    } else {

        [_trailerButton setTitle:@"NO TRAILER FOUND"];
        [_trailerSearching stopAnimation:nil];
    }

}

- (void)_findDownloadForCurrentLanguage {

    [_downloadButton setTitle:@"SEARCHING TORRENT"];
    [_downloadSearching startAnimation:nil];

    NSMutableArray *torrents = [[NSMutableArray alloc] init];

    dispatch_queue_t torrentFinder = dispatch_queue_create("torrentFinder", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(torrentFinder, ^{
        [torrents addObjectsFromArray:[[APKickAssTorrentFinder sharedInstance] findTorrentsForMovie:_movie]];
    });

    dispatch_async(torrentFinder, ^{
        [torrents addObjectsFromArray:[[APReactorTorrentFinder sharedInstance] findTorrentsForMovie:_movie]];
    });

    dispatch_async(torrentFinder, ^{
        [torrents addObjectsFromArray:[[APIsoHuntTorrentFinder sharedInstance] findTorrentsForMovie:_movie]];
    });

    //when all done, merge together, sort by seeds and get the best
    dispatch_barrier_async(torrentFinder, ^{

        if ([torrents count] > 0) {
            [torrents setArray:[torrents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 objectForKey:@"seeds"] integerValue] > [[obj2 objectForKey:@"seeds"] integerValue] ? NSOrderedAscending : NSOrderedDescending;
            }]];
            NSLog(@"%@", [torrents objectAtIndex:0]);
            _movie.bestTorrent = [[torrents objectAtIndex:0] objectForKey:@"torrentLink"];
        }
        if ([_movie.bestTorrent length] > 0) {
            [_downloadButton setTitle:@"DOWNLOAD"];
        }
        else {
            [_downloadButton setTitle:@"NO DOWNLOAD FOUND"];
        }
        [_downloadSearching stopAnimation:nil];
        [CATransaction flush];
        [torrents release];
    });
    dispatch_release(torrentFinder);
}

@end
