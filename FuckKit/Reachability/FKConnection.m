//
//  FKConnection.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKConnection.h"
#import "FKReachability.h"
#import "FKCellular.h"

@interface FKConnection ()

@property (nonatomic, assign) FKNetworkConnectionType connection;
@property (nonatomic, copy) NSString *connectMethodName;

@end

@implementation FKConnection

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static FKConnection *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onConnectionChanged)
                                                     name:FKNotificationReachabilityChanged
                                                   object:nil];
        [self onConnectionChanged];
    }

    return self;
}

- (FKNetworkConnectionType)cellularConnection {
    FKCellularServiceType serviceType = [[FKCellular sharedInstance] currentDataServiceType];
    FKCellularConnectionType connectionType = [[FKCellular sharedInstance] cellularConnectionTypeForService:serviceType];
    
    switch (connectionType) {
        case FKCellularConnectionType4G:
            return FKNetworkConnectionType4G;
        case FKCellularConnectionType3G:
            return FKNetworkConnectionType3G;
        case FKCellularConnectionType2G:
            return FKNetworkConnectionType2G;
        case FKCellularConnectionTypeUnknown:
            return FKNetworkConnectionTypeMobile;
        case FKCellularConnectionTypeNone:
            return FKNetworkConnectionTypeNone;
    }
}

- (void)onConnectionChanged {
    FKReachabilityStatus status = [[FKReachability sharedInstance] currentReachabilityStatus];

    switch (status) {
        case FKReachabilityStatusNotReachable:
            self.connection = FKNetworkConnectionTypeNone;
            break;
        case FKReachabilityStatusReachableViaWiFi:
            self.connection = FKNetworkConnectionTypeWiFi;
            break;
        case FKReachabilityStatusReachableViaWWAN:
            self.connection = [self cellularConnection];
            break;

    }

    switch (self.connection) {
        case FKNetworkConnectionTypeWiFi:
            self.connectMethodName = @"WIFI";
            break;
        case FKNetworkConnectionType2G:
            self.connectMethodName = @"2G";
            break;
        case FKNetworkConnectionType3G:
            self.connectMethodName = @"3G";
            break;
        case FKNetworkConnectionType4G:
            self.connectMethodName = @"4G";
            break;
        case FKNetworkConnectionTypeMobile:
            self.connectMethodName = @"mobile";
            break;
        default:
            self.connectMethodName = @"";
            break;
    }
}


@end
