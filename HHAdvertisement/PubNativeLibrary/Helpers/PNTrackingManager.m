//
//  PNTrackingManager.m
//
//  Created by Csongor Nagy on 04/06/14.
//  Copyright (c) 2014 PubNative
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "PNTrackingManager.h"
#import "PNAdConstants.h"

NSString * const kPNTrackingManagerErrorBeacon  = @"PNTrackingManager - beacon error";

@interface PNTrackingManager ()

@end

@implementation PNTrackingManager

static PNTrackingManager *sharedManager = nil;

#pragma mark NSObject

#pragma mark PNTrackingManager

+ (NSMutableArray*)confirmedAds
{
    NSMutableArray *result = nil;
    result = [[[NSUserDefaults standardUserDefaults] objectForKey:kPNAdConstantTrackingConfirmedAdsKey] mutableCopy];
    if(!result)
    {
        result = [[NSMutableArray alloc] init];
    }
    return result;
}

+ (void)setConfirmedAds:(NSMutableArray*)confirmedAds
{
    [[NSUserDefaults standardUserDefaults] setObject:confirmedAds forKey:kPNAdConstantTrackingConfirmedAdsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)trackURLString:(NSString*)confirmURLString completion:(PNTrackingCompletedBlock)completion
{
    [PNTrackingManager confirmWithURLString:confirmURLString urlScheme:nil completion:completion];
}

+ (void)trackImpressionWithAd:(PNNativeAdModel*)ad completion:(PNTrackingCompletedBlock)completion
{
    __block PNBeaconModel *beacon = nil;
    
    if (ad.beacons)
    {
        [ad.beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             PNBeaconModel *beaconItem = (PNBeaconModel*)obj;
             if ([beaconItem.type isEqualToString:kPNAdConstantTrackingBeaconImpressionTypeString] && beaconItem.url)
             {
                 beacon = obj;
                 *stop = YES;
                 return;
             }
         }];
    }
    else
    {
        if (completion)
        {
            NSError *error = [NSError errorWithDomain:kPNTrackingManagerErrorBeacon
                                                 code:0
                                             userInfo:nil];
            completion(nil, error);
        }
        return;
    }
    
    if(beacon == nil)
    {
        if(completion)
        {
            NSError *error = [NSError errorWithDomain:kPNTrackingManagerErrorBeacon
                                                 code:0
                                             userInfo:nil];
            completion(nil, error);
        }
    }
    else
    {
        NSString *urlScheme = nil;
        if ((NSNull*)ad.app_details.url_scheme != [NSNull null])
        {
            urlScheme = ad.app_details.url_scheme;
        }

        [PNTrackingManager confirmWithURLString:beacon.url urlScheme:urlScheme completion:completion];
    }
}



+ (void)confirmWithURLString:(NSString*)confirmURLString urlScheme:(NSString*)urlScheme completion:(PNTrackingCompletedBlock)completion
{
    if (![[PNTrackingManager confirmedAds] containsObject:confirmURLString])
    {
        NSString *requestURLString = confirmURLString;
        if (urlScheme)
        {
            requestURLString = [confirmURLString stringByAppendingString:@"&installed=1"];
        }
        
        NSURL *requestURL = [NSURL URLWithString:requestURLString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:30];
        
        [request setHTTPMethod:kPNAdConstantMethodGET];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    if(error)
                    {
                        if(completion)
                        {
                            completion(nil, error);
                        }
                    }
                    else
                    {
                        NSMutableArray *confirmedAds = [PNTrackingManager confirmedAds];
                        [confirmedAds addObject:confirmURLString];
                        [PNTrackingManager setConfirmedAds:confirmedAds];

                        if(completion)
                        {
                            completion(response, nil);
                        }
                    }
                });
            }];
        });
    }
}

@end
