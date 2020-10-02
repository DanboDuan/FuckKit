//
//  FKConnection.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络状态
typedef NS_ENUM(NSInteger, FKNetworkConnectionType) {
    /// 初始状态
    BDAutoTrackNetworkNone = -1,
    /// 无网络连接
    FKNetworkConnectionTypeNone = 0,
    /// 移动网络连接
    FKNetworkConnectionTypeMobile = 1,
    /// 2G网络连接
    FKNetworkConnectionType2G = 2,
    /// 3G网络连接
    FKNetworkConnectionType3G = 3,
    /// wifi网络连接
    FKNetworkConnectionTypeWiFi = 4,
    /// 4G网络连接
    FKNetworkConnectionType4G = 5
};

@interface FKConnection : NSObject

@property (nonatomic, assign, readonly) FKNetworkConnectionType connection;
@property (nonatomic, copy, readonly) NSString *connectMethodName;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
