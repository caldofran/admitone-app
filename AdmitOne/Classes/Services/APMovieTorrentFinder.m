//
//  APMovieTorrentFinder.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-13.
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

#import "APMovieTorrentFinder.h"
#import "APMovie.h"

@implementation APMovieTorrentFinder

- (NSString*)normalizeKeywordsForMovie:(APMovie*)movie escapingSpaces:(BOOL)escapeSpaces{
    
    NSString *title = [NSString stringWithString:movie.title];
    
    //si ":" dans le titre, seulement prendre la premiere partie
    NSInteger semiColumnPosition = [title rangeOfString:@":"].location;
    if (semiColumnPosition!=NSNotFound) {
        title = [title substringToIndex:semiColumnPosition];
    }
    
    //remplacer par des espaces les charactere suivant \/|!@#$%?*()-=+_][}{}^;.,'"<>«»
    NSString *specialCharacters = @"\\/|!@#$%?*()-=+_][}{^;.,'\"<>«»";
    for (NSInteger i=0;i<[specialCharacters length];i++) {
        NSString *s = [specialCharacters substringWithRange:NSMakeRange(i, 1)];
        title = [title stringByReplacingOccurrencesOfString:s withString:@" "];
    }
    
    //on enleve les doubles espaces
    while ([title rangeOfString:@"  "].location!=NSNotFound) {
        title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    //on ajoute l'annee comme keyword
    title = [title stringByAppendingFormat:@" %ld",movie.year];
    
    //on ajoute la langue si pas "english"
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferedLanguage"]?:@"english";
    language = [language lowercaseString];
    if (![language isEqualToString:@"english"]) {
        title = [title stringByAppendingFormat:@" %@",language];
    }
    
    //dependamment de la source utilisé : remplacer les espace par des +
    if (escapeSpaces) {
        title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    
    return title;
}

- (BOOL)isTorrentTitle:(NSString*)title andSize:(NSInteger)size matchingMovie:(APMovie*)movie{
    
    title = [title lowercaseString];
    
    //si hd on demande plus que 2 gig
    BOOL hd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hdQuality"] boolValue];
    if (hd && size<2147483648) {
        return NO;
    }
    if (!hd && size>2147483648) {
        return NO;
    }
    
    //"rip", "720p" or "1080p" doit etre present
    if ([title rangeOfString:@"rip"].location==NSNotFound &&
        [title rangeOfString:@"720p"].location==NSNotFound &&
        [title rangeOfString:@"1080p"].location==NSNotFound &&
        [title rangeOfString:@"dvd"].location==NSNotFound &&
        [title rangeOfString:@"bluray"].location==NSNotFound) {
        return NO;
    }
    
    //"cam" ne doit pas etre present
    if ([title rangeOfString:@"cam"].location!=NSNotFound) {
        return NO;
    }
    
    //"language" doit etre present si pas "english"
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferedLanguage"]?:@"english";
    language = [language lowercaseString];
    if (![language isEqualToString:@"english"]) {
        if ([title rangeOfString:language].location==NSNotFound) {
            return NO;
        }
    }
    
    //aucun autre "language" doit etre present ["italian","spanish","french","dutch","russian"]
    NSArray *languages = [NSArray arrayWithObjects:@"italian",@"spanish",@"french",@"dutch",@"russian", nil];
    for (NSString *l in languages) {
        if (![l isEqualToString:language]) {
            if ([title rangeOfString:l].location!=NSNotFound) {
                return NO;
            }
        }
    }
    
    //l'annee doit etre presente
    if ([title rangeOfString:[NSString stringWithFormat:@"%ld",movie.year]].location==NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary*)performActionRequestToURL:(NSURL*)url withMethod:(NSString*)method body:(NSString*)body response:(NSURLResponse**)response andError:(NSError**)error{
    return [super performActionRequestToURL:url withMethod:method body:body response:response andError:error];
}

@end