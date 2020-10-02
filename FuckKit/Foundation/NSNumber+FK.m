//
//  NSNumber+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSNumber+FK.h"

@implementation NSNumber (FK)

- (id)fk_safeJsonObject {
    /// fallback to zero
    if (!isnormal(self.doubleValue)) {
        return @(0);
    }
    
    return [self copy];
}

- (NSString *)fk_safeJsonObjectKey {
    return self.stringValue;
}

@end
