//
//  NSObject+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSObject+FK.h"

@implementation NSObject (FK)

- (id)fk_safeJsonObject {
    return [self description];
}

- (NSString *)fk_safeJsonObjectKey {
    return [self description];
}

- (NSString *)fk_jsonStringEncoded {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:kNilOptions
                                                     error:nil];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)fk_jsonStringEncodedForJS {
    NSString *string = [self fk_jsonStringEncoded];
    string = [string stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    string = [string stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];

    return string;
}

@end
