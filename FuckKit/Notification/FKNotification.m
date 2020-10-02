//
//  FKNotification.m
//  FuckKit
//
//  Created by bob on 2020/10/2.
//

#import "FKNotification.h"
#import "NSDictionary+FK.h"

static NSString * const kFKNotificationName              = @"name";
static NSString * const kFKNotificationInfo              = @"info";

@interface FKNotification ()<NSFilePresenter>

@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSFileCoordinator *coordinator;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, FKNotificationBlock> *> *observers;

@end

@implementation FKNotification

- (void)presentedItemDidChange {
    if (self.fileURL == nil) {
        return;
    }
    [self.coordinator coordinateReadingItemAtURL:self.fileURL
                                         options:NSFileCoordinatorReadingWithoutChanges
                                           error:nil
                                      byAccessor:^(NSURL *fileURL) {
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfURL:fileURL];
        if (![data isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSString *name = [data fk_stringValueForKey:kFKNotificationName];
        if (name == nil) {
            return;
        }
        
        [self.queue addOperationWithBlock:^{
            NSMutableDictionary<NSString *, FKNotificationBlock> *observers = [self.observers objectForKey:name];
            if (observers.count < 1) {
                return;
            }
            NSDictionary *info = [data objectForKey:kFKNotificationInfo];
            [observers enumerateKeysAndObjectsUsingBlock:^(NSString *key, FKNotificationBlock block, BOOL *stop) {
                block(info);
            }];
        }];
    }];
}

- (void)relinquishPresentedItemToWriter:(void (^)(dispatch_block_t reacquirer))writer {
    writer(nil);
}

- (void)relinquishPresentedItemToReader:(void (^)(dispatch_block_t reacquirer))reader {
    reader(nil);
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return self.queue;
}

- (NSURL *)presentedItemURL {
    return self.fileURL;
}

- (void)dealloc {
    [self stop];
}

+ (instancetype)sharedInstance {
    static FKNotification *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [NSOperationQueue new];
        self.queue.maxConcurrentOperationCount = 1;
        self.observers = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    return self;
}

- (void)stop {
    if (self.fileURL == nil) {
        return;
    }
    [NSFileCoordinator removeFilePresenter:self];
    self.fileURL = nil;
    self.coordinator = nil;
}

- (void)startWithLockFilePath:(NSURL *)path {
    if ([self.fileURL.path isEqualToString:path.path]) {
        return;
    }
    [self stop];
    self.fileURL = path;
    self.coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    [NSFileCoordinator addFilePresenter:self];
}

- (NSString *)addObserverForName:(NSString *)name
                       withBlock:(FKNotificationBlock)block {
    if (name == nil || block == nil) {
        return nil;
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%p",block];
    [self.queue addOperationWithBlock:^{
        NSMutableDictionary<NSString *, FKNotificationBlock> *observers = [self.observers objectForKey:name];
        if (observers == nil) {
            observers = [NSMutableDictionary dictionaryWithCapacity:10];
            [self.observers setValue:observers forKey:name];
        }
        [observers setValue:block forKey:identifier];
    }];
    
    return identifier;
}

- (void)removeObserver:(NSString *)identifier forName:(NSString *)name {
    if (identifier == nil || name == nil) {
        return;
    }
    
    [self.queue addOperationWithBlock:^{
        NSMutableDictionary<NSString *, FKNotificationBlock> *observers = [self.observers objectForKey:name];
        if (observers != nil) {
            [observers removeObjectForKey:identifier];
        }
    }];
}

- (void)postNotification:(NSString *)name
                userInfo:(NSDictionary *)userInfo
              completion:(dispatch_block_t)completion {
    if (name == nil || self.fileURL == nil) {
        return;
    }
    [self.coordinator coordinateWritingItemAtURL:self.fileURL
                                         options:NSFileCoordinatorWritingForReplacing
                                           error:nil
                                      byAccessor:^(NSURL *fileURL) {
        NSDictionary *data = @{
            kFKNotificationName:name,
            kFKNotificationInfo:[userInfo fk_safeJsonObject] ?: @{},
        };
        if (@available(iOS 11, *)) {
            [data writeToURL:fileURL error:nil];
        } else {
            [data writeToFile:fileURL.path atomically:YES];
        }
        if (completion) {
            completion();
        }
    }];
}


@end
