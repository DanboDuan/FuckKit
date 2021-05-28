//
//  FKServiceCenter.h
//  FuckKit
//
//  Created by bob on 2020/5/11.
//

#import <Foundation/Foundation.h>

@protocol FKService;


NS_ASSUME_NONNULL_BEGIN

@interface FKServiceCenter : NSObject

+ (instancetype)sharedInstance;

/// class should implement FKService
- (void)bindClass:(Class)cls forProtocol:(Protocol *)protocol;
- (void)bindClass:(Class)cls forKey:(NSString *)key;

/// object should implement FKService
- (void)bindObject:(id)service forProtocol:(Protocol *)protocol;
- (void)bindObject:(id)service forKey:(NSString *)key;

- (nullable id)serviceForProtocol:(Protocol *)protocol;
- (nullable id)serviceForKey:(NSString *)key;

@end

#define FK_CENTER_OBJECT(theProtocol) \
    [[FKServiceCenter sharedInstance] serviceForProtocol:@protocol(theProtocol)]

#define FK_CENTER_BIND_CLASS_PROTOCOL(theClass, theProtocol) \
    [[FKServiceCenter sharedInstance] bindClass:theClass forProtocol:@protocol(theProtocol)]

#define FK_CENTER_BIND_OBJECT_PROTOCOL(theObject, theProtocol) \
    [[FKServiceCenter sharedInstance] bindObject:theObject forProtocol:@protocol(theProtocol)]

NS_ASSUME_NONNULL_END
