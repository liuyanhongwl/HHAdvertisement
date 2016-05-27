//
//  PNCacheManager.m
//  PubNativeDemo
//
//  Created by Csongor Nagy on 18/12/14.
//  Copyright (c) 2014 PubNative. All rights reserved.
//

#import "PNCacheManager.h"

NSString * const kPNCacheNamespace = @"pubnative_cache";

@implementation PNCacheManager

+ (void)dataWithURLString:(NSString*)urlString
               andCompletion:(PNCacheManagerCompletionBlock)completionBlock
{
    if([PNCroissantCache hasCachedDataWithName:urlString])
    {
        completionBlock([PNCroissantCache cachedDataWithName:urlString]);
    }
    else
    {
        dispatch_queue_t portraitBannerDownloadQueue = dispatch_queue_create(nil, NULL);
        dispatch_async(portraitBannerDownloadQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [PNCroissantCache cacheData:data witName:urlString];
                completionBlock(data);
            });
        });
    }
}

@end
