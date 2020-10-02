//
//  FKReachability+Cellular.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKReachability+Cellular.h"
#import "FKCellular.h"
#import <CoreTelephony/CTCarrier.h>

@implementation FKReachability (Cellular)

+ (BOOL)isNetworkConnected {
    FKReachabilityStatus status = [[FKReachability sharedInstance] currentReachabilityStatus];
    return status == FKReachabilityStatusReachableViaWiFi || status == FKReachabilityStatusReachableViaWWAN;
}

+ (FKCellularConnectionType)cellularConnectionType {
    FKCellularServiceType service = [[FKCellular sharedInstance] currentDataServiceType];
    
    return [[FKCellular sharedInstance] cellularConnectionTypeForService:service];
}

+ (BOOL)is3GConnected {
    FKCellularServiceType service = [[FKCellular sharedInstance] currentDataServiceType];
    
    return [self is3GConnectedForService:service];
}

+ (BOOL)is4GConnected {
    FKCellularServiceType service = [[FKCellular sharedInstance] currentDataServiceType];
    
    return [self is4GConnectedForService:service];
}

+ (NSString *)carrierName {
    FKCellularServiceType service = [[FKCellular sharedInstance] currentDataServiceType];

    return [self carrierNameForService:service];
}

+ (NSString *)carrierMCC {
    FKCellularServiceType service = [[FKCellular sharedInstance] currentDataServiceType];

    return [self carrierMCCForService:service];
}

+ (NSString *)carrierMNC {
    FKCellularServiceType service = [[FKCellular sharedInstance] currentDataServiceType];
    
    return [self carrierMNCForService:service];
}

+ (FKCellularConnectionType)cellularConnectionTypeForService:(FKCellularServiceType)service {
    
    return [[FKCellular sharedInstance] cellularConnectionTypeForService:service];
}

+ (BOOL)is3GConnectedForService:(FKCellularServiceType)service {
    FKCellularConnectionType connectionType = [[FKCellular sharedInstance] cellularConnectionTypeForService:service];
    
    return connectionType == FKCellularConnectionType3G;
}

+ (BOOL)is4GConnectedForService:(FKCellularServiceType)service {
    FKCellularConnectionType connectionType = [[FKCellular sharedInstance] cellularConnectionTypeForService:service];
    
    return connectionType == FKCellularConnectionType4G;
}

+ (NSString *)carrierNameForService:(FKCellularServiceType)service {
    CTCarrier *carrier =[[FKCellular sharedInstance] carrierForService:service];

    return carrier.carrierName;
}

+ (NSString *)carrierMCCForService:(FKCellularServiceType)service {
    CTCarrier *carrier =[[FKCellular sharedInstance] carrierForService:service];

    return carrier.mobileCountryCode;
}

+ (NSString *)carrierMNCForService:(FKCellularServiceType)service {
    CTCarrier *carrier =[[FKCellular sharedInstance] carrierForService:service];

    return carrier.mobileNetworkCode;
}

@end
