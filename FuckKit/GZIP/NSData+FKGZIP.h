//
//  NSData+FKGZIP.h
//  FuckKit
//
//  Created by bob on 2020/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (FKGZIP)

/// GZIP
- (nullable NSData *)fk_dataByGZipCompressingWithError:(NSError * __autoreleasing *)error;
- (BOOL)fk_isGzipCompressedData;
- (nullable NSData *)fk_dataByGZipDecompressingDataWithError:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
