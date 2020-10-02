//
//  FKDevice.m
//  FuckKit
//
//  Created by bob on 2020/4/26.
//

#import "FKDevice.h"
#import "NSFileManager+FK.h"

#import <sys/utsname.h>
#import <mach/mach.h>
#include <sys/sysctl.h>

@implementation FKDevice

+ (NSTimeInterval)startupTime {
    NSTimeInterval interval = [[NSProcessInfo processInfo] systemUptime];
    
    NSDate *currentDate = [NSDate new];
    NSDate *startTime = [currentDate dateByAddingTimeInterval:(0 - interval)];
    NSTimeInterval result = [startTime timeIntervalSince1970];
    
    return result;
}

+ (uint32_t)cpuCoreCount {
    uint32_t ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
    
    return ncpu;
}

+ (NSString *)machineModel {
    static NSString *machineModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        machineModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([machineModel containsString:@"i386"] || [machineModel containsString:@"x86_64"]) {
            machineModel = [[NSProcessInfo processInfo].environment objectForKey:@"SIMULATOR_MODEL_IDENTIFIER"];
        }
    });

    return machineModel;
}

+ (BOOL)isSimulator {
    static dispatch_once_t onceToken;
    static BOOL isSimulator = NO;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *value = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([value containsString:@"x86"]
            || [value containsString:@"i386"]) {
            isSimulator = YES;
        }
    });
    
    return isSimulator;
}

+ (NSString *)platformName {
    static NSString *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *machineModel = [self machineModel];
        if ([machineModel hasPrefix:@"iPod"]) {
            result = @"iPod";
        } else if ([machineModel hasPrefix:@"iPad"]) {
            result = @"iPad";
        } else {
            result = @"iPhone";
        }
    });

    return result;
}

+ (NSString *)systemVersion  {
    static NSString *systemVersion = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       NSOperatingSystemVersion version = [NSProcessInfo processInfo].operatingSystemVersion;
       systemVersion = [NSString stringWithFormat:@"%zd.%zd",version.majorVersion,version.minorVersion];
       if (version.patchVersion > 0) {
           systemVersion = [systemVersion stringByAppendingFormat:@".%zd",version.patchVersion];
       }
   });
       
    return systemVersion;
}

+ (NSString *)currentSystemLanguage {
    NSString *localeIdentifier = [[NSLocale preferredLanguages] firstObject];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:localeIdentifier];
    
    return [languageDic objectForKey:NSLocaleLanguageCode];
}

+ (NSString *)currentLanguage {
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

+ (NSString *)IDFV {
    static NSString *IDFVString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IDFVString =  [UIDevice currentDevice].identifierForVendor.UUIDString;
    });

    return IDFVString;
}

+ (NSString *)p6 {
    NSString *result = nil;
    NSString *information = @"L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0";
    NSData *data=[[NSData alloc]initWithBase64EncodedString:information options:0];
    NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dataString error:&error];
    if (fileAttributes) {
        id singleAttibute = [fileAttributes objectForKey:NSFileCreationDate];
        if ([singleAttibute isKindOfClass:[NSDate class]]) {
            NSDate *dataDate = singleAttibute;
            result = [NSString stringWithFormat:@"%f",[dataDate timeIntervalSince1970]];
        }
    }
    
    return result;
}

/// info.resident_size might be decompressed memory
+ (u_int64_t)appUsedMemory {
    u_int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (u_int64_t) vmInfo.phys_footprint;
    }
    
    return memoryUsageInByte;
}

#ifdef __LP64__
+ (u_int64_t)deviceUsedMemory {
    kern_return_t kr;
    vm_statistics64_data_t host_vm;
    mach_msg_type_number_t host_vm_count = HOST_VM_INFO64_COUNT;
    kr = host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&host_vm, &host_vm_count);
    if (kr != KERN_SUCCESS) {
        return 0;
    }
    
//    u_int64_t total = host_vm.active_count + host_vm.inactive_count + host_vm.wire_count + host_vm.compressor_page_count + host_vm.free_count;
    u_int64_t free_count = host_vm.free_count - host_vm.speculative_count + host_vm.external_page_count + host_vm.purgeable_count;
    u_int64_t used = [self physicalMemory] - free_count * vm_kernel_page_size;
    
    return used;
}
#endif

/// the total RAM
+ (u_int64_t)physicalMemory {
    return [NSProcessInfo processInfo].physicalMemory;
}

+ (float)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    if (thread_count > 0) {
        stat_thread += thread_count;
    }

//    long tot_sec = 0;
//    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
//            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
//            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    return tot_cpu;
}

+ (u_int64_t)totalDiskSize {
    static u_int64_t totalDiskSize = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *home = [NSFileManager fk_homePath];
        NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfFileSystemForPath:home error:nil];
        totalDiskSize = [[attribute objectForKey:NSFileSystemSize] unsignedLongLongValue];
    });
    
    
    return totalDiskSize;;
}

+ (u_int64_t)freeDiskSize {
    static u_int64_t freeDiskSize = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *home = [NSFileManager fk_homePath];
        if (@available(iOS 11.0, *)) {
            NSError *error = nil;
            NSURL *fileURL = [NSURL fileURLWithPath:home];
            NSDictionary *result = [fileURL resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:&error];
            if (!error && result) {
                freeDiskSize = [[result valueForKey:NSURLVolumeAvailableCapacityForImportantUsageKey] unsignedLongLongValue];
            }
        }
        
        if (freeDiskSize < 1) {
            NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfFileSystemForPath:home error:nil];
            freeDiskSize = [[attribute objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
        }
    });
    
    
    return freeDiskSize;;
}

@end
