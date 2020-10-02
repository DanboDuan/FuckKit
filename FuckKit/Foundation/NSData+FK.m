//
//  NSData+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSData+FK.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (FK)

- (NSString *)fk_md5String {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)fk_sha256String {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (unsigned int)self.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)fk_hexString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (dataBuffer == NULL) {
        return [NSString string];
    }
        
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

- (id)fk_jsonValueDecoded {
    NSError *error = nil;
    return [self fk_jsonValueDecoded:&error];
}

- (id)fk_jsonValueDecoded:(NSError *__autoreleasing *)error {
    id value = [NSJSONSerialization JSONObjectWithData:self
                                               options:kNilOptions
                                                 error:error];
    return value;
}

@end
