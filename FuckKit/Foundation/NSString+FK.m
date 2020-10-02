//
//  NSString+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSString+FK.h"
#import "NSData+FK.h"
#import "NSDictionary+FK.h"

#import <CommonCrypto/CommonDigest.h>


@implementation NSString (FK)

- (NSString *)fk_trimmed {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)fk_md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] fk_md5String];
}

- (NSString *)fk_sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] fk_sha256String];
}

- (NSString *)fk_base64EncodedString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length > 0) {
        return [data base64EncodedStringWithOptions:0];
    }
    
    return nil;
}

- (NSString *)fk_base64DecodedString {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    if (data.length > 0) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (id)fk_jsonValueDecoded {
    NSError *error = nil;
    return [self fk_jsonValueDecoded:&error];
}

- (id)fk_jsonValueDecoded:(NSError *__autoreleasing *)error {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data fk_jsonValueDecoded:error];
}

+ (NSString *)fk_UUIDString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef fullStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return (__bridge_transfer NSString *)fullStr;
}

- (NSString *)fk_stringByAppendingQueryDictionary:(NSDictionary *)params {
    NSString *query = [params fk_queryString];
    if (query.length > 0) {
        if ([self containsString:@"?"]) {
            return [self stringByAppendingFormat:@"&%@",query];
        } else {
            return [self stringByAppendingFormat:@"?%@",query];
        }
    }
    
    return self;
}

- (NSDictionary *)fk_queryDictionary {
    if (self.length < 1) {
        return @{};
    }
    
    NSMutableDictionary * result = [NSMutableDictionary new];
    NSArray<NSString *> *items = [self componentsSeparatedByString:@"&"];
    
    for (NSString *item in items) {
        NSArray *pairComponents = [item componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        [result setValue:value forKey:key];
    }

    return result;
}

- (id)fk_safeJsonObject {
    return [self copy];
}

- (NSString *)fk_safeJsonObjectKey {
    return [self copy];
}

@end
