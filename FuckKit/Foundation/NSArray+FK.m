//
//  NSArray+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSArray+FK.h"
#import "NSObject+FK.h"

@implementation NSArray (FK)

- (id)fk_safeJsonObject {
    NSMutableArray *safeEncodingArray = [NSMutableArray array];
    for (id arrayValue in self) {
        id safe = [arrayValue fk_safeJsonObject];
        if (safe) {
            [safeEncodingArray addObject:safe];
        }
    }
    
    return safeEncodingArray.copy;
}

@end
