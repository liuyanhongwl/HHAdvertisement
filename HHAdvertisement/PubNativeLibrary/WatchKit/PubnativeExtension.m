//
//  PubnativeExtension.m
//
//  Created by David Martin on 23/03/2015
//  Copyright (c) 2015 PubNative
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

#import "PubnativeExtension.h"
#import "Pubnative.h"

typedef NS_ENUM(NSInteger, PubnativeExtension_BindingType)
{
    PubnativeExtension_BindingType_Request = 0,
    PubnativeExtension_BindingType_Track = 1,
    PubnativeExtension_BindingType_Open = 2
};

typedef void (^WKExtensionReply)(NSDictionary *reply);

@interface PubnativeExtension ()

@property (strong, nonatomic) PNAdRequest *request;
@end

@implementation PubnativeExtension

+ (instancetype)sharedExtension
{
    static PubnativeExtension *_sharedExtension;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedExtension = [[PubnativeExtension alloc] init];
    });
    return _sharedExtension;
}

+ (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    [[PubnativeExtension sharedExtension] application:application
                       handleWatchKitExtensionRequest:userInfo
                                                reply:reply];
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    NSNumber *bindingType = [userInfo objectForKey:@"type"];
    switch ([bindingType integerValue])
    {
        case PubnativeExtension_BindingType_Request:    [self handleRequestWithDictionary:userInfo reply:reply];    break;
        case PubnativeExtension_BindingType_Track:      [self handleTrackWithDictionary:userInfo reply:reply];      break;
        case PubnativeExtension_BindingType_Open:       [self handleOpenWithDictionary:userInfo reply:reply];       break;
    }
}

- (void)handleRequestWithDictionary:(NSDictionary*)dictionary reply:(void (^)(NSDictionary *))reply
{
    NSString *appToken = [dictionary objectForKey:@"app_token"];
    
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    parameters.app_token = appToken;
    parameters.ad_count = @1;
    parameters.icon_size = @"400x400";
    
    self.request = [PNAdRequest request:PNAdRequest_Native
                         withParameters:parameters
                          andCompletion:^(NSArray *ads, NSError *error)
                    {
                        if(error)
                        {
                            if(reply)
                            {
                                reply(@{@"error":[error description]});
                            }
                        }
                        else
                        {
                            if(ads.count > 0)
                            {
                                __block PNNativeAdModel *model = [ads firstObject];
                                if(model &&
                                   model != nil &&
                                   ((NSNull*)model) != [NSNull null])
                                {
                                    [self requestDataWithURL:model.icon_url
                                                  completion:^(NSData * iconData)
                                    {
                                        [self requestDataWithURL:model.banner_url
                                                      completion:^(NSData *bannerData)
                                        {
                                            if(reply)
                                            {
                                                reply([self resultDictionaryWithModel:model
                                                                             iconData:iconData
                                                                           bannerData:bannerData]);
                                            }
                                        }];
                                    }];
                                }
                                else
                                {
                                    if(reply)
                                    {
                                        reply(@{@"error":@"Pubnative - error with data"});
                                    }
                                }
                            }
                            else
                            {
                                if(reply)
                                {
                                    reply(@{@"error":@"Pubnative - no ads to fill"});
                                }
                            }
                        }
                    }];
    
    [self.request startRequest];
}

- (void)requestDataWithURL:(NSString*)urlString completion:(void(^)(NSData* data))completion
{
    if(urlString &&
       [NSNull null] != ((NSNull*)urlString))
    {
        [PNCacheManager dataWithURLString:urlString
                            andCompletion:^(NSData *data)
         {
             if(completion)
             {
                 completion(data);
             }
         }];
    }
    else
    {
        if(completion)
        {
            completion(nil);
        }
    }
}


- (NSDictionary*)resultDictionaryWithModel:(PNNativeAdModel*)model iconData:(NSData*)iconData bannerData:(NSData*)bannerData
{
    return @{
             @"title" : model.title,
             @"icon" : iconData,
             @"banner" : bannerData,
             @"click_url" : model.click_url,
             @"cta_text" : model.cta_text,
             @"description" : model.Description,
             @"impression_url" : [self impressionURLWithModel:model]
            };
}

- (NSString*)impressionURLWithModel:(PNNativeAdModel*)model
{
    __block NSString *result = @"";
    
    if(model.beacons)
    {
        [model.beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            PNBeaconModel *beaconItem = (PNBeaconModel*)obj;
            if ([beaconItem.type isEqualToString:@"impression"] && beaconItem.url)
            {
                result = beaconItem.url;
                *stop = YES;
            }
        }];
    }
    
    return result;
}

- (void)handleTrackWithDictionary:(NSDictionary*)dictionary reply:(void (^)(NSDictionary *))reply
{
    NSString *track_url = [dictionary objectForKey:@"url"];
    [PNTrackingManager trackURLString:track_url completion:^(id result, NSError *error)
    {
        if(error)
        {
            if(reply)
            {
                reply(@{@"error":[error description]});
            }
        }
        else
        {
            if(reply)
            {
                reply(nil);
            }
        }
    }];
}

- (void)handleOpenWithDictionary:(NSDictionary*)dictionary reply:(void (^)(NSDictionary *))reply
{
    NSString *open_url = [dictionary objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:open_url]];
}

@end
