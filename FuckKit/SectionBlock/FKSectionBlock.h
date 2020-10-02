//
//  FKSectionBlock.h
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "FKMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _FKBlock {
    const char *key;
    __unsafe_unretained void (^block)(void);
} FKBlock;

#define FKBlockUniqueIdentifier FKIdentifier(__FKBlock, __COUNTER__)

#define FK_BLOCKS_EXPORT(key, block) \
FKSectionNameData(__FKBlock) \
static const FKBlock FKBlockUniqueIdentifier = (FKBlock){key, block};

/**
 e.g.
 1. define blocks
 FK_BLOCKS_EXPORT("a", ^(void) {
     printf("\nBlockA:test block A");
 })
 
 2.call blocks, should not be in the first runloop
 dispatch_async(dispatch_get_main_queue(), ^{
     [[FKSectionBlock sharedInstance] excuteBlocksForKey:@"a"];
 });
 */
@interface FKSectionBlock : NSObject

+ (instancetype)sharedInstance;

- (void)excuteBlocksForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
