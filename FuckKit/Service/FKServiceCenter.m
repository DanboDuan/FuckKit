//
//  FKServiceCenter.m
//  FuckKit
//
//  Created by bob on 2020/5/11.
//

#import "FKServiceCenter.h"
#import "FKService.h"
#import "FKMacros.h"
#import "FKSectionBlock.h"
#import "FKSectionFunction.h"
#import "FKSectionMethod.h"

@interface FKServiceCenter ()

@property (nonatomic, strong) NSMutableDictionary<NSString * ,id> *services;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation FKServiceCenter

+ (void)initialize {
    [[FKSectionMethod sharedInstance] executeMethodsForKey:@FK_SERVICE_KEY];
    [[FKSectionFunction sharedInstance] executeFunctionsForKey:@FK_SERVICE_KEY];
    [[FKSectionBlock sharedInstance] executeBlocksForKey:@FK_SERVICE_KEY];
}

+ (instancetype)sharedInstance {
    static FKServiceCenter *sharedInstance = nil;
    static dispatch_once_t onceTFKen;
    dispatch_once(&onceTFKen, ^{
        sharedInstance = [self new];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.services = [NSMutableDictionary new];
        self.semaphore = dispatch_semaphore_create(1);
    }
    
    return self;
}

- (void)bindClass:(Class)cls forProtocol:(Protocol *)protocol {
    if (![cls conformsToProtocol:protocol]) {
        return;
    }
    NSString *key = [FKServiceCenter stringKeyForProtocol:protocol];
    [self bindClass:cls forKey:key];
}

- (void)bindClass:(Class)cls forKey:(NSString *)key {
    NSCAssert(key != nil && key.length > 0, @"key should not be nil");
    if (key.length < 1) {
        return;
    }
    
    FK_Lock(self.semaphore);
    if ([self.services objectForKey:key] == nil) {
        id service = nil;
        if ([cls respondsToSelector:@selector(sharedInstance)]) {
            service = [cls sharedInstance];
        } else {
            service = [[cls alloc] init];
        }
        
        NSCAssert(service != nil, @"Protocol sharedInstance should not be nil");
        [self.services setValue:service forKey:key];
    }
    FK_Unlock(self.semaphore);
}

- (void)bindObject:(id)service forProtocol:(Protocol *)protocol {
    if (![service conformsToProtocol:protocol]) {
        return;
    }
    
    NSString *key = [FKServiceCenter stringKeyForProtocol:protocol];
    [self bindObject:service forKey:key];
}

- (void)bindObject:(id)service forKey:(NSString *)key {
    NSCAssert(key != nil && key.length > 0, @"key should not be nil");
    if (key.length < 1) {
        return;
    }
    
    FK_Lock(self.semaphore);
    if ([self.services objectForKey:key] == nil) {
        [self.services setValue:service forKey:key];
    }
    
    FK_Unlock(self.semaphore);
}

- (id)serviceForProtocol:(Protocol *)protocol {
    NSString *key = [FKServiceCenter stringKeyForProtocol:protocol];
    
    return [self serviceForKey:key];
}

- (id)serviceForKey:(NSString *)key {
    NSCAssert(key != nil && key.length > 0, @"key should not be nil");
    if (key.length < 1) {
        return nil;
    }
    FK_Lock(self.semaphore);
    id service = [self.services objectForKey:key];
    FK_Unlock(self.semaphore);
    
    return service;
}

#pragma mark -- Helper

+ (NSString *)stringKeyForProtocol:(Protocol *)protocol {
    return [NSString stringWithFormat:@"com.FKServiceCenter.%@", NSStringFromProtocol(protocol)];
}

@end


#ifdef __FILE_NAME__
#define __FKALOG_FILE_NAME__ __FILE_NAME__
#else
#define __FKALOG_FILE_NAME__ __FILE__
#endif

#define NSSTRING_LOG(tag, format, ...) ( [NSString stringWithFormat:@"[%@][%@:%d] %@", tag, [[NSString stringWithUTF8String:__FKALOG_FILE_NAME__] lastPathComponent], __LINE__, [NSString stringWithFormat:format, ##__VA_ARGS__, nil]])


#define FKLOG_PROTOCOL_VERBOSE_TAG(tag, format, ...)\
@autoreleasepool {do{[FK_CENTER_OBJECT(FKLogService) verbose:NSSTRING_LOG(tag, format, ##__VA_ARGS__)];\
}while(0);};

#define FKLOG_PROTOCOL_DEBUG_TAG(tag, format, ...)\
@autoreleasepool {do{[FK_CENTER_OBJECT(FKLogService) debug:NSSTRING_LOG(tag, format, ##__VA_ARGS__)];\
}while(0);};

#define FKLOG_PROTOCOL_INFO_TAG(tag, format, ...)\
@autoreleasepool {do{[FK_CENTER_OBJECT(FKLogService) info:NSSTRING_LOG(tag, format, ##__VA_ARGS__)];\
}while(0);};

#define FKLOG_PROTOCOL_WARN_TAG(tag, format, ...)\
@autoreleasepool {do{[FK_CENTER_OBJECT(FKLogService) warn:NSSTRING_LOG(tag, format, ##__VA_ARGS__)];\
}while(0);};

#define FKLOG_PROTOCOL_ERROR_TAG(tag, format, ...)\
@autoreleasepool {do{[FK_CENTER_OBJECT(FKLogService) error:NSSTRING_LOG(tag, format, ##__VA_ARGS__)];\
}while(0);};

#define FK_SERVICE_METHOD FK_METHOD_EXPORT(FK_SERVICE_KEY);


/// @BindService(LoginService)
/// @BindService(AccountService)
#define FKBindService(protocolName) class NSObject; \
+ (id<protocolName>)__bind_service_##protocolName { \
    FK_SERVICE_METHOD \
    [[FKServiceCenter sharedInstance] bindClass:self forProtocol:@protocol(protocolName)]; \
    return nil; \
}

/// @InjectService(loginService, TTLoginService)
/// @InjectService(accountService, TTAccountService)
#define FKInjectService(name, protocolName) class NSObject; \
- (id<protocolName>)name { \
    id service = objc_getAssociatedObject(self, _cmd); \
    if (!service) { \
        service = [[FKServiceCenter sharedInstance] serviceForProtocol:@protocol(protocolName)]; \
        objc_setAssociatedObject(self, _cmd, service, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    } \
    return service; \
}



