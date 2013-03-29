//
//  main.m
//  AdmitOne
//
//  Created by Anthony Plourde on 11-12-22.
//  Copyright (c) 2011 Anthony Plourde. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    signal(SIGPIPE, SIG_IGN);
    return NSApplicationMain(argc, (const char **)argv);
}
