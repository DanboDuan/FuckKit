//
//  NSSet+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSSet+FK.h"
#import "NSObject+FK.h"

@implementation NSSet (FK)

- (id)fk_safeJsonObject {
    
    return [self.allObjects fk_safeJsonObject];
}

@end
