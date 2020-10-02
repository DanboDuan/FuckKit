//
//  NSMutableDictionary+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (FK)

- (void)fk_setObject:(nullable id)anObject forKey:(nullable id<NSCopying>)aKey;

/*
the struct should be the same
e.g.
{"x":"xx"} skipMerge {"x":"xxx","y","yyy"}
==> {"x":"xx","y","yyy"}

{"x":"xx"} overrideMerge {"x":"xxx","y","yyy"}
==> {"x":"xxx","y","yyy"}

*/
- (void)fk_skipMerge:(NSDictionary *)value;
- (void)fk_overrideMerge:(NSDictionary *)value;

@end

NS_ASSUME_NONNULL_END
