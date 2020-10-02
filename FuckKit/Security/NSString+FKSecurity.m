//
//  NSString+FKSecurity.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSString+FKSecurity.h"

@implementation NSString (FKSecurity)

- (NSString *)fk_aesEncryptWithkey:(NSString *)key
                            keySize:(FKAESKeySize)keySize
                                 iv:(NSString *)iv {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [data fk_aesEncryptWithkey:key
                                         keySize:keySize
                                              iv:iv];

    return [result base64EncodedStringWithOptions:0];
}

- (NSString *)fk_aesDecryptwithKey:(NSString *)key
                            keySize:(FKAESKeySize)keySize
                                 iv:(NSString *)iv {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *result = [data fk_aesDecryptwithKey:key
                                         keySize:keySize
                                              iv:iv];
    if (result == nil) {
        return  nil;
    }

    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

@end
