//
//  NSMutableDictionary+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSMutableDictionary+FK.h"
#import "FKMacros.h"

@implementation NSMutableDictionary (FK)

- (void)fk_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (aKey == nil) {
        return;
    }
    
    if (anObject == nil) {
        [self removeObjectForKey:aKey];
    } else {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)fk_skipMerge:(NSDictionary *)value {
    if (FK_isNotDictOrEmptyDict(value)) {
        return;
    }
    
    [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *origin = [self objectForKey:key];
        if ([origin isKindOfClass:[NSMutableDictionary class]]) {
            [origin fk_skipMerge:obj];
        } else if ([origin isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *merge = [origin mutableCopy];
            [merge fk_skipMerge:obj];
            [self setObject:merge forKey:key];
        } else if (origin == nil) {
            [self setObject:obj forKey:key];
        }
    }];
}

- (void)fk_overrideMerge:(NSDictionary *)value {
    if (FK_isNotDictOrEmptyDict(value)) {
        return;
    }
    
    [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *origin = [self objectForKey:key];
        if ([origin isKindOfClass:[NSMutableDictionary class]]) {
            [origin fk_overrideMerge:obj];
        } else if ([origin isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *merge = [origin mutableCopy];
            [merge fk_overrideMerge:obj];
            [self setObject:merge forKey:key];
        } else {
            [self setObject:obj forKey:key];
        }
    }];
}

@end
