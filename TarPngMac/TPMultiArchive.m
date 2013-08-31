//
//  TPMultiArchive.m
//  TarPng
//
//  Created by Aaron Clarke on 8/30/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import "TPMultiArchive.h"
#import "TPArchive.h"

@interface TPMultiArchive ()
@property (nonatomic, retain) NSMutableDictionary* dict;
@end

@implementation TPMultiArchive

- (id)init
{
    self = [super init];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCapacity:50];
    }
    return self;
}

- (void)dealloc
{
    [_dict release];
    [super dealloc];
}

-(CGImageRef)createImageNamed:(NSString*)name
{
    TPArchive* arc = [self.dict objectForKey:name];
    if (arc) {
        return [arc createImageNamed:name];
    } else {
        return nil;
    }
}

-(NSArray*)names
{
    return self.dict.allKeys;
}

-(void)loadTAR:(NSString*)path
{
    TPArchive* archive = [[TPArchive alloc] initWithTAR:path];
    for (NSString* name in archive.names) {
        self.dict[name] = archive;
    }
    [archive release];
}

#if TARGET_OS_MAC
-(NSImage*)imageNamed:(NSString*)name
{
    CGImageRef img = [self createImageNamed:name];
    if (img) {
        NSImage* answer = [[NSImage alloc] initWithCGImage:img
                                                      size:NSMakeSize(CGImageGetWidth(img),
                                                                      CGImageGetHeight(img)) ];
        CGImageRelease(img);
        return answer;
    } else {
        return nil;
    }
}
#endif

#if TARGET_OS_IPHONE
-(UIImage*)imageNamed:(NSString*)name
{
    CGImageRef img = [self createImageNamed:name];
    if (img) {
        UIImage* answer = [UIImage imageWithCGImage:img];
        CGImageRelease(img);
        return answer;
    } else {
        return nil;
    }
}
#endif

@end
