//
//  FKBridgeConstant.h
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 前端需要引入bridge.js minify后的bridge.min.js，在组件目录下JS


typedef NS_ENUM(NSInteger, FKBridgeType){
    FKBridgeUnkown = 1,
    FKBridgeCall,
    FKBridgeOn,
    FKBridgeOff,
};

typedef NS_ENUM(NSInteger, FKBridgeMsg){
    FKBridgeMsgSuccess = 1,
    FKBridgeMsgFailed = 0,
    FKBridgeMsgParamError = -3,
    FKBridgeMsgNoHandler = -2,
    FKBridgeMsgNoPermission = -1,
};

typedef void (^FKBridgeCallCompletion)(id _Nullable result, NSError * _Nullable error);

typedef void (^FKBridgeOnCallback)(FKBridgeMsg msg, NSDictionary *_Nullable params);
typedef void (^FKBridgeOnHandler)(NSDictionary *_Nullable params, FKBridgeOnCallback _Nullable callback);

FOUNDATION_EXTERN NSString * const kFKCallMethod;

FOUNDATION_EXTERN NSString *const kFKBridgeCallbackID;
FOUNDATION_EXTERN NSString *const kFKBridgeMsgType;
FOUNDATION_EXTERN NSString *const kFKBridgeName;
FOUNDATION_EXTERN NSString *const kFKBridge2JSParams;
FOUNDATION_EXTERN NSString *const kFKBridge2NativeParams;
FOUNDATION_EXTERN NSString *const kFKBridgeErrorCode;
FOUNDATION_EXTERN NSString *const kFKBridgeCode;
FOUNDATION_EXTERN NSString *const kFKBridgeData;

FOUNDATION_EXTERN NSString *const FKBridgeMsgTypeEvent;
FOUNDATION_EXTERN NSString *const FKBridgeMsgTypeOn;
FOUNDATION_EXTERN NSString *const FKBridgeMsgTypeCall;
FOUNDATION_EXTERN NSString *const FKBridgeMsgTypeOff;
FOUNDATION_EXTERN NSString *const FKBridgeMsgTypeCallback;

FOUNDATION_EXTERN NSString * kFKBridgeJSHandler;


NS_ASSUME_NONNULL_END
