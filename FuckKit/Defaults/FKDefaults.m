//
//  FKDefaults.m
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import "FKDefaults.h"
#import "NSMutableDictionary+FK.h"
#import "NSDictionary+FK.h"
#import "NSFileManager+FK.h"
#import "FKMacros.h"

static NSMutableDictionary<NSString *, FKDefaults *> *allDefaults = nil;
static dispatch_semaphore_t semaphore = NULL;

@interface FKDefaults ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *plistPath;
@property (nonatomic, strong) NSMutableDictionary *rawData;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation FKDefaults

+ (NSString *)defaultPathForIdentifier:(NSString *)identifier {
    static NSString *document = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        document = [[NSFileManager fk_documentPath] stringByAppendingPathComponent:@"fk_defaults"];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if ([fm fileExistsAtPath:document isDirectory:&isDir]) {
            if (!isDir) {
                [fm removeItemAtPath:document error:nil];
                [fm createDirectoryAtPath:document withIntermediateDirectories:YES attributes:nil error:nil];
            }
        } else {
            [fm createDirectoryAtPath:document withIntermediateDirectories:YES attributes:nil error:nil];
        }
         /// 耗时操作
        dispatch_block_t block = ^{
            NSURL *url = [NSURL fileURLWithPath:document];
            [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       block);
    });
    
    return [document stringByAppendingPathComponent:identifier];
}

+ (instancetype)defaultsWithIdentifier:(NSString *)identifier {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allDefaults = [NSMutableDictionary new];
        semaphore = dispatch_semaphore_create(1);
    });
    
    if (![identifier isKindOfClass:[NSString class]] || identifier.length < 1) {
        return nil;
    }
    
    FK_Lock(semaphore);
    FKDefaults *defaults = [allDefaults objectForKey:identifier];
    if (!defaults) {
        defaults = [[FKDefaults alloc] initWithIdentifier:identifier];
        [allDefaults setValue:defaults forKey:identifier];
    }
    FK_Unlock(semaphore);

    return defaults;
}

- (instancetype)initWithIdentifier:(NSString *)identifier path:(NSString *)path {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.plistPath = path;
        self.rawData = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary new];
        self.semaphore = dispatch_semaphore_create(1);
    }

    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    NSString *plistPath = [FKDefaults defaultPathForIdentifier:identifier];
    
    return [self initWithIdentifier:identifier path:plistPath];
}


- (BOOL)boolValueForKey:(NSString *)key {
    if (key == nil) {
        return NO;
    }
    FK_Lock(self.semaphore);
    BOOL value = [self.rawData fk_boolValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (double)doubleValueForKey:(NSString *)key {
    if (key == nil) {
        return 0;
    }
    FK_Lock(self.semaphore);
    double value = [self.rawData fk_doubleValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (NSInteger)integerValueForKey:(NSString *)key {
    if (key == nil) {
        return 0;
    }
    FK_Lock(self.semaphore);
    NSInteger value = [self.rawData fk_integerValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (long long)longlongValueForKey:(NSString *)key {
    if (key == nil) {
        return 0;
    }
    FK_Lock(self.semaphore);
    long long value = [self.rawData fk_longlongValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (NSString *)stringValueForKey:(NSString *)key {
    if (key == nil) {
        return nil;
    }
    FK_Lock(self.semaphore);
    NSString *value = [self.rawData fk_stringValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (NSDictionary *)dictionaryValueForKey:(NSString *)key {
    if (key == nil) {
        return nil;
    }
    FK_Lock(self.semaphore);
    NSDictionary *value = [self.rawData fk_dictionaryValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (NSArray *)arrayValueForKey:(NSString *)key {
    if (key == nil) {
        return nil;
    }
    FK_Lock(self.semaphore);
    NSArray *value = [self.rawData fk_arrayValueForKey:key];
    FK_Unlock(self.semaphore);
    
    return value;
}

- (void)setDefaultValue:(id)value forKey:(NSString *)key {
    if (key == nil) {
        return;
    }
    FK_Lock(self.semaphore);
    [self.rawData setValue:value forKey:key];
    FK_Unlock(self.semaphore);
}

- (void)saveDataToFile {
    FK_Lock(self.semaphore);
    NSDictionary *data = [self.rawData fk_safeJsonObject];
    if (@available(iOS 11, *)) {
        [data writeToURL:[NSURL fileURLWithPath:self.plistPath] error:nil];
    } else {
        [data writeToFile:self.plistPath atomically:YES];
    }
    FK_Unlock(self.semaphore);
}

- (void)clearAllData {
    FK_Lock(self.semaphore);
    self.rawData = [NSMutableDictionary new];
    [[NSFileManager defaultManager] removeItemAtPath:self.plistPath error:nil];
    FK_Unlock(self.semaphore);
}

@end
