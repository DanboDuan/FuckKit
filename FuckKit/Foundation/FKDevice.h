//
//  FKDevice.h
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Please call from main thread
 */
@interface FKDevice : NSObject

+ (NSTimeInterval)startupTime;
+ (uint32_t)cpuCoreCount ;
+ (NSString *)machineModel; /// return string like "iPhone9,1"
+ (NSString *)platformName; /// return "iPod", "iPad" or "iPhone"
+ (BOOL)isSimulator;
+ (NSString *)systemVersion;
+ (NSString *)currentSystemLanguage;
+ (NSString *)currentLanguage;
+ (NSString *)IDFV;
+ (NSString *)p6;
+ (float)cpuUsage; /// return -1 if error

+ (u_int64_t)physicalMemory;
+ (u_int64_t)appUsedMemory;
#ifdef __LP64__
+ (u_int64_t)deviceUsedMemory;
#endif

+ (u_int64_t)totalDiskSize;
+ (u_int64_t)freeDiskSize;

@end

NS_ASSUME_NONNULL_END
