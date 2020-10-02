//
//  FKUtility.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKUtility.h"

@implementation FKUtility

+ (NSTimeInterval)currentInterval {
    return [[NSDate date] timeIntervalSince1970];
}

+ (long long)currentIntervalMS {
    return [self currentInterval] * 1000;
}

+ (NSCharacterSet *)URLQueryAllowedCharacterSet {
    static NSCharacterSet *characterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *set = [NSMutableCharacterSet new];
        [set formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        [set addCharactersInString:@"$-_.+!*'(),"];
        characterSet = set;
    });

    return characterSet;
}

@end
