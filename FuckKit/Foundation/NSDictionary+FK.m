//
//  NSDictionary+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSDictionary+FK.h"
#import "NSObject+FK.h"
#import "FKUtility.h"

@implementation NSDictionary (FK)

- (id)fk_safeJsonObject {
    NSMutableDictionary *safeEncodingDict = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        id safeKey = [key fk_safeJsonObjectKey];
        id safeValue = [value fk_safeJsonObject];
        if (safeKey!= nil && safeValue != nil) {
            [safeEncodingDict setObject:safeValue forKey:safeKey];
        }
    }];
    
    return safeEncodingDict.copy;
}

- (NSString *)fk_queryString {
    if (self.count < 1) {
        return nil;
    }
    
    NSCharacterSet *characterSet = [FKUtility URLQueryAllowedCharacterSet];
    NSMutableArray *keyValuePairs = [NSMutableArray array];
    for (id key in self) {
        NSString *queryKey = [[key description] stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSString *queryValue = [[self[key] description] stringByAddingPercentEncodingWithAllowedCharacters:characterSet];

        [keyValuePairs addObject:[NSString stringWithFormat:@"%@=%@", queryKey, queryValue]];
    }

    return [keyValuePairs componentsJoinedByString:@"&"];
}

- (BOOL)fk_boolValueForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }

    return NO;
}

- (double)fk_doubleValueForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value doubleValue];
    }

    if ([value isKindOfClass:[NSString class]]) {
        return [value doubleValue];
    }

    return 0.0;
}

- (NSInteger)fk_integerValueForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }

    if ([value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }

    return 0;
}

- (long long)fk_longlongValueForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value longLongValue];
    }

    if ([value isKindOfClass:[NSString class]]) {
        return [value longLongValue];
    }

    return 0;
}

- (NSString *)fk_stringValueForKey:(NSString *)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return nil;
}

- (NSDictionary *)fk_dictionaryValueForKey:(NSString *)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSMapTable class]]) {
        NSMapTable *table = value;
        return table.dictionaryRepresentation;
    }

    return nil;
}

- (NSMutableDictionary *)fk_mutableDictionaryValueForKey:(NSString *)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSMutableDictionary class]]) {
        return value;
    }

    return nil;
}


- (NSArray *)fk_arrayValueForKey:(NSString *)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSHashTable class]]) {
        NSHashTable *table = value;
        return table.allObjects;
    }
    
    if ([value isKindOfClass:[NSSet class]]) {
        NSSet *table = value;
        return table.allObjects;
    }

    return nil;
}

- (NSMutableArray *)fk_mutableArrayValueForKey:(NSString *)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSMutableArray class]]) {
        return value;
    }

    return nil;
}

@end
