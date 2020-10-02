//
//  FKCellular.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKCellular.h"
#import "FKReachability.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCellularData.h>

#ifndef FK_Lock
#define FK_Lock(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef FK_Unlock
#define FK_Unlock(lock) dispatch_semaphore_signal(lock);
#endif

static FKCellularConnectionType ParseRadioAccessTechnology(NSString * tech) {
    if (tech.length < 1) return FKCellularConnectionTypeNone;
    
    if ([tech isEqualToString:CTRadioAccessTechnologyLTE]) {
        return FKCellularConnectionType4G;
    }

    if ([tech isEqualToString:CTRadioAccessTechnologyWCDMA]
        || [tech isEqualToString:CTRadioAccessTechnologyHSDPA]
        || [tech isEqualToString:CTRadioAccessTechnologyHSUPA]
        || [tech isEqualToString:CTRadioAccessTechnologyCDMA1x]
        || [tech isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
        || [tech isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
        || [tech isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
        || [tech isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return FKCellularConnectionType3G;
    }

    if ([tech isEqualToString:CTRadioAccessTechnologyGPRS] ||[tech isEqualToString:CTRadioAccessTechnologyEdge]) {
        return FKCellularConnectionType2G;
    }
    
    // Maybe 5G? :)
    return FKCellularConnectionTypeUnknown;
}

@interface FKCellular ()<CTTelephonyNetworkInfoDelegate>

@property (class, nonatomic, strong, readonly) CTTelephonyNetworkInfo *telephoneInfo;
@property (nonatomic, assign) BOOL usingCellularServiceAPI;
@property (nonatomic, strong) dispatch_semaphore_t serviceCurrentRadioAccessTechnologyLock;
@property (nonatomic, strong) dispatch_semaphore_t serviceSubscriberCellularProvidersLock;

///
@property (nonatomic, assign) NSUInteger cellularCount;
@property (nonatomic, assign) FKCellularConnectionType primaryCellularConnectionType;
@property (nonatomic, assign) FKCellularConnectionType secondaryCellularConnectionType;
@property (nonatomic, copy) NSString *primaryRadioAccessTechnology;
@property (nonatomic, copy) NSString *secondaryRadioAccessTechnology;

///
@property (nonatomic, copy) NSString *primaryIdentifier;
@property (nonatomic, copy) NSString *secondaryIdentifier;
@property (nonatomic, strong) CTCarrier *primaryCarrier;
@property (nonatomic, strong) CTCarrier *secondaryCarrier;

///
@property(nonatomic, copy) NSString *dataServiceIdentifier;

@end

@implementation FKCellular

+ (CTTelephonyNetworkInfo *)telephoneInfo {
    static dispatch_once_t onceToken;
    static CTTelephonyNetworkInfo *telephoneInfo = nil;
    dispatch_once(&onceToken, ^{
        telephoneInfo = [CTTelephonyNetworkInfo new];
    });
    
    return telephoneInfo;
}

+ (CTCellularData *)cellularData {
    static dispatch_once_t onceToken;
    static CTCellularData *cellularData = nil;
    dispatch_once(&onceToken, ^{
        cellularData = [CTCellularData new];
    });
    
    return cellularData;
}

+ (instancetype)sharedInstance {
    static FKCellular *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });

    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.usingCellularServiceAPI = NO;
        self.cellularCount = 1;
        self.primaryCellularConnectionType = FKCellularConnectionTypeNone;
        self.secondaryCellularConnectionType = FKCellularConnectionTypeNone;
        self.primaryRadioAccessTechnology = nil;
        self.secondaryRadioAccessTechnology = nil;
        self.primaryIdentifier = nil;
        self.secondaryIdentifier = nil;
        self.primaryCarrier = nil;
        self.secondaryCarrier = nil;
        self.serviceCurrentRadioAccessTechnologyLock = dispatch_semaphore_create(1);
        self.serviceSubscriberCellularProvidersLock = dispatch_semaphore_create(1);
        self.dataServiceIdentifier = nil;
        [self startWork];
    }
    
    return self;
}

- (void)startWork {
    /// 兼容Hack，仅仅在iOS 12.0.0 Beta版本，不包含双卡API，单独Hack处理，待iOS 12普及率上来后删除
    /// 最新发现，单卡iPhone在iOS 12.0版本上，serviceSubscriberCellularProviders方法返回nil，因此也需要过滤，指定到iOS 12.1+
    if (@available(iOS 12.1, *)) {
        self.usingCellularServiceAPI = YES;
        [self updateServiceCellularConnectionType];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onServiceRadioAccessTechnologyDid)
                                                     name:CTServiceRadioAccessTechnologyDidChangeNotification
                                                   object:nil];
        [self updateCarrierProviders];
        FKCellular.telephoneInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = ^(NSString *serviceIdentifier) {
            [[FKCellular sharedInstance] updateCarrierProviders];
        };
    } else {
        [self updateCellularConnectionType];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRadioAccessTechnologyDidChange)
                                                     name:CTRadioAccessTechnologyDidChangeNotification
                                                   object:nil];
        self.primaryCarrier = FKCellular.telephoneInfo.subscriberCellularProvider;
        FKCellular.telephoneInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
            [FKCellular sharedInstance].primaryCarrier = carrier;
        };
    }
    
    if (@available (iOS 13, *)) {
        self.dataServiceIdentifier = [FKCellular.telephoneInfo dataServiceIdentifier];
        FKCellular.telephoneInfo.delegate = self;
    }
}

- (void)onRadioAccessTechnologyDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCellularConnectionType];
    });
}

- (void)onServiceRadioAccessTechnologyDid API_AVAILABLE(ios(12.0)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateServiceCellularConnectionType];
    });
}

- (void)updateCellularConnectionType {
    if (FKCellular.telephoneInfo == nil) {
        return;
    }
    
    NSString *currentRadioAccessTechnology = [FKCellular.telephoneInfo.currentRadioAccessTechnology copy];
    if (currentRadioAccessTechnology == nil
        || [self.primaryRadioAccessTechnology isEqualToString:currentRadioAccessTechnology]) {
        return;
    }
    self.primaryRadioAccessTechnology = currentRadioAccessTechnology;
    self.primaryCellularConnectionType = ParseRadioAccessTechnology(currentRadioAccessTechnology);
}


- (void)updateServiceCellularConnectionType API_AVAILABLE(ios(12.0)) {
    if (FKCellular.telephoneInfo == nil) {
        return;
    }
    
    FK_Lock(self.serviceCurrentRadioAccessTechnologyLock);
    NSDictionary *serviceCurrentRadioAccessTechnology = [FKCellular.telephoneInfo.serviceCurrentRadioAccessTechnology copy];
    FK_Unlock(self.serviceCurrentRadioAccessTechnologyLock);
    NSArray<NSString *> *keys = serviceCurrentRadioAccessTechnology.allKeys;
    self.cellularCount = keys.count;
    if (keys.count < 1) {
        return;
    }
    /// 使用sort可能会有坑，目前不怕，以后再改
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSString * primaryIdentifier = [keys firstObject];
    NSString * seconaryIdentifier = [keys lastObject];
    NSString *primaryRadioAccessTechnology = [serviceCurrentRadioAccessTechnology objectForKey:primaryIdentifier];
    NSString *secondaryRadioAccessTechnology = [serviceCurrentRadioAccessTechnology objectForKey:seconaryIdentifier];
    
    if (![self.primaryRadioAccessTechnology isEqualToString:primaryRadioAccessTechnology]) {
        self.primaryRadioAccessTechnology = primaryRadioAccessTechnology;
        self.primaryCellularConnectionType = ParseRadioAccessTechnology(primaryRadioAccessTechnology);
    }
    
    if (self.cellularCount > 1
        && ![self.secondaryRadioAccessTechnology isEqualToString:secondaryRadioAccessTechnology]) {
        self.secondaryRadioAccessTechnology = secondaryRadioAccessTechnology;
        self.secondaryCellularConnectionType = ParseRadioAccessTechnology(secondaryRadioAccessTechnology);
    }
}

#pragma mark dataService

/// 当前流量卡 identifier
- (void)dataServiceIdentifierDidChange:(NSString *)identifier {
    self.dataServiceIdentifier = identifier;
}

#pragma mark CTCarrier

- (void)updateCarrierProviders API_AVAILABLE(ios(12.0)) {
    if (FKCellular.telephoneInfo == nil) {
        return;
    }
    
    FK_Lock(self.serviceSubscriberCellularProvidersLock);
    NSDictionary *serviceSubscriberCellularProviders = [FKCellular.telephoneInfo.serviceSubscriberCellularProviders copy];
    FK_Unlock(self.serviceSubscriberCellularProvidersLock);
    NSArray<NSString *> *keys = serviceSubscriberCellularProviders.allKeys;
    self.cellularCount = keys.count;
    if (keys.count < 1) {
        return;
    }
    
    NSString * primaryIdentifier = [keys firstObject];
    self.primaryIdentifier = primaryIdentifier;
    self.primaryCarrier = [serviceSubscriberCellularProviders objectForKey:primaryIdentifier];
    
    if (self.cellularCount > 1) {
        NSString * seconaryIdentifier = [keys lastObject];
        self.secondaryIdentifier = seconaryIdentifier;
        self.secondaryCarrier = [serviceSubscriberCellularProviders objectForKey:seconaryIdentifier];
    }
}

#pragma mark public API

- (FKCellularConnectionType)cellularConnectionTypeForService:(FKCellularServiceType)service {
    if (self.usingCellularServiceAPI
        && service == FKCellularServiceTypeSecondary
        && self.cellularCount > 1) {
        return self.secondaryCellularConnectionType;
    } else {
        return self.primaryCellularConnectionType;
    }
}

- (CTCarrier *)carrierForService:(FKCellularServiceType)service {
    if (self.usingCellularServiceAPI
        && service == FKCellularServiceTypeSecondary
        && self.cellularCount > 1) {
        return self.secondaryCarrier;
    } else {
        return self.primaryCarrier;
    }
}

- (FKCellularServiceType)currentDataServiceType {
    if (self.cellularCount < 1) {
        return FKCellularServiceTypeNone;
    }
    
    if (self.usingCellularServiceAPI
        && self.secondaryIdentifier != nil
        && [self.dataServiceIdentifier isEqualToString:self.secondaryIdentifier]) {
        
        return FKCellularServiceTypeSecondary;
    }
    
    return FKCellularServiceTypePrimary;
}

@end
