//
//  FKService.h
//  FuckKit
//
//  Created by bob on 2020/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FKService <NSObject>

+ (instancetype)sharedInstance;

@end

@protocol FKLogService <FKService>

- (void)verbose:(NSString *)log;
- (void)debug:(NSString *)log;
- (void)info:(NSString *)log;
- (void)warn:(NSString *)log;
- (void)error:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
