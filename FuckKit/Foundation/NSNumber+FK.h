//
//  NSNumber+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (FK)

- (id)fk_safeJsonObject;
- (NSString *)fk_safeJsonObjectKey;

@end

NS_ASSUME_NONNULL_END
