//
//  FKBridgeCommand.h
//  FuckKit
//
//  Created by bob on 2020/5/28.
//

#import "FKBridgeConstant.h"

/// 前端需要引入bridge.js minify后的bridge.min.js，在组件目录下JS

NS_ASSUME_NONNULL_BEGIN

@interface FKBridgeCommand : NSObject

@property (nonatomic, assign) FKBridgeType bridgeType;
@property (nonatomic, copy) NSString *messageType;
@property (nonatomic, copy) NSString *bridgeName;
@property (nonatomic, copy) NSString *callbackID;
@property (nonatomic, copy) NSDictionary *params;

@property (nonatomic, strong, nullable) FKBridgeCallCompletion callCompletion;
@property (nonatomic, strong, nullable) FKBridgeOnHandler onHandler;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithName:(NSString *)bridgeName onHandler:(FKBridgeOnHandler)onHandler;

- (void)addCode:(FKBridgeMsg)code response:(nullable NSDictionary *)response type:(NSString *)type;
- (NSString *)toJSONString;


@end

NS_ASSUME_NONNULL_END
