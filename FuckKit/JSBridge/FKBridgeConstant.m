//
//  FKBridgeConstant.m
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import "FKBridgeConstant.h"

NSString *const kFKCallMethod      =   @"callMethodParams";

NSString *const kFKBridgeCallbackID       = @"__callback_id";
NSString *const kFKBridgeMsgType          = @"__msg_type";
NSString *const kFKBridgeName             = @"func";
NSString *const kFKBridge2JSParams        = @"__params";
NSString *const kFKBridge2NativeParams    = @"params";
NSString *const kFKBridgeErrorCode        = @"__err_code";
NSString *const kFKBridgeCode             = @"code";
NSString *const kFKBridgeData             = @"data";

NSString *const FKBridgeMsgTypeEvent      = @"event";
NSString *const FKBridgeMsgTypeOn         = @"on";
NSString *const FKBridgeMsgTypeCall       = @"call";
NSString *const FKBridgeMsgTypeOff        = @"off";
NSString *const FKBridgeMsgTypeCallback   = @"callback";

NSString * kFKBridgeJSHandler     = @";window.Native2JSBridge && Native2JSBridge._handleMessageFromApp";


