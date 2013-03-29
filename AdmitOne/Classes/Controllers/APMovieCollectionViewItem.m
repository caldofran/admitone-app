//
//  APMovieCollectionViewItem.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-06.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APMovieCollectionViewItem.h"
#import "APMovie.h"
#import "AppDelegate.h"
#import "NSButton+LinkLike.h"

@implementation APMovieCollectionViewItem

-(void)awakeFromNib{
    if (self.representedObject) {
        self.imageView.image = [[NSImage alloc]initWithContentsOfURL:[(APMovie*)[self representedObject] imageURL]];
        self.textField.stringValue = [(APMovie*)[self representedObject] title];
    }
    
}

- (IBAction)downloadButton:(id)sender{
    [[self collectionView]setSelectionIndexes:nil];
    [self setSelected:YES];
    [(AppDelegate*)[NSApp delegate] showMovieDetails:self.representedObject];
}



@end
