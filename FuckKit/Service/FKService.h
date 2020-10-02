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

NS_ASSUME_NONNULL_END
