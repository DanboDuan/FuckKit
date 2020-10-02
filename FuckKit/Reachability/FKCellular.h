//
//  FKCellular.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CTTelephonyNetworkInfo, CTCarrier, CTCellularData;

/// SIM网络状态
typedef NS_ENUM(NSInteger, FKCellularConnectionType) {
    /// 无网络连接
    FKCellularConnectionTypeNone = 0,
    /// 未知移动网络
    FKCellularConnectionTypeUnknown,
    /// 2G网络连接
    FKCellularConnectionType2G,
    /// 3G网络连接
    FKCellularConnectionType3G,
    /// 4G网络连接
    FKCellularConnectionType4G
};

typedef NS_ENUM(NSInteger, FKCellularServiceType) {
    FKCellularServiceTypeNone = 0,         /// 无卡
    FKCellularServiceTypePrimary = 1,      /// 主卡状态
    FKCellularServiceTypeSecondary = 2,    /// 副卡状态
};

@interface FKCellular : NSObject

@property (class ,nonatomic, strong, readonly) CTCellularData *cellularData;

+ (instancetype)sharedInstance;

/// 返回指定卡信息
/// 如果指定副卡不存在，返回主卡信息
- (FKCellularConnectionType)cellularConnectionTypeForService:(FKCellularServiceType)service;
- (CTCarrier *)carrierForService:(FKCellularServiceType)service;
- (FKCellularServiceType)currentDataServiceType;/// 返回当前流量卡类型

@end

NS_ASSUME_NONNULL_END
