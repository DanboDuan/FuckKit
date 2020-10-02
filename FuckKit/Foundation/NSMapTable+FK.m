//
//  NSMapTable+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSMapTable+FK.h"
#import "NSObject+FK.h"


@implementation NSMapTable (FK)

- (id)fk_safeJsonObject {
    
    return [self.dictionaryRepresentation fk_safeJsonObject];
}

@end
