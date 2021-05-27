//
//  FKUtility.m
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#import "FKUtility.h"
#import <sys/sysctl.h>
#import <mach/mach_time.h>

@implementation FKUtility

+ (NSTimeInterval)currentInterval {
    return [[NSDate date] timeIntervalSince1970];
}

+ (long long)currentIntervalMS {
    return [self currentInterval] * 1000;
}

+ (NSCharacterSet *)URLQueryAllowedCharacterSet {
    static NSCharacterSet *characterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *set = [NSMutableCharacterSet new];
        [set formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        [set addCharactersInString:@"$-_.+!*'(),"];
        characterSet = set;
    });

    return characterSet;
}

@end

uint64_t FKCurrentMachTime(void) {
    return mach_absolute_time();
}

/// the same as CACurrentMediaTime()
double FKMachTimeToSecs(uint64_t time) {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / NSEC_PER_SEC;
}

long long FKTimeMillisecond(void) {
    struct timespec now;
    if (clock_gettime(CLOCK_REALTIME, &now)) {
        return -1;
    }
    
    long long micros = now.tv_sec * 1000 + now.tv_nsec/NSEC_PER_MSEC;
    return micros;
}
