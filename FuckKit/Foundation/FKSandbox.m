//
//  FKSandbox.m
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import "FKSandbox.h"

@implementation FKSandbox

+ (NSString *)appName {
    static NSString *appName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    });

    return appName;
}

+ (NSString *)appDisplayName {
    static NSString *appName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        if (appName == nil) {
            appName = [self appName];
        }
    });

    return appName;
}

+ (NSString *)appVersion {
    static NSString *versionName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];;
    });

    return versionName;
}

+ (NSString *)appBuildVersion {
    static NSString *versionName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];;
    });

    return versionName;
}

+ (NSString *)bundleID {
    static NSString *versionName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];;
    });

    return versionName;
}

@end
