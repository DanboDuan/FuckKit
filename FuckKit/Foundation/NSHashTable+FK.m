//
//  NSHashTable+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSHashTable+FK.h"
#import "NSObject+FK.h"

@implementation NSHashTable (FK)

- (id)fk_safeJsonObject {
    return [self.allObjects fk_safeJsonObject];
}

@end
