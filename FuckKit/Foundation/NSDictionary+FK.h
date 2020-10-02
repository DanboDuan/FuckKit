//
//  NSDictionary+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (FK)

- (id)fk_safeJsonObject;
- (nullable NSString *)fk_queryString;

- (BOOL)fk_boolValueForKey:(NSString *)key;
- (double)fk_doubleValueForKey:(NSString *)key;
- (NSInteger)fk_integerValueForKey:(NSString *)key;
- (long long)fk_longlongValueForKey:(NSString *)key;
- (nullable NSString *)fk_stringValueForKey:(NSString *)key;
- (nullable NSDictionary *)fk_dictionaryValueForKey:(NSString *)key;
- (nullable NSMutableDictionary *)fk_mutableDictionaryValueForKey:(NSString *)key;
- (nullable NSArray *)fk_arrayValueForKey:(NSString *)key;
- (nullable NSMutableArray *)fk_mutableArrayValueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
