//
//  AppDelegate.m
//  RSKExample
//
//  Created by bob on 2020/5/7.
//  Copyright © 2020 rangers. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <FuckKit/NSFileManager+FK.h>
#import <FuckKit/FKSectionData.h>
#import <FuckKit/FKSectionBlock.h>
#import <FuckKit/FKSectionFunction.h>

FK_STRINGS_EXPORT("key1", "value1")
FK_STRINGS_EXPORT("key1", "value2")
FK_STRINGS_EXPORT("key2", "value1")

FK_BLOCKS_EXPORT("a", ^(void) {
    printf("\na Block:test block 1");
});

FK_BLOCKS_EXPORT("a", ^(void) {
    printf("\na Block:test block 2");
});

FK_FUNCTION_EXPORT("a")(void){
    printf("\na Function:test function 1");
};

FK_FUNCTION_EXPORT("a")(void){
    printf("\na Function:test function 2");
};

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    [NSFileManager fk_homePath];
    [NSFileManager fk_documentPath];
    [NSFileManager fk_libraryPath];
    [NSFileManager fk_cachePath];
    NSArray *key1 = [FKSectionData exportedStringsForKey:@"key1"];
    NSArray *key2 = [FKSectionData exportedStringsForKey:@"key2"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[FKSectionBlock sharedInstance] excuteBlocksForKey:@"a"];
        [[FKSectionFunction sharedInstance] excuteFunctionsForKey:@"a"];
    });
    NSLog(@"%@, %@ %s",key1, key2,__func__);
    return YES;
}

@end
