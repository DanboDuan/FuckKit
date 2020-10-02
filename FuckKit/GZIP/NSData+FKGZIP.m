//
//  NSData+FKGZIP.m
//  FuckKit
//
//  Created by bob on 2020/6/12.
//

#import "NSData+FKGZIP.h"
#import <zlib.h>

static const int kGodzippaChunkSize = 1024;
static const int kGodzippaDefaultMemoryLevel = 8;
static const int kGodzippaDefaultWindowBits = 15;
static const int kGodzippaDefaultWindowBitsWithGZipHeader = 16 + kGodzippaDefaultWindowBits;
static NSString * const GodzippaZlibErrorDomain = @"com.godzippa.zlib.error";

@implementation NSData (FKGZIP)


- (NSData *)fk_dataByGZipCompressingWithError:(NSError * __autoreleasing *)error {
    return [self fk_dataByGZipCompressingAtLevel:Z_DEFAULT_COMPRESSION
                                       windowSize:kGodzippaDefaultWindowBitsWithGZipHeader
                                      memoryLevel:kGodzippaDefaultMemoryLevel
                                         strategy:Z_DEFAULT_STRATEGY
                                            error:error];
}

- (NSData *)fk_dataByGZipCompressingAtLevel:(int)level
                                  windowSize:(int)windowBits
                                 memoryLevel:(int)memLevel
                                    strategy:(int)strategy
                                       error:(NSError * __autoreleasing *)error {
    if ([self length] == 0) {
        return self;
    }

    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));

    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.next_in = (Bytef *)[self bytes];
    zStream.avail_in = (unsigned int)[self length];
    zStream.total_out = 0;

    OSStatus status;
    if ((status = deflateInit2(&zStream, level, Z_DEFLATED, windowBits, memLevel, strategy)) != Z_OK) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed deflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain
                                                code:status
                                            userInfo:userInfo];
        }

        return nil;
    }

    NSMutableData *compressedData = [NSMutableData dataWithLength:kGodzippaChunkSize];

    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [compressedData length])) {
            [compressedData increaseLengthBy:kGodzippaChunkSize];
        }

        zStream.next_out = (Bytef*)[compressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([compressedData length] - zStream.total_out);

        status = deflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));

    deflateEnd(&zStream);

    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error deflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain
                                                code:status
                                            userInfo:userInfo];
        }

        return nil;
    }

    [compressedData setLength:zStream.total_out];

    return compressedData;
}

- (BOOL)fk_isGzipCompressedData {
    if (self.length < 3) {
        return NO;
    }

    NSData *subdata = [self subdataWithRange:NSMakeRange(0, 3)];
    const Byte *bytes = (const Byte *)subdata.bytes;
    return bytes[0] == 0x1f && bytes[1] == 0x8b && bytes[2] == 0x08;
}


- (NSData *)fk_dataByGZipDecompressingDataWithError:(NSError * __autoreleasing *)error {
    return [self fk_dataByGZipDecompressingDataWithWindowSize:kGodzippaDefaultWindowBitsWithGZipHeader
                                                         error:error];
}

- (NSData *)fk_dataByGZipDecompressingDataWithWindowSize:(int)windowBits
                                                    error:(NSError * __autoreleasing *)error {
    if ([self length] == 0) {
        return self;
    }

    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));

    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.avail_in = (unsigned int)[self length];
    zStream.next_in = (Byte *)[self bytes];

    OSStatus status;
    if ((status = inflateInit2(&zStream, windowBits)) != Z_OK) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed inflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }

    NSUInteger estimatedLength = (NSUInteger)((double)[self length] * 1.5);
    NSMutableData *decompressedData = [NSMutableData dataWithLength:estimatedLength];

    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [decompressedData length])) {
            [decompressedData increaseLengthBy:estimatedLength / 2];
        }

        zStream.next_out = (Bytef*)[decompressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([decompressedData length] - zStream.total_out);

        status = inflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));

    inflateEnd(&zStream);

    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error inflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }

    [decompressedData setLength:zStream.total_out];

    return decompressedData;
}

@end
