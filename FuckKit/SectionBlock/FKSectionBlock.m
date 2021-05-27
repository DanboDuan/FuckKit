//
//  FKSectionBlock.m
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import "FKSectionBlock.h"
#import <mach-o/getsect.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

@interface FKSectionBlock ()

@property (atomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *keyBlocks;

- (void)addBlock:(dispatch_block_t)block forKey:(NSString *)key;

@end

static void FKReadBlocks(char *sectionName, const struct mach_header *mhp) {
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    FKBlock *dataArray = (FKBlock *)memory;
    unsigned long counter = size/sizeof(FKBlock);
    /// next runloop for oc method
    dispatch_async(dispatch_get_main_queue(), ^{
        for(int idx = 0; idx < counter; ++idx) {
            FKBlock data = dataArray[idx];
            NSString *key = [NSString stringWithUTF8String:data.key];
            dispatch_block_t block = data.block;
            [[FKSectionBlock sharedInstance] addBlock:block forKey:key];
        }
    });
}

static void dyld_block_callback(const struct mach_header *mhp, intptr_t vmaddr_slide)
{
    Dl_info info;
    if (dladdr(mhp, &info) == 0) {
        return;
    }
    FKReadBlocks("__FKBlock",mhp);
}

__attribute__((constructor)) void fkBlockProphet(void) {
    _dyld_register_func_for_add_image(dyld_block_callback);
}

@implementation FKSectionBlock

+ (instancetype)sharedInstance {
    static FKSectionBlock *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyBlocks = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addBlock:(dispatch_block_t)block forKey:(NSString *)key {
    if (block == nil || key == nil) {
        return;
    }
    
    NSMutableArray *blocks = [self.keyBlocks objectForKey:key];
    if (blocks == nil) {
        blocks = [NSMutableArray new];
        [self.keyBlocks setValue:blocks forKey:key];
    }
    [blocks addObject:block];
}

- (void)excuteBlocksForKey:(NSString *)key {
    if (key == nil) {
        return;
    }
    
    NSArray<dispatch_block_t> *blocks = [self.keyBlocks objectForKey:key].copy;
    if (blocks == nil) {
        return;
    }
    [blocks enumerateObjectsUsingBlock:^(dispatch_block_t block, NSUInteger idx, BOOL * stop) {
        block();
    }];
}

@end
