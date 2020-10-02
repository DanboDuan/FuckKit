//
//  FKKeychain.m
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import "FKKeychain.h"

@interface FKKeychain ()

@property (nonatomic, copy) NSString *service;
@property (nonatomic, assign) BOOL thisDeviceOnly;
@property (nonatomic, copy) NSString *group;

@end

@implementation FKKeychain

- (instancetype)initWithService:(NSString *)service
                 thisDeviceOnly:(BOOL)thisDeviceOnly
                          group:(NSString *)group {
    self = [super init];
    if (self) {
        self.service = service;
        self.thisDeviceOnly = thisDeviceOnly;
        self.group = group;
    }
    
    return self;
}

- (NSMutableDictionary *)queryWithKey:(NSString *)key {
    /// see http://developer.apple.com/library/ios/#DOCUMENTATION/Security/Reference/keychainservices/Reference/reference.html
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithDictionary:
                                          @{(__bridge id)kSecClass            : (__bridge id)kSecClassGenericPassword,
                                            (__bridge id)kSecAttrService      : self.service,
                                            (__bridge id)kSecAttrAccount      : key,
                                            }];
    if (self.group) {
        [keychainQuery setValue:self.group forKey: (__bridge id)kSecAttrAccessGroup];
    }
    
    return keychainQuery;
}

- (void)addKey:(NSString *)key value:(NSString *)value to:(NSMutableDictionary *)result {
    if (self.thisDeviceOnly) {
        [result setValue:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    } else {
        [result setValue:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
    }
    [result setValue:(__bridge id)kCFBooleanFalse forKey:(__bridge id)kSecAttrSynchronizable];
    [result setValue:key forKey:(__bridge id)kSecAttrGeneric];
    [result setValue:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

- (NSString *)loadValueForKey:(NSString *)key {
    NSMutableDictionary *query = [self queryWithKey:key];
    NSString *value = nil;
    CFDataRef valueData = NULL;
    [query setValue:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setValue:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&valueData);
    if (result == errSecSuccess && valueData != NULL) {
        value = [[NSString alloc] initWithData:(__bridge NSData *)valueData encoding:NSUTF8StringEncoding];
        CFRelease(valueData);
    }
    
    return value;
}

- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key {
    if (value == nil) {
        return [self deleteValueForKey:key];
    }
    NSMutableDictionary *query = [self queryWithKey:key];
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    /// update
    /// errSecItemNotFound  = -25300
    /// errSecDuplicateItem = -25299,
    
    if (result == errSecSuccess) {
        NSMutableDictionary *attributes = [NSMutableDictionary new];
        [self addKey:key value:value to:attributes];
        return SecItemUpdate((__bridge CFDictionaryRef)query,(__bridge CFDictionaryRef)attributes) == errSecSuccess;
    } else {
        [self addKey:key value:value to:query];
        return SecItemAdd((__bridge CFDictionaryRef)query, NULL) == errSecSuccess;
    }
}

- (BOOL)deleteValueForKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self queryWithKey:key];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    
    return result == errSecSuccess || result == errSecItemNotFound;
}

@end
