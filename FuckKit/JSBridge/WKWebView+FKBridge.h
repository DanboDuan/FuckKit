//
//  WKWebView+FKBridge.h
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 前端需要引入bridge.js minify后的bridge.min.js，在组件目录下JS

@class FKBridge;

@interface WKWebView (FKBridge)

@property (nonatomic, strong, nullable) FKBridge *fk_bridge;

- (void)fk_installBridge;
- (void)fk_uninstallBridge;

@end

NS_ASSUME_NONNULL_END
