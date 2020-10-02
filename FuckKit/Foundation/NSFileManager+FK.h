//
//  NSFileManager+FK.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 home => /var/mobile/Containers/Data/Application/XXX/
    - Documents => /var/mobile/Containers/Data/Application/XXX/Documents
    - Applications =>
    - Library =>
    - Library/Caches
 */

@interface NSFileManager (FK)

+ (NSString *)fk_homePath;
+ (NSString *)fk_cachePath;
+ (NSString *)fk_documentPath;
+ (NSString *)fk_libraryPath;

/// /private/var/containers/Bundle/Application/XXX/YYY.app
+ (NSString *)fk_mainBundlePath;

@end

NS_ASSUME_NONNULL_END
