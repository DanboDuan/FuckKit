//
//  FKReachability.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKReachability.h"
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIKit.h>

#ifndef FK_WeakSelf
#define FK_WeakSelf __weak typeof(self) wself = self
#endif

#ifndef FK_StrongSelf
#define FK_StrongSelf __strong typeof(wself) self = wself
#endif

NSString *FKNotificationReachabilityChanged = @"FKNotificationReachabilityChanged";

@interface FKReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef  reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t reachabilityQueue;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
@property (nonatomic, assign) BOOL callbackScheduled;
@property (nonatomic, assign) FKReachabilityStatus cachedStatus;
@property (nonatomic, assign) BOOL hasCachedStatus;
@property (nonatomic, assign) BOOL telephoneInfoIndeterminateStatus;

@end

static FKReachabilityStatus networkStatusForFlags(SCNetworkReachabilityFlags flags) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0){
        return FKReachabilityStatusNotReachable;
    }

    FKReachabilityStatus returnValue = FKReachabilityStatusNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        returnValue = FKReachabilityStatusReachableViaWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0)
         || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            returnValue = FKReachabilityStatusReachableViaWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        returnValue = FKReachabilityStatusReachableViaWWAN;
    }

    return returnValue;
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    FKReachability *reachability = [FKReachability sharedInstance];
    FKReachabilityStatus status = networkStatusForFlags(flags);
    if (reachability.cachedStatus != status) {
        reachability.cachedStatus = status;
        reachability.hasCachedStatus = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:FKNotificationReachabilityChanged
                                                            object:nil];
    }
}

static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (CFStringCompare(name, CFSTR("com.apple.system.config.network_change"), 0) == kCFCompareEqualTo) {
        ///  当WiFi状态发生变化时候，认为此时处于不稳定状态，蜂窝权限检测依赖了WiFi的IP地址做快速检测
        ///  因为无法获取系统开关具体是什么），需要临时禁用
        /// 等待1秒后标记取消，这段时间内永远返回notDetermined，之后才能正常判定，如果有更好方法请联系我
        [FKReachability sharedInstance].telephoneInfoIndeterminateStatus = YES;
        // 注：目前测试，这个Darwin的通知在mainQueue触发，线程安全，以后如果有变化再说
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [FKReachability sharedInstance].telephoneInfoIndeterminateStatus = NO;
        });
    }
}

@implementation FKReachability

+ (instancetype)sharedInstance  {
    static FKReachability * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sa_len = sizeof(zeroAddress);
        zeroAddress.sa_family = AF_INET;

        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                                                                       &zeroAddress);
        sharedInstance = [[self alloc] initWithReachabilityRef:reachability];
        if (reachability != NULL) {
            CFRelease(reachability);
        }
    });

    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopNotifier];
    SCNetworkReachabilityRef reachabilityRef = self.reachabilityRef;
    if (reachabilityRef != NULL) {
        CFRelease(reachabilityRef);
        self.reachabilityRef = NULL;
    }
}

- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef {
    self = [super init];
    if (self) {
        if (reachabilityRef != NULL) {
            self.reachabilityRef = CFRetain(reachabilityRef);
        } else {
            self.reachabilityRef = NULL;
        }
        self.cachedStatus = FKReachabilityStatusNotReachable;
        self.hasCachedStatus = NO;
        self.reachabilityQueue = dispatch_queue_create("com.fk.reachability", DISPATCH_QUEUE_SERIAL);
        self.callbackQueue = dispatch_queue_create("com.fk.callback", DISPATCH_QUEUE_SERIAL);
        self.callbackScheduled = NO;
        self.telephoneInfoIndeterminateStatus = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onWillEnterForeground) name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        // 监听WiFi硬件开关变化的Darwin通知，这个按照Apple的论坛说法是Public API
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                        NULL, // observer
                                        onNotifyCallback, // callback
                                        CFSTR("com.apple.system.config.network_change"), // event name
                                        NULL, // object
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }

    return self;
}

#pragma mark - Start and stop notifier

- (void)startNotifier {
    FK_WeakSelf;
    dispatch_async(self.reachabilityQueue, ^{
        FK_StrongSelf;
        if (self.callbackScheduled) {
            return;
        }
        SCNetworkReachabilityRef reachabilityRef = self.reachabilityRef;
        if (reachabilityRef == NULL) {
            return;
        };
        [self readReachabilityStatus];
        /// 耗时方法
        if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, NULL)) {
            if(SCNetworkReachabilitySetDispatchQueue(reachabilityRef, self.callbackQueue)) {
                self.callbackScheduled = YES;
            } else {
                SCNetworkReachabilitySetCallback(reachabilityRef, NULL,NULL);
            }
        }
    });
}

- (void)stopNotifier {
    SCNetworkReachabilityRef reachabilityRef = self.reachabilityRef;
    if (reachabilityRef == NULL) {
        return;
    }
    dispatch_sync(self.reachabilityQueue, ^{
        if (self.callbackScheduled) {
            SCNetworkReachabilitySetCallback(reachabilityRef, NULL, NULL);
            SCNetworkReachabilitySetDispatchQueue(reachabilityRef, NULL);
            self.callbackScheduled = NO;
        }
    });
    self.hasCachedStatus = NO;
}

- (void)onDidEnterBackground {
    [self stopNotifier];
    
}

- (void)onWillEnterForeground {
    [self startNotifier];
}

- (void)readReachabilityStatus {
    if (self.cachedStatus != FKReachabilityStatusNotReachable) {
        return;
    }
    
    SCNetworkReachabilityFlags flags;
    /// 弱网情况下很耗时
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        self.cachedStatus = networkStatusForFlags(flags);
        self.hasCachedStatus = YES;
    }
}

- (BOOL)shouldUpdateCachedStatus {
    return !self.hasCachedStatus || self.cachedStatus == FKReachabilityStatusNotReachable;
}

/// only fist time
/// 后面都依赖callback回调更新
- (FKReachabilityStatus)currentReachabilityStatus {
    if (![self shouldUpdateCachedStatus]) {
        return self.cachedStatus;
    }
    
    [self readReachabilityStatus];
    
    return self.cachedStatus;
}

@end
