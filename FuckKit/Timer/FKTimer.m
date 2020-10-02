//
//  FKTimer.m
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import "FKTimer.h"

@interface FKTimer ()

@property (nonatomic, strong) NSMutableDictionary *timerContainer;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation FKTimer

+ (instancetype)sharedInstance {
    static FKTimer *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken,^{
        sharedInstance = [self new];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = dispatch_semaphore_create(1);
        self.timerContainer = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                                 start:(long long)start
                          timeInterval:(long long)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    if (interval < 1) return;
    if (!action) return;
    if (!timerName) return;
    if (!queue) queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);

    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (timer == NULL) {
        /// might be nil
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        if (timer != NULL) {
            dispatch_source_set_event_handler(timer, ^{
                /// empty handler to resume it
            });
            dispatch_resume(timer);
            [self.timerContainer setValue:timer forKey:timerName];
        }
    }

    dispatch_semaphore_signal(self.lock);
    if (timer == NULL) {
        return;
    }
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_MSEC),
                              interval * NSEC_PER_MSEC,
                              NSEC_PER_MSEC);

    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(timer, ^{
        __strong typeof(wself) self = wself;
        if (!repeats) {
            [self cancelTimerWithName:timerName];
        }

        if (action) {
            action();
        }
    });
}

- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_semaphore_signal(self.lock);
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (timer != NULL) {
        [self.timerContainer removeObjectForKey:timerName];
        dispatch_source_cancel(timer);
    }
    dispatch_semaphore_signal(self.lock);
}

@end
