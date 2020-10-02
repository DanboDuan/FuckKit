//
//  FKSectionData.m
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import "FKSectionData.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>

#ifdef __LP64__
typedef uint64_t FKExportValue;
typedef struct section_64 FKExportSection;
#define FKGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t FKExportValue;
typedef struct section FKExportSection;
#define FKGetSectByNameFromHeader getsectbynamefromheader
#endif

@interface FKSectionData ()

@property (atomic, copy) NSDictionary<NSString *, NSMutableArray *> *keyValues;

+ (instancetype)sharedInstance;

@end

static void FKGetString() {
    if ([FKSectionData sharedInstance].keyValues) {
        return;
    }
    Dl_info info;
    dladdr((const void *)&FKGetString, &info);
    const FKExportValue mach_header = (FKExportValue)info.dli_fbase;
    const FKExportSection *section = FKGetSectByNameFromHeader((void *)mach_header, "__DATA", "__FKString");
    if (section == NULL) {
        [FKSectionData sharedInstance].keyValues = [NSDictionary new];
        return;
    }
    
    FKString *dataArray = (FKString *)(mach_header + section->offset);
    unsigned long counter = section->size/sizeof(FKString);
    
    NSMutableDictionary<NSString *, NSMutableArray *> *keyValues = [NSMutableDictionary dictionary];
    for (int idx = 0; idx < counter; ++idx) {
        FKString data = dataArray[idx];
        NSString *entryKey = [NSString stringWithUTF8String:data.key];
        NSString *entryValue = [NSString stringWithUTF8String:data.value];
        NSMutableArray<NSString *> *values = [keyValues objectForKey:entryKey];
        if (values == nil) {
            values = [NSMutableArray new];
            [keyValues setValue:values forKey:entryKey];
        }
        [values addObject:entryValue];
    }
    
    [FKSectionData sharedInstance].keyValues = keyValues;
}

@implementation FKSectionData

+ (instancetype)sharedInstance {
    static FKSectionData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

+ (NSArray<NSString *> *)exportedStringsForKey:(NSString *)key {
    FKGetString();
    NSDictionary<NSString *, NSArray *> * keyValues = [FKSectionData sharedInstance].keyValues;
    
    return [keyValues objectForKey:key].copy;
}

@end
