//
//  FKReachability+Cellular.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKReachability.h"
#import "FKCellular.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKReachability (Cellular)

+ (BOOL)isNetworkConnected;

/// 优先返回流量卡状态，其次是主卡状态
+ (FKCellularConnectionType)cellularConnectionType;
+ (BOOL)is3GConnected;
+ (BOOL)is4GConnected;
+ (nullable NSString*)carrierName;
+ (nullable NSString*)carrierMCC;
+ (nullable NSString*)carrierMNC;

// 返回指定卡 状态
+ (FKCellularConnectionType)cellularConnectionTypeForService:(FKCellularServiceType)service;
+ (BOOL)is3GConnectedForService:(FKCellularServiceType)service;
+ (BOOL)is4GConnectedForService:(FKCellularServiceType)service;
+ (NSString *)carrierNameForService:(FKCellularServiceType)service;
+ (NSString *)carrierMCCForService:(FKCellularServiceType)service;
+ (NSString *)carrierMNCForService:(FKCellularServiceType)service;

@end

NS_ASSUME_NONNULL_END
