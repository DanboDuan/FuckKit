//
//  FKDevice+IDFA.m
//  FuckKit
//
//  Created by bob on 2020/5/25.
//

#import "FKDevice+IDFA.h"
#import <AdSupport/AdSupport.h>

@implementation FKDevice (IDFA)

+ (NSString *)IDFA {
    static NSString *IDFAString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IDFAString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    });

    return IDFAString;
}

@end
