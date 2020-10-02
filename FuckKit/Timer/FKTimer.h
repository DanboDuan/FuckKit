//
//  FKTimer.h
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKTimer : NSObject

+ (instancetype)sharedInstance;

/// start interval 单位是毫秒，必须大于1
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                                 start:(long long)start
                          timeInterval:(long long)interval
                                 queue:(nullable dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action;

- (void)cancelTimerWithName:(NSString *)timerName;

@end

NS_ASSUME_NONNULL_END
