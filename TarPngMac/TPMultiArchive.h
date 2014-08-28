//
//  TPMultiArchive.h
//  TarPng
//
//  Created by Aaron Clarke on 8/30/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPMultiArchive : NSObject
-(CGImageRef)createImageNamed:(NSString*)name;
-(NSArray*)names;
-(void)loadTAR:(NSString*)path;
#ifdef TARPNG_TARGET_MAC
-(NSImage*)imageNamed:(NSString*)name;
#endif
#ifdef TARGET_OS_IPHONE
-(UIImage*)imageNamed:(NSString*)name;
#endif
@end
