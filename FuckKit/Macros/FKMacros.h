//
//  FKMacros.h
//  FuckKit
//
//  Created by bob on 2020/4/27.
//

#ifndef FKMacros_h
#define FKMacros_h

#ifndef FK_WeakSelf
#define FK_WeakSelf __weak typeof(self) wself = self
#endif

#ifndef FK_StrongSelf
#define FK_StrongSelf __strong typeof(wself) self = wself
#endif

#ifndef FK_Lock
#define FK_Lock(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef FK_Unlock
#define FK_Unlock(lock) dispatch_semaphore_signal(lock);
#endif

#ifndef FK_isNotStrOrEmptyStr
#define FK_isNotStrOrEmptyStr(str) (!str || ![str isKindOfClass:[NSString class]] || str.length < 1)
#endif

#ifndef FK_isNotArrayOrEmptyArray
#define FK_isNotArrayOrEmptyArray(array) (!array || ![array isKindOfClass:[NSArray class]] || array.count < 1)
#endif

#ifndef FK_isNotDictOrEmptyDict
#define FK_isNotDictOrEmptyDict(dict) (!dict || ![dict isKindOfClass:[NSDictionary class]] || ((NSDictionary *)dict).count < 1)
#endif

#ifndef FKLog
#if DEBUG
    #define FKLog(s, ...) \
    fprintf(stderr, "<%s:%-4d> %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String])
#else
    #define FKLog(s, ...)
#endif
#endif

#define _FK_CONCAT(A, B) A ## B
#define FKIdentifier(NAME, COUNTER) _FK_CONCAT(NAME, COUNTER)
#define FKSectionNameData(sectname) __attribute((used, no_sanitize_address, section("__DATA,"#sectname" ")))

#endif /* FKMacros_h */
