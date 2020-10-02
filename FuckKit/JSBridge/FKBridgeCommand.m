//
//  FKBridgeCommand.m
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import "FKBridgeCommand.h"
#import "NSDictionary+FK.h"
#import "NSObject+FK.h"

@implementation FKBridgeCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSString *messageType = [dict fk_stringValueForKey:kFKBridgeMsgType];
        if ([messageType isEqualToString:FKBridgeMsgTypeOn]
            || [messageType isEqualToString:FKBridgeMsgTypeEvent]) {
            self.bridgeType = FKBridgeOn;
        } else if ([messageType isEqualToString:FKBridgeMsgTypeCall]) {
            self.bridgeType = FKBridgeCall;
        } else if ([messageType isEqualToString:FKBridgeMsgTypeOff]) {
            self.bridgeType = FKBridgeOff;
        }
        self.messageType = messageType;
        self.bridgeName = [dict fk_stringValueForKey:kFKBridgeName];
        self.callbackID = [dict fk_stringValueForKey:kFKBridgeCallbackID];
        self.params = [dict fk_dictionaryValueForKey:kFKBridge2NativeParams];
    }

    return self;
}

- (instancetype)initWithName:(NSString *)bridgeName onHandler:(FKBridgeOnHandler)onHandler {
    self = [super init];
    if (self) {
        self.messageType = FKBridgeMsgTypeOn;
        self.bridgeName = bridgeName;
        self.bridgeType = FKBridgeOn;
        self.onHandler = onHandler;
    }

    return self;
}

- (void)addCode:(FKBridgeMsg)code response:(NSDictionary *)response type:(NSString *)type {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@(code) forKey:kFKBridgeCode];
    [param setValue:response forKey:kFKBridgeData];
    [param setValue:self.bridgeName forKey:kFKBridgeName];
    [param setValue:type forKey:kFKBridgeMsgType];

    self.params = param;
}

- (NSString *)toJSONString {
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    [jsonDic setValue:[self.callbackID mutableCopy]forKey:kFKBridgeCallbackID];
    [jsonDic setValue:self.params forKey:kFKBridge2JSParams];

    return [jsonDic fk_jsonStringEncodedForJS];
}


@end
