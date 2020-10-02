//
//  NSFileManager+FK.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "NSFileManager+FK.h"

@implementation NSFileManager (FK)

+ (NSString *)fk_homePath {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       value = NSHomeDirectory();
    });
    
    return value;
}

+ (NSString *)fk_cachePath {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
       value = [paths objectAtIndex:0];
    });
    
    return value;
}

+ (NSString *)fk_documentPath {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
       value = [paths objectAtIndex:0];
    });
    
    return value;
}

+ (NSString *)fk_libraryPath {
    static NSString *value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
       value = [paths objectAtIndex:0];
    });
    
    return value;
}

+ (NSString *)fk_mainBundlePath {
    return [[NSBundle mainBundle] bundlePath];
}

@end
