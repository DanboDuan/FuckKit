//
//  AppDelegate.m
//  RSKExample
//
//  Created by bob on 2020/5/7.
//  Copyright © 2020 rangers. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <FuckKit/NSFileManager+FK.h>
#import <FuckKit/FKSectionData.h>
#import <FuckKit/FKSectionBlock.h>
#import <FuckKit/FKSectionFunction.h>
#import <FuckKit/FKSectionMethod.h>
#import <FuckKit/FKService.h>
#import <FuckKit/FKServiceCenter.h>

#import <FuckKit/FKNotification.h>
#import <FuckKit/NSFileManager+FK.h>
#import <FuckKit/FKReachability+Cellular.h>
#import <FuckKit/FKUtility.h>

FK_STRINGS_EXPORT("key1", "value1")
FK_STRINGS_EXPORT("key1", "value2")
FK_STRINGS_EXPORT("key2", "value1")

FK_BLOCKS_EXPORT("a", ^(void) {
    printf("\na Block:test block 1");
});

FK_BLOCKS_EXPORT("a", ^(void) {
    printf("\na Block:test block 2");
});

FK_FUNCTION_EXPORT("a")(void){
    printf("\na Function:test function 1");
};

FK_FUNCTION_EXPORT("a")(void){
    printf("\na Function:test function 2");
};

void wormholeNotificationCallback(CFNotificationCenterRef center,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    NSLog(@"%@",identifier);
}

@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (strong, nonatomic) FKNotification *notification;

@end

@implementation AppDelegate

+ (void)testMethod {
    FK_METHOD_EXPORT("a")
    printf("\na Method:test Method 1");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    id<FKLogService> logger = [[FKServiceCenter sharedInstance] serviceForProtocol:@protocol(FKLogService)];
    [logger debug:@"test log"];
    
    [NSFileManager fk_homePath];
    [NSFileManager fk_documentPath];
    [NSFileManager fk_libraryPath];
    [NSFileManager fk_cachePath];
    NSArray *key1 = [FKSectionData exportedStringsForKey:@"key1"];
    NSArray *key2 = [FKSectionData exportedStringsForKey:@"key2"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[FKSectionBlock sharedInstance] executeBlocksForKey:@"a"];
        [[FKSectionFunction sharedInstance] executeFunctionsForKey:@"a"];
        [[FKSectionMethod sharedInstance] executeMethodsForKey:@"a"];
    });
    NSLog(@"%@, %@ %s",key1, key2,__func__);
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    NSString *identifier = @"test";
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    wormholeNotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    if (self.notification == nil) {
        NSURL *path = [[NSFileManager defaultManager] fk_pathForNotificationFile:@"data.lock" group:@"group.bobcat.test"];
        self.notification = [FKNotification sharedInstance];
        [self.notification startWithLockFilePath:path];
        [self.notification addObserverForName:@"Shared"
                                    withBlock:^(NSDictionary * userInfo) {
            NSLog(@"app receives notification from today: %@",userInfo);
        }];
    }
    
    [FKReachability is5GConnected];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.bgTask == UIBackgroundTaskInvalid) {
        self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            if (self.bgTask != UIBackgroundTaskInvalid) {
                [application endBackgroundTask:self.bgTask];
                self.bgTask = UIBackgroundTaskInvalid;
            }
        }];
    }
    
    [self.notification postNotification:@"Shared"
                               userInfo:@{@"from":@"app"}
                             completion:^{
        NSLog(@"app post notification to today");
    }];
}

@end
