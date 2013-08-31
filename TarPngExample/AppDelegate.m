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
    NSImage* nsimg = [arc imageNamed:@"Mushroom2.PNG"];
    self.imageView.image = nsimg;
    [arc release];
}

@end
