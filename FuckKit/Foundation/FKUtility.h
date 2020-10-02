//
//  FKUtility.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKUtility : NSObject

+ (NSTimeInterval)currentInterval; /// return [[NSDate date] timeIntervalSince1970];
+ (long long)currentIntervalMS; /// return currentInterval * 1000
+ (NSCharacterSet *)URLQueryAllowedCharacterSet;

@end

NS_ASSUME_NONNULL_END
