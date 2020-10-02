//
//  NSMutableArray+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSMutableArray+FK.h"

@implementation NSMutableArray (FK)

- (void)fk_addObject:(id)anObject {
    if (anObject != nil) {
        [self addObject:anObject];
    }
}

@end
