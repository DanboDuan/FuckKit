//
//  FKReachability.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int32_t, FKReachabilityStatus) {
    FKReachabilityStatusNotReachable    = 0,
    FKReachabilityStatusReachableViaWiFi,
    FKReachabilityStatusReachableViaWWAN
};

FOUNDATION_EXTERN NSString *FKNotificationReachabilityChanged;

@interface FKReachability : NSObject

@property (nonatomic, assign, readonly) BOOL telephoneInfoIndeterminateStatus;

+ (instancetype)sharedInstance;

- (void)startNotifier;

- (FKReachabilityStatus)currentReachabilityStatus;

@end

NS_ASSUME_NONNULL_END
