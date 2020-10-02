//
//  FKReachability+Authorization.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKReachability.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FKNetworkAuthorizationStatus) {
    /// 程序无法判断出 App 的网络权限设置
    FKNetworkAuthorizationStatusNotDetermined = 0,
    /// App 未开启蜂窝数据网络权限
    FKNetworkAuthorizationStatusCellularNotPermitted,
    /// App 未开启无线局域网与蜂窝移动网络权限，此项仅可能在国行 iPhone 手机上出现
    FKNetworkAuthorizationStatusWLANAndCellularNotPermitted
};

@interface FKReachability (Authorization)

+ (FKNetworkAuthorizationStatus)currentAuthorizationStatus;

@end

NS_ASSUME_NONNULL_END
