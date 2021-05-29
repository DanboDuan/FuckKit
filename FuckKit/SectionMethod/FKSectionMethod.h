//
//  FKSectionMethod.h
//  FuckKit
//
//  Created by bob on 2021/5/28.
//

#import <Foundation/Foundation.h>
#import "FKMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _FKMethod {
    const char *key;
    const void (*value)(void);
} FKMethod;

#define FKMethodIdentifier(COUNTER) FKIdentifier(__FKMethod, COUNTER)
#define FKMethodDataIdentifier FKIdentifier(__FKMethod, __COUNTER__)

#define _FK_METHOD_EXPORT(key, COUNTER) \
FKSectionNameData(__FKMethod) \
static const FKMethod FKMethodDataIdentifier = (FKMethod){key, (void *)(__func__)};


#define FK_METHOD_EXPORT(key) \
_FK_METHOD_EXPORT(key, __COUNTER__)

/**
e.g.
1. define METHOD
 
@implementation FKSectionMethod
+(void)XXX{
 FK_METHOD_EXPORT("a")
 ...
}
@end

 
 
2.call METHOD, should not be in the first runloop
dispatch_async(dispatch_get_main_queue(), ^{
 [[FKSectionMethod sharedInstance] executeMethodsForKey:@"a"];
});
*/


@interface FKSectionMethod : NSObject

+ (instancetype)sharedInstance;

- (void)executeMethodsForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
