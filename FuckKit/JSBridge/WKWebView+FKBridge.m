//
//  WKWebView+FKBridge.m
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import "WKWebView+FKBridge.h"
#import <objc/runtime.h>
#import "FKBridge.h"

@implementation WKWebView (FKBridge)

- (void)setFk_bridge:(FKBridge *)fk_bridge {
    objc_setAssociatedObject(self, @selector(fk_bridge), fk_bridge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FKBridge *)fk_bridge {
    return objc_getAssociatedObject(self, @selector(fk_bridge));
}

- (void)fk_installBridge {
    FKBridge *bridge = self.fk_bridge;
    if (bridge != nil && [bridge isKindOfClass:[FKBridge class]]) {
        return;
    }
    
    self.fk_bridge = [[FKBridge alloc] initWithWebView:self];
}

- (void)fk_uninstallBridge {
    FKBridge *bridge = self.fk_bridge;
    if (bridge == nil) {
        return;
    }
    
    [bridge uninstallBridge];
}

@end
