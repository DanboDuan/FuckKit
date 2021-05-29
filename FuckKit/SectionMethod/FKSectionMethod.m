//
//  FKSectionMethod.m
//  FuckKit
//
//  Created by bob on 2021/5/28.
//

#import "FKSectionMethod.h"
#import <mach-o/getsect.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

#if DEBUG
static NSMutableDictionary<NSString *, NSString *> *__loadedMethods;
#endif

@interface _FKMethodData : NSObject
@end

@implementation _FKMethodData {
    Class _class;
    SEL _selector;
}

- (nullable instancetype)initWithPointer:(const void *)pointer {
    char *funcPointer = (char *)pointer;
    if (*(funcPointer) != '+'){
        NSAssert(NO, @"FKMethod can only export class method.");
        return nil;
    }
    NSString *func = [NSString stringWithUTF8String:pointer];
    NSArray<NSString *> *components = [func componentsSeparatedByString:@" "];
    if (components.count != 2) {
        return nil;
    }
    
    if (self = [super init]) {
        NSRange range = [components[0] rangeOfString:@"("];
        NSString *className = nil;
        if (range.length > 0) {
            className = [components[0] substringWithRange:NSMakeRange(2, range.location - 2)];
            _class = NSClassFromString(className);
        } else {
            className = [components[0] stringByReplacingOccurrencesOfString:@"+[" withString:@""];
            _class = NSClassFromString(className);
        }
        _selector = NSSelectorFromString([components[1] stringByReplacingOccurrencesOfString:@"]" withString:@""]);
#if DEBUG
        NSString *method = [NSString stringWithFormat:@"+[%@ %@]", className, NSStringFromSelector(_selector)];
        if (!__loadedMethods[method]) {
            __loadedMethods[method] = func;
        } else {
            NSAssert(NO, @"Duplicated implementation of FK method: '%@' and '%@'.", __loadedMethods[method], func);
        }
#endif
    }
    
    return self;
}

- (void)start {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([_class respondsToSelector:_selector]) {
        [_class performSelector:_selector];
    }
#pragma clang diagnostic pop
}

@end

typedef struct _FKMethodNode {
    FKMethod* dataArray;
    unsigned long size;
    struct _FKMethodNode *next;
    struct _FKMethodNode *head;
} FKMethodNode;

static FKMethodNode *_NODE;

@interface FKSectionMethod ()

@property (atomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *keyMethods;
- (void)addMethod:(const void *)pointer forKey:(NSString *)key;

@end

static void FKParseNode() {
    if (_NODE == NULL) {
        return;
    }
    FKMethodNode *head = _NODE->head;
    FKMethodNode *node = head;
    while (node != NULL) {
        FKMethod *dataArray = node->dataArray;
        unsigned long counter = node->size;
        for(int idx = 0; idx < counter; ++idx) {
            FKMethod data = dataArray[idx];
            NSString *key = [NSString stringWithUTF8String:data.key];
            const void * Method = data.value;
            [[FKSectionMethod sharedInstance] addMethod:Method forKey:key];
        }
        FKMethodNode *temp = node;
        node = node->next;
        free(temp);
    }
    _NODE = NULL;
}


static void FKReadMethods(char *sectionName, const struct mach_header *mhp) {
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    FKMethod *dataArray = (FKMethod *)memory;
    unsigned long counter = size/sizeof(FKMethod);
    /// next runloop for oc method
    FKMethodNode *node = (FKMethodNode*)malloc(sizeof(FKMethodNode));
    node->dataArray = dataArray;
    node->size = counter;
    node->next = NULL;
    node->head = NULL;
    if (_NODE != NULL) {
        node->head = _NODE->head;
        _NODE->next = node;
    } else {
        node->head = node;
    }
    _NODE = node;
    
    /// next runloop for oc method
    dispatch_async(dispatch_get_main_queue(), ^{
        FKParseNode();
    });
}

static void dyld_Method_callback(const struct mach_header *mhp, intptr_t vmaddr_slide)
{
    Dl_info info;
    if (dladdr(mhp, &info) == 0) {
        return;
    }
    FKReadMethods("__FKMethod", mhp);
}

@implementation FKSectionMethod

+ (void)initialize {
#if DEBUG
    __loadedMethods = [NSMutableDictionary new];
#endif
    _dyld_register_func_for_add_image(dyld_Method_callback);
    FKParseNode();
}

+ (instancetype)sharedInstance {
    static FKSectionMethod *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyMethods = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addMethod:(const void *)pointer forKey:(NSString *)key {
    if (pointer == nil || key == nil) {
        return;
    }
    
    NSMutableArray *methods = [self.keyMethods objectForKey:key];
    if (methods == nil) {
        methods = [NSMutableArray new];
        [self.keyMethods setValue:methods forKey:key];
    }
    [methods addObject:[[_FKMethodData alloc] initWithPointer:pointer]];
}

- (void)executeMethodsForKey:(NSString *)key {
    if (key == nil) {
        return;
    }
    
    NSArray<_FKMethodData *> *methods = [self.keyMethods objectForKey:key].copy;
    if (methods != nil) {
        [methods enumerateObjectsUsingBlock:^(_FKMethodData *method, NSUInteger idx, BOOL * stop) {
            [method start];
        }];
    }
}

@end
