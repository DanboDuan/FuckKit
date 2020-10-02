//
//  NSData+FKSecurity.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*! @abstract AES 加密 key size类型
 @discussion key size要和传入的key符合
*/
typedef NS_ENUM(NSInteger, FKAESKeySize) {
    FKAESKeySizeAES128 = 0x10, /// 对应key的byte是16字节
    FKAESKeySizeAES192 = 0x18, /// 对应key的byte是24字节
    FKAESKeySizeAES256 = 0x20, /// 对应key的byte是32字节
};

@interface NSData (FKSecurity)


/*! @abstract AES 加密方法
 @param key 加密的key，这个需要和keySize对应的byte一致。如果过长，会截断；如果过短，默认用0填充
 @param keySize 参考枚举值FKAESKeySize三种选项
 @param iv 如果 iv是nil，则使用EBC模式，不为nil则使用CBC模式。iv要求16字节
 @result 加密结果，失败则返回nil
 @discussion key和keySize要对应
*/
- (nullable NSData *)fk_aesEncryptWithkey:(NSString *)key
                                   keySize:(FKAESKeySize)keySize
                                        iv:(nullable NSString *)iv;

/*! @abstract AES 加密方法
 @param keyData 加密的key，这个需要和keySize对应的byte一致。如果过长，会截断；如果过短，默认用0填充
 @param keySize 参考枚举值FKAESKeySize三种选项
 @param ivData 如果 iv是nil，则使用EBC模式，不为nil则使用CBC模式。iv要求16字节
 @result 加密结果，失败则返回nil
 @discussion key和keySize要对应
*/
- (nullable NSData *)fk_aesEncryptWithkeyData:(NSData *)keyData
                                       keySize:(FKAESKeySize)keySize
                                        ivData:(nullable NSData *)ivData;

/*! @abstract AES 解密方法
 @param key 加密的key，这个需要和keySize对应的byte一致。如果过长，会截断；如果过短，默认用0填充
 @param keySize 参考枚举值FKAESKeySize三种选项
 @param iv 如果 iv是nil，则使用EBC模式，不为nil则使用CBC模式。iv要求16字节
 @result 解密结果，失败则返回nil
 @discussion key和keySize要对应
*/
- (nullable NSData *)fk_aesDecryptwithKey:(NSString *)key
                                   keySize:(FKAESKeySize)keySize
                                        iv:(nullable NSString *)iv;

/*! @abstract AES 解密方法
 @param keyData 加密的key，这个需要和keySize对应的byte一致。如果过长，会截断；如果过短，默认用0填充
 @param keySize 参考枚举值FKAESKeySize三种选项
 @param ivData 如果 iv是nil，则使用EBC模式，不为nil则使用CBC模式。iv要求16字节
 @result 解密结果，失败则返回nil
 @discussion key和keySize要对应
*/
- (nullable NSData *)fk_aesDecryptwithKeyData:(NSData *)keyData
                                       keySize:(FKAESKeySize)keySize
                                        ivData:(nullable NSData *)ivData;

@end

NS_ASSUME_NONNULL_END
