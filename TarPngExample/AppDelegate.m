//
//  AppDelegate.m
//  TarPng
//
//  Created by Aaron Clarke on 8/30/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import "AppDelegate.h"
#import "TPArchive.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString* path = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"tar"];
    TPArchive* arc = [[TPArchive alloc] initWithTAR:path];
    NSLog(@"names:%@", arc.names);
    CGImageRef img = [arc createImageNamed:@"Mushroom2.PNG"];
    NSImage* nsimg = [[NSImage alloc] initWithCGImage:img
                                                 size:NSMakeSize(CGImageGetWidth(img),
                                                                 CGImageGetHeight(img)) ];
    self.imageView.image = nsimg;
    CGImageRelease(img);
}

@end
