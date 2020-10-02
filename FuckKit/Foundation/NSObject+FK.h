//
//  NSObject+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (FK)

- (id)fk_safeJsonObject;
- (NSString *)fk_safeJsonObjectKey;
- (nullable NSString *)fk_jsonStringEncoded;
- (nullable NSString *)fk_jsonStringEncodedForJS;

@end

NS_ASSUME_NONNULL_END
