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

FOUNDATION_EXTERN uint64_t FKCurrentMachTime(void);
FOUNDATION_EXTERN double FKMachTimeToSecs(uint64_t time);
FOUNDATION_EXTERN long long FKTimeMillisecond(void);

NS_ASSUME_NONNULL_END
