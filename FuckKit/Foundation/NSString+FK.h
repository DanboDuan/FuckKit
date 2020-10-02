//
//  NSString+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FK)

- (NSString *)fk_trimmed;
- (NSString *)fk_md5String;
- (NSString *)fk_sha256String;
- (nullable NSString *)fk_base64EncodedString;
- (nullable NSString *)fk_base64DecodedString;
- (nullable id)fk_jsonValueDecoded;
- (nullable id)fk_jsonValueDecoded:(NSError *__autoreleasing *)error;

- (NSString *)fk_stringByAppendingQueryDictionary:(NSDictionary *)params;
- (NSDictionary *)fk_queryDictionary;

+ (NSString *)fk_UUIDString;

- (id)fk_safeJsonObject;
- (NSString *)fk_safeJsonObjectKey;

@end

NS_ASSUME_NONNULL_END
