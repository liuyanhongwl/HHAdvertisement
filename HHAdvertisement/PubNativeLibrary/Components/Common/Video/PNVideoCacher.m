//
// PNVideoCacher.m
//
// Created by Csongor Nagy on 10/03/14.
// Copyright (c) 2014 PubNative
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PNVideoCacher.h"
#import <CommonCrypto/CommonDigest.h>

NSString * const kPNVideoCacherServerNotAvailable   = @"Pubnative server not available";
NSString * const kPNVideoCacherNamespace            = @"com.pubnative.VideoDownloader";

@interface PNVideoCacher () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData     *responseData;
@property (nonatomic, strong) NSURLConnection   *connection;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) NSString          *videoUrl;
@property (nonatomic, strong) dispatch_queue_t  videoCacheQueue;

- (void)invokeCacherDidCache:(NSString*)file;
- (void)invokeCacherDidFail:(NSError*)error;
+ (NSString*)cacheFolder;

@end

@implementation PNVideoCacher

- (void)dealloc
{
    [self cancelCaching];
    
    self.videoCacheQueue = nil;
    self.httpResponse = nil;
    self.responseData = nil;
    self.videoUrl = nil;
}

- (id)initWithURL:(NSString*)url
{
    self = [super init];
    
    if (self)
    {
        self.videoUrl = url;
        self.responseData = nil;
    }
    
    return self;
}

- (void)startCaching
{
    if ([self hasCachedDataWithName:self.videoUrl])
    {
        [self invokeCacherDidCache:[NSString stringWithFormat:@"%@/%@", [PNVideoCacher cacheFolder], [self getCachedNameFromURL:self.videoUrl]]];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.videoUrl]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60];
    
    self.responseData = [NSMutableData dataWithCapacity:0];
    
    self.connection = [NSURLConnection connectionWithRequest:request
                                                    delegate:self];
    
    if (!self.connection)
    {
        self.responseData = nil;
        
        NSError *result = nil;
        NSString *domain = @"ResourceNotAvailable";
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:domain forKey:NSLocalizedDescriptionKey];
        result = [NSError errorWithDomain:domain
                                     code:0
                                 userInfo:userInfo];
        [self invokeCacherDidFail:result];
    }
    else
    {
        [self.connection start];
    }
}

- (void)cancelCaching
{
    [self.connection cancel];
    self.connection = nil;
}

+ (BOOL)cleanCache
{
    NSFileManager *fileManager = [NSFileManager new];
    return [fileManager removeItemAtPath:[PNVideoCacher cacheFolder]
                                   error:nil];
}


#pragma mark - Private Methods

+ (NSString*)cacheFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [paths[0] stringByAppendingPathComponent:kPNVideoCacherNamespace];
    
    NSFileManager *fileManager = [NSFileManager new];
    
    if (![fileManager fileExistsAtPath:diskCachePath])
    {
        [fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return diskCachePath;
}

- (NSString*)cacheData:(NSData*)data witName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager new];
    NSString *newName = [[PNVideoCacher cacheFolder] stringByAppendingPathComponent:[self getCachedNameFromURL:self.videoUrl]];
    [fileManager createFileAtPath:newName
                         contents:data
                       attributes:nil];
    return newName;
}

- (BOOL)hasCachedDataWithName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager new];
    return [fileManager fileExistsAtPath:[[PNVideoCacher cacheFolder] stringByAppendingPathComponent:[self getCachedNameFromURL:self.videoUrl]]];
}

- (NSData*)cachedDataWithName:(NSString*)name
{
    NSData *data;
    
    if ([self hasCachedDataWithName:name])
    {
        data = [NSData dataWithContentsOfFile:[[PNVideoCacher cacheFolder] stringByAppendingPathComponent:[self getCachedNameFromURL:self.videoUrl]]];
    }
    
    return data;
}

- (NSString*)getCachedNameFromURL:(NSString*)urlString
{
    if ([urlString length] <= 0) { return nil; }
    
	const char *cStringToHash = [urlString UTF8String];
	unsigned char hash[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStringToHash, (CC_LONG)(strlen(cStringToHash)), hash);
	
	NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
    {
        [hashString appendFormat:@"%02X", hash[i]];
    }
	NSString *result = [NSString stringWithFormat:@"%@.mp4", hashString];
    return result;
}


- (void)invokeCacherDidCache:(NSString*)file
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        if(self.delegate && [self.delegate respondsToSelector:@selector(videoCacherDidCache:)])
        {
            [self.delegate videoCacherDidCache:file];
        }
    });
}

- (void)invokeCacherDidFail:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        if(self.delegate && [self.delegate respondsToSelector:@selector(videoCacherDidFail:)])
        {
            [self.delegate videoCacherDidFail:error];
        }
    });
}

#pragma mark - DELEGATE -

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.httpResponse = (NSHTTPURLResponse*)response;
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(self.httpResponse.statusCode != 304)
    {
        NSDictionary *headers = [self.httpResponse allHeaderFields];
        NSString *contentType = [headers objectForKey:@"Content-Type"];
        if(contentType && [contentType isKindOfClass:[NSString class]] && [contentType containsString:@"video/"])
        {
            [self invokeCacherDidCache:[self cacheData:self.responseData witName:self.videoUrl]];
            
        }
        else
        {
            NSError *error = [NSError errorWithDomain:kPNVideoCacherServerNotAvailable
                                                 code:0
                                             userInfo:nil];
            [self invokeCacherDidFail:error];
        }
    }
    else
    {
        NSError *error = [NSError errorWithDomain:kPNVideoCacherServerNotAvailable
                                             code:0
                                         userInfo:nil];
        [self invokeCacherDidFail:error];
    }
    
    self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseData = nil;
    [self invokeCacherDidFail:error];
}

@end
