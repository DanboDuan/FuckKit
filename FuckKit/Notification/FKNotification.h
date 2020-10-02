//
//  FKNotification.h
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FKNotificationBlock)(NSDictionary *_Nullable userInfo);

/**
 if (self.notification == nil) {
     NSURL *path = [[NSFileManager defaultManager] fk_pathForNotificationFile:@"data.lock" group:@"group.xxx"];
     self.notification = [FKNotification sharedInstance];
     [self.notification startWithLockFilePath:path];
     [self.notification addObserverForName:@"name"
                                 withBlock:^(NSDictionary * userInfo) {
         NSLog(@"today receives notification from app: %@",userInfo);
     }];
 }
 [self.notification postNotification:@"name"
                            userInfo:@{@"from":@"today"}
                          completion:^{
     NSLog(@"today post notification to app");
 }];
 */
@interface FKNotification : NSObject

+ (instancetype)sharedInstance;

/**
 path should be in app group
 */
- (void)startWithLockFilePath:(NSURL *)path;
- (void)stop;

- (void)postNotification:(NSString *)name
                userInfo:(nullable NSDictionary *)userInfo
              completion:(nullable dispatch_block_t)completion;

/// the return value can be used to remove Observer
- (nullable NSString *)addObserverForName:(NSString *)name
                                withBlock:(FKNotificationBlock)block;

- (void)removeObserver:(NSString *)identifier
               forName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
