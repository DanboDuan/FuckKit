//
//  FKBridge.h
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import "FKBridgeConstant.h"

NS_ASSUME_NONNULL_BEGIN

/// 前端需要引入bridge.js minify后的bridge.min.js，在组件目录下JS

@protocol FKBridgeReporter <NSObject>

- (void)reportJS2Native:(NSString *)bridgeName;
- (void)reportNativ2JS:(NSString *)bridgeName;

@end

@class WKWebView;

@interface FKBridge : NSObject

@property (nonatomic, weak, nullable, readonly)  WKWebView *webView;
@property (nonatomic, weak, nullable)  id<FKBridgeReporter> reporter;

- (instancetype)initWithWebView:(WKWebView *)webView;
- (void)uninstallBridge;

- (BOOL)webOnBridge:(NSString *)bridgeName;

- (void)call:(NSString *)bridgeName
         msg:(FKBridgeMsg)msg
      params:(nullable NSDictionary *)params
  completion:(nullable FKBridgeCallCompletion)completion;

- (void)on:(NSString *)bridgeName callback:(FKBridgeOnHandler)callback;


@end

NS_ASSUME_NONNULL_END
