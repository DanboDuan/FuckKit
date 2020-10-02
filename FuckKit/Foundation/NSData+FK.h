//
//  NSData+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (FK)

- (NSString *)fk_md5String;
- (NSString *)fk_sha256String;
- (NSString *)fk_hexString;
- (nullable id)fk_jsonValueDecoded;
- (nullable id)fk_jsonValueDecoded:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
