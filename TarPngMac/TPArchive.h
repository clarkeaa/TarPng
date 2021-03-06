//
//  TarPngMac.h
//  TarPngMac
//
//  Created by Aaron Clarke on 8/30/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPArchive : NSObject
-(id)initWithTAR:(NSString*)path;
-(CGImageRef)createImageNamed:(NSString*)name;
-(NSArray*)names;
#ifdef TARPNG_TARGET_MAC
-(NSImage*)imageNamed:(NSString*)name;
#endif
#ifdef TARPNG_TARGET_IOS
-(UIImage*)imageNamed:(NSString*)name;
#endif
@end
