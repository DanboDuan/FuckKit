//
//  FKSectionFunction.m
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import "FKSectionFunction.h"
#import <mach-o/getsect.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

@interface _FKFunctionData : NSObject
@end

@implementation _FKFunctionData {
    const void *_function;
}

- (instancetype)initWithPointer:(const void *)pointer {
    if (self = [super init]) {
        _function = pointer;
    }
    
    return self;
}

- (void)start {
    if (_function) {
        ((void (*)(void))_function)();
    }
}

@end

typedef struct _FKFunctionNode {
    FKFunction* dataArray;
    unsigned long size;
    struct _FKFunctionNode *next;
    struct _FKFunctionNode *head;
} FKFunctionNode;

static FKFunctionNode *_NODE;

@interface FKSectionFunction ()

@property (atomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *keyFunctions;
- (void)addFunction:(const void *)pointer forKey:(NSString *)key;

@end

static void FKParseNode() {
    if (_NODE == NULL) {
        return;
    }
    FKFunctionNode *head = _NODE->head;
    FKFunctionNode *node = head;
    while (node != NULL) {
        FKFunction *dataArray = node->dataArray;
        unsigned long counter = node->size;
        for(int idx = 0; idx < counter; ++idx) {
            FKFunction data = dataArray[idx];
            NSString *key = [NSString stringWithUTF8String:data.key];
            const void * function = data.function;
            [[FKSectionFunction sharedInstance] addFunction:function forKey:key];
        }
        FKFunctionNode *temp = node;
        node = node->next;
        free(temp);
    }
    _NODE = NULL;
}


static void FKReadFunctions(char *sectionName, const struct mach_header *mhp) {
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    FKFunction *dataArray = (FKFunction *)memory;
    unsigned long counter = size/sizeof(FKFunction);
    /// next runloop for oc method
    FKFunctionNode *node = (FKFunctionNode*)malloc(sizeof(FKFunctionNode));
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

static void dyld_function_callback(const struct mach_header *mhp, intptr_t vmaddr_slide)
{
    Dl_info info;
    if (dladdr(mhp, &info) == 0) {
        return;
    }
    FKReadFunctions("__FKFunction", mhp);
}

@implementation FKSectionFunction

+ (void)initialize {
    _dyld_register_func_for_add_image(dyld_function_callback);
    FKParseNode();
}

+ (instancetype)sharedInstance {
    static FKSectionFunction *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyFunctions = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addFunction:(const void *)pointer forKey:(NSString *)key {
    if (pointer == nil || key == nil) {
        return;
    }
    
    NSMutableArray *functions = [self.keyFunctions objectForKey:key];
    if (functions == nil) {
        functions = [NSMutableArray new];
        [self.keyFunctions setValue:functions forKey:key];
    }
    [functions addObject:[[_FKFunctionData alloc] initWithPointer:pointer]];
}

- (void)executeFunctionsForKey:(NSString *)key {
    if (key == nil) {
        return;
    }
    
    NSArray<_FKFunctionData *> *functions = [self.keyFunctions objectForKey:key].copy;
    if (functions != nil) {
        [functions enumerateObjectsUsingBlock:^(_FKFunctionData *function, NSUInteger idx, BOOL * stop) {
            [function start];
        }];
    }
    
    [self executeSwiftFunctionsForKey:key];
}

- (void)executeSwiftFunctionsForKey:(NSString *)key {
    
}

@end
