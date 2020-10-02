//
//  FKSectionData.h
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "FKMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _FKString {
    const char *key;
    const char *value;
} FKString;

#define FKStringUniqueIdentifier FKIdentifier(__FKString, __COUNTER__)

#define FK_STRINGS_EXPORT(key, value) \
FKSectionNameData(__FKString) \
static const FKString FKStringUniqueIdentifier = (FKString){key, value};

/**
 e.g
 to define values:
 FK_STRINGS_EXPORT("key1", "value1")
 FK_STRINGS_EXPORT("key1", "value2")
 FK_STRINGS_EXPORT("key2", "value1")
 
 to get values:
 NSArray *key1 = [FKSectionData exportedStringsForKey:@"key1"];
 NSArray *key2 = [FKSectionData exportedStringsForKey:@"key2"];
 */

/// lazy load
@interface FKSectionData : NSObject

+ (nullable NSArray<NSString *> *)exportedStringsForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
