//
//  FKBridge.m
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import "FKBridge.h"
#import "WKWebView+FKBridge.h"
#import "FKBridgeCommand.h"
#import "FKMacros.h"

@interface FKBridge ()<WKScriptMessageHandler>

@property (nonatomic, weak, nullable)  WKWebView *webView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, FKBridgeCommand *> *webOnCommands;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<FKBridgeCommand *> *> *nativeOnCommands;

@end

@implementation FKBridge

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        self.webOnCommands = [NSMutableDictionary new];
        self.nativeOnCommands = [NSMutableDictionary new];
        self.webView = webView;
        self.reporter = nil;
        [webView.configuration.userContentController addScriptMessageHandler:self name:kFKCallMethod];
    }

    return self;
}

- (void)uninstallBridge {
    WKWebView *webView = self.webView;
    [webView.configuration.userContentController removeScriptMessageHandlerForName:kFKCallMethod];
    webView.fk_bridge = nil;
    self.webView = nil;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *body = [message.body isKindOfClass:NSDictionary.class] ? message.body : nil;
    if (!body) {
        return;
    }
    FKBridgeCommand *command = [[FKBridgeCommand alloc] initWithDictionary:body];
    if (command.bridgeType == FKBridgeCall) {
        [self callNative:command.bridgeName command:command];
    } else if (command.bridgeType == FKBridgeOn) {
        [self.webOnCommands setValue:command forKey:command.bridgeName];
    } else if (command.bridgeType == FKBridgeOff) {
        [self.webOnCommands removeObjectForKey:command.bridgeName];
    }
}

- (NSMutableArray<FKBridgeCommand *> *)nativeOnCommandForBridgeName:(NSString *)bridgeName {
    NSMutableArray<FKBridgeCommand *> *result = [NSMutableArray new];
    NSMutableArray<FKBridgeCommand *> *commands = [self.nativeOnCommands objectForKey:bridgeName];
    if (commands.count > 0) {
        for (FKBridgeCommand *nCommand in commands) {
            if (nCommand.onHandler != nil) {
                [result addObject:nCommand];
            }
        }
    }
    
    return result;
}

#pragma mark - JSBridge function call Native

- (void)callNative:(NSString *)bridgeName command:(FKBridgeCommand *)command {
    __strong typeof(self.reporter) reporter = self.reporter;
    if ([reporter respondsToSelector:@selector(reportJS2Native:)]) {
        [reporter reportJS2Native:bridgeName];
    }
    NSMutableArray<FKBridgeCommand *> *commands = [self nativeOnCommandForBridgeName:bridgeName];
    if (commands.count < 1) {
        [command addCode:FKBridgeMsgNoHandler response:nil type:FKBridgeMsgTypeCallback];
        NSString *invokeJS = [NSString stringWithFormat:@"%@(%@);",kFKBridgeJSHandler, [command toJSONString]];
        [self.webView evaluateJavaScript:invokeJS completionHandler:nil];
        return;
    }
    
    for (FKBridgeCommand *nCommand in commands) {
        FK_WeakSelf;
        FKBridgeOnCallback callback = ^(FKBridgeMsg msg, NSDictionary *params) {
            FK_StrongSelf;
            WKWebView *webView = self.webView;
            if (!webView) {
                return;
            }
            [command addCode:msg response:params type:FKBridgeMsgTypeCallback];
            NSString *invokeJS = [NSString stringWithFormat:@"%@(%@);",kFKBridgeJSHandler, [command toJSONString]];
            [webView evaluateJavaScript:invokeJS completionHandler:nil];
        };
        nCommand.onHandler([command.params mutableCopy], callback);
    }
}

- (BOOL)webOnBridge:(NSString *)bridgeName {
    return [self.webOnCommands objectForKey:bridgeName] != nil;
}

#pragma mark - JSBridge function call JS

- (void)call:(NSString *)bridgeName
         msg:(FKBridgeMsg)msg
      params:(NSDictionary *)params
  completion:(FKBridgeCallCompletion)completion {
    __strong typeof(self.reporter) reporter = self.reporter;
    
    if ([reporter respondsToSelector:@selector(reportNativ2JS:)]) {
        [reporter reportNativ2JS:bridgeName];
    }
    if (![self.webOnCommands objectForKey:bridgeName] || !self.webView) {
        if (completion) completion(@"cb404", nil);
        return;
    }
    FK_WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        FK_StrongSelf;
        FKBridgeCommand *command = [self.webOnCommands objectForKey:bridgeName];
        [command addCode:msg response:params type:FKBridgeMsgTypeCall];
        NSString *invokeJS = [NSString stringWithFormat:@"%@(%@);",kFKBridgeJSHandler, [command toJSONString]];
        [self.webView evaluateJavaScript:invokeJS completionHandler:completion];
    });
}

- (void)on:(NSString *)bridgeName callback:(FKBridgeOnHandler)callback {
    FKBridgeCommand *command = [[FKBridgeCommand alloc] initWithName:bridgeName onHandler:callback];
    NSMutableArray<FKBridgeCommand *> *commands = [self.nativeOnCommands objectForKey:bridgeName];
    if (!commands) {
        commands = [NSMutableArray new];
        [self.nativeOnCommands setValue:commands forKey:bridgeName];
    }
    [commands addObject:command];
}

@end


