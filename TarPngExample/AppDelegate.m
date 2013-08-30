//
//  AppDelegate.m
//  TarPng
//
//  Created by Aaron Clarke on 8/30/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

struct TarHeader {
    char name[100];
    char mode[8];
    char uid[8];
    char gid[8];
    char size[12];
    char mtime[12];
    char chksum[8];
    char typeflag;
    char linkname[100];
    char magic[6];
    char version[2];
    char uname[32];
    char gname[32];
    char devmajor[8];
    char defminor[8];
    char prefix[155];
    char padding[12];
};

static NSDictionary* loadTarContents(NSString* path)
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:path]);
    NSMutableDictionary* temp = [[NSMutableDictionary alloc] initWithCapacity:100];
    int pageSize = getpagesize();

    int fd = open(path.UTF8String, O_RDONLY);
    uint64_t offset = 0;
    
    char* mem = mmap(NULL, pageSize, PROT_READ, MAP_FILE|MAP_PRIVATE, fd, offset);
    char* memend = mem+pageSize;
    char* memloc = mem;
    char headerBlob[sizeof(struct TarHeader)];
    uint32_t headerBlobSize = 0;
    int foundEnd = mem == MAP_FAILED;
    
    while (!foundEnd) {
        while (memloc < memend) {
            char* headerLoc = NULL;
            
            if (headerBlobSize > 0) {
                int restSize = sizeof(struct TarHeader) - headerBlobSize;
                memcpy(headerBlob+headerBlobSize, mem, restSize);
                headerBlobSize = 0;
                memloc += restSize;
                headerLoc = headerBlob;
            } else if (memloc + sizeof(struct TarHeader) >= memend) {
                headerBlobSize = pageSize;
                memcpy(headerBlob, memloc, headerBlobSize);
                memloc += headerBlobSize;
            } else {
                headerLoc = memloc;
                memloc += sizeof(struct TarHeader);
            }
            
            if (headerLoc) {
                struct TarHeader header;
                memcpy(&header, headerLoc, sizeof(struct TarHeader));
                char sizestr[13] = {0};
                memcpy(sizestr, &header.size, 12);
                int size = 0;
                sscanf(sizestr, "%o", &size);
                int totalSize = (size%512==0)?size:((size/512)+1) * 512;
                NSString* name = [NSString stringWithUTF8String:header.name];
                if (name.length <= 0) {
                    memloc = memend;
                    foundEnd = 1;
                } else {
                    temp[name] = @{
                                   @"size":@(size),
                                   @"offset":@(memloc - mem + offset),
                                   };
                    memloc += totalSize;
                }
            }
        }
        
        uint64_t loc = offset + memloc-mem;
        offset = (loc / pageSize) * pageSize;
        uint64_t overflow = loc % pageSize;
        mmap(mem, pageSize, PROT_READ, MAP_FIXED|MAP_FILE|MAP_PRIVATE, fd, offset);
        memloc = mem + overflow;
    }
    
    munmap(mem, pageSize);
    close(fd);
    
    NSLog(@"%@", temp);
    NSDictionary* answer = [NSDictionary dictionaryWithDictionary:temp];
    [temp release];
    return answer;
}

static CGImageRef createTarPngImage(NSString* path, uint64_t offset, uint64_t size)
{
    int pageSize = getpagesize();
    uint64_t start = (offset%pageSize==0) ? offset : (offset/pageSize)*pageSize;
    uint64_t desiredSize = (offset-start) + size;
    uint64_t mapSize = (desiredSize%pageSize==0)?
                        desiredSize:
                        ((desiredSize/pageSize)+1) * pageSize;
    
    int fd = open(path.UTF8String, O_RDONLY);
    char* mem = mmap(NULL, mapSize, PROT_READ, MAP_FILE|MAP_PRIVATE, fd, start);
    
    NSData* data = [NSData dataWithBytes:mem + (offset - start) length:size];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef answer =
        CGImageCreateWithPNGDataProvider(dataProvider, NULL, YES, kCGRenderingIntentDefault);

    CGDataProviderRelease(dataProvider);
    munmap(mem, mapSize);
    close(fd);

    return answer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString* path = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"tar"];
    NSDictionary* contents = loadTarContents(path);
    NSLog(@"%@", contents);

    NSDictionary* mushroom = contents[@"Mushroom2.PNG"];
    CGImageRef img = createTarPngImage(path,
                                       [mushroom[@"offset"] longLongValue],
                                       [mushroom[@"size"] longLongValue]);
    NSImage* nsimg = [[NSImage alloc] initWithCGImage:img
                                                 size:NSMakeSize(CGImageGetWidth(img),
                                                                 CGImageGetHeight(img)) ];
    self.imageView.image = nsimg;
    CGImageRelease(img);
}

@end
