//
//  FKSectionFunction.h
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "FKMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _FKFunction {
    const char *key;
    const void (*function)(void);
} FKFunction;

#define FKFunctionIdentifier(COUNTER) FKIdentifier(__FKFunction, COUNTER)
#define FKFunctionDataIdentifier FKIdentifier(__FKFunction_, __COUNTER__)

#define _FK_FUNCTION_EXPORT(key, COUNTER) \
__attribute__((used, no_sanitize_address)) static void FKFunctionIdentifier(COUNTER)(void);\
FKSectionNameData(__FKFunction) \
static const FKFunction FKFunctionDataIdentifier = (FKFunction){key, (void *)(&FKFunctionIdentifier(COUNTER))}; \
__attribute__((used, no_sanitize_address)) static void FKFunctionIdentifier(COUNTER)


#define FK_FUNCTION_EXPORT(key) \
_FK_FUNCTION_EXPORT(key, __COUNTER__)

/**
e.g.
1. define function
FK_FUNCTION_EXPORT("a")(void){
    printf("\nFunction:test function a");
}

2.call function, should not be in the first runloop
dispatch_async(dispatch_get_main_queue(), ^{
 [[FKSectionFunction sharedInstance] executeFunctionsForKey:@"a"];
});
*/

@interface FKSectionFunction : NSObject

+ (instancetype)sharedInstance;

- (void)executeFunctionsForKey:(NSString *)key;
/// empty method for swift
- (void)executeSwiftFunctionsForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
