//
//  FKKeychain.h
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKKeychain : NSObject

@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, assign, readonly) BOOL thisDeviceOnly;

- (instancetype)initWithService:(NSString *)service
                 thisDeviceOnly:(BOOL)thisDeviceOnly
                          group:(nullable NSString *)group;

- (NSString *)loadValueForKey:(NSString *)key;
- (BOOL)saveValue:(nullable NSString *)value forKey:(NSString *)key;
- (BOOL)deleteValueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
