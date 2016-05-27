//
//  Pubnative.m
//
//  Created by David Martin on 12/12/14.
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

#import "Pubnative.h"

@interface Pubnative () <PubnativeAdDelegate>

@property (nonatomic, strong) PNAdRequest                   *currentRequest;
@property (nonatomic, strong) UIViewController              *currentAdVC;

@property (nonatomic, weak) NSObject<PubnativeAdDelegate>   *originalDelegate;

+ (instancetype)sharedInstance;

@end

@implementation Pubnative

#pragma mark - NSObject

- (void)dealloc
{
    self.currentRequest = nil;
}

#pragma mark - Pubnative

#pragma mark public

+ (PNTableViewCell*)dequeueFeedType:(Pubnative_FeedType)feedType
{
    return [PNTableViewManager dequeueType:feedType];
}

+ (CGFloat)heightForRowType:(Pubnative_FeedType)feedType
{
    return [PNTableViewManager heightForRowType:feedType];
}

+ (void)requestAdType:(Pubnative_AdType)type
       withParameters:(PNAdRequestParameters*)parameters
          andDelegate:(NSObject<PubnativeAdDelegate>*)delegate
{
    PNAdRequestType requestType = PNAdRequest_Native;
    
    switch (type)
    {
        case Pubnative_AdType_GameList:
        {
            parameters.ad_count = @8;
            parameters.icon_size = @"200x200";
        }
        break;
            
        case Pubnative_AdType_VideoBanner:
        {
            requestType = PNAdRequest_Native_Video;
            parameters.banner_size = @"1200x627";
        }
        break;
            
        case Pubnative_AdType_VideoInterstitial:
        {
            parameters.icon_size = @"200x200";
            requestType = PNAdRequest_Native_Video;
        }
            
        case Pubnative_AdType_Banner:
        {
            parameters.icon_size = @"100x100";
        }
        break;
            
        case Pubnative_AdType_Interstitial:
        {
            parameters.icon_size = @"400x400";
            parameters.banner_size = @"1200x627";
        }
        break;
            
        case Pubnative_AdType_Icon:
        {
            parameters.icon_size = @"400x400";
        }
        break;
    }
    
    __block Pubnative_AdType adType = type;
    __weak NSObject<PubnativeAdDelegate> *weakDelegate = delegate;
    [Pubnative sharedInstance].currentRequest = [PNAdRequest request:requestType
                                                      withParameters:parameters
                                                       andCompletion:^(NSArray *ads, NSError *error)
    {
        if(error)
        {
            [self invokeDidFailWithError:error
                                delegate:weakDelegate];
        }
        else
        {
            [Pubnative cleanCurrentAdVC];
            
            UIViewController *adVC = [Pubnative createType:adType
                                                   withAds:ads];
            
            if(adVC)
            {
                [Pubnative sharedInstance].originalDelegate = weakDelegate;
                [Pubnative sharedInstance].currentAdVC = adVC;
                UIView *adView = adVC.view;
                #pragma unused(adView)
            }
            else
            {
                NSString *errorString = [NSString stringWithFormat:@"Pubnative error creating the selected type %ld", (long)adType];
                NSError *creationError = [NSError errorWithDomain:errorString
                                                             code:0
                                                         userInfo:nil];
                [self invokeDidFailWithError:creationError
                                    delegate:weakDelegate];
            }
        }
    }];
    
    [[Pubnative sharedInstance].currentRequest startRequest];
}

+ (void)cleanCurrentAdVC
{
    if([Pubnative sharedInstance].currentAdVC)
    {
        if([[Pubnative sharedInstance].currentAdVC respondsToSelector:@selector(setDelegate:)])
        {
            [[Pubnative sharedInstance].currentAdVC performSelector:@selector(setDelegate:) withObject:[Pubnative sharedInstance].originalDelegate];
        }
        
        [Pubnative sharedInstance].currentAdVC = nil;
        [Pubnative sharedInstance].originalDelegate = nil;
    }
}

+ (void)invokeDidFailWithError:(NSError*)error delegate:(NSObject<PubnativeAdDelegate>*)delegate
{
    if(delegate && [delegate respondsToSelector:@selector(pnAdDidFail:)])
    {
        [delegate pnAdDidFail:error];
    }
}

#pragma mark private

+ (instancetype)sharedInstance
{
    static Pubnative *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Pubnative alloc] init];
    });
    return _sharedInstance;
}

+ (UIViewController*)createType:(Pubnative_AdType)type withAds:(NSArray*)ads
{
    UIViewController *result = nil;
    switch (type)
    {
        case Pubnative_AdType_Banner:               result = [Pubnative createAdTypeBannerWithAd:[ads firstObject]];            break;
        case Pubnative_AdType_VideoBanner:          result = [Pubnative createAdTypeVideoBannerWithAd:[ads firstObject]];       break;
        case Pubnative_AdType_VideoInterstitial:    result = [Pubnative createAdTypeVideoInterstitialWithAd:[ads firstObject]]; break;
        case Pubnative_AdType_Interstitial:         result = [Pubnative createAdTypeInterstitialWithAd:[ads firstObject]];      break;
        case Pubnative_AdType_Icon:                 result = [Pubnative createAdTypeIconWithAd:[ads firstObject]];              break;
        case Pubnative_AdType_GameList:             result = [Pubnative createAdTypeGameListWithAd:ads];                        break;
    }
    return result;
}

+ (UIViewController*)createAdTypeBannerWithAd:(PNNativeAdModel*)ad
{
    PNBannerViewController *result = [[PNBannerViewController alloc] initWithNibName:NSStringFromClass([PNBannerViewController class])
                                                                              bundle:[NSBundle bundleForClass:[PNBannerViewController class]]
                                                                               model:ad];
    result.delegate = [Pubnative sharedInstance];
    return result;
}

+ (UIViewController*)createAdTypeVideoBannerWithAd:(PNNativeAdModel*)ad
{
    PNVideoBannerViewController *result = [[PNVideoBannerViewController alloc] initWithNibName:NSStringFromClass([PNVideoBannerViewController class])
                                                                                        bundle:[NSBundle bundleForClass:[PNVideoBannerViewController class]]
                                                                                         model:(PNNativeVideoAdModel*)ad];
    result.delegate = [Pubnative sharedInstance];
    return result;
}

+ (UIViewController*)createAdTypeVideoInterstitialWithAd:(PNNativeAdModel*)ad
{
    PNVideoInterstitialViewController *result = [[PNVideoInterstitialViewController alloc] initWithNibName:NSStringFromClass([PNVideoInterstitialViewController class])
                                                                                                    bundle:[NSBundle bundleForClass:[PNVideoInterstitialViewController class]]
                                                                                                     model:(PNNativeVideoAdModel*)ad];
    result.delegate = [Pubnative sharedInstance];
    return result;
}

+ (UIViewController*)createAdTypeInterstitialWithAd:(PNNativeAdModel*)ad
{
    PNInterstitialAdViewController *result = [[PNInterstitialAdViewController alloc] initWithNibName:NSStringFromClass([PNInterstitialAdViewController class])
                                                                                              bundle:[NSBundle bundleForClass:[PNInterstitialAdViewController class]]
                                                                                               model:ad];
    result.delegate = [Pubnative sharedInstance];
    return result;
}

+ (UIViewController*)createAdTypeIconWithAd:(PNNativeAdModel*)ad
{
    PNIconViewController *result = [[PNIconViewController alloc] initWithNibName:NSStringFromClass([PNIconViewController class])
                                                                          bundle:[NSBundle bundleForClass:[PNIconViewController class]]
                                                                           model:ad];
    result.delegate = [Pubnative sharedInstance];
    return result;
}

+ (UIViewController*)createAdTypeGameListWithAd:(NSArray*)ads
{
    PNGameListAdViewController *result = [[PNGameListAdViewController alloc] initWithNibName:NSStringFromClass([PNGameListAdViewController class])
                                                                                      bundle:[NSBundle bundleForClass:[PNGameListAdViewController class]]
                                                                                         ads:ads];
    result.delegate = [Pubnative sharedInstance];
    return result;
}

#pragma mark - DELEGATES -
#pragma PubnativeAdDelegate

- (void)pnAdDidLoad:(UIViewController *)ad
{
    if(self.originalDelegate)
    {
        if([self.originalDelegate respondsToSelector:@selector(pnAdDidLoad:)])
        {
            [self.originalDelegate pnAdDidLoad:ad];
        }
    }
    else
    {
        [Pubnative cleanCurrentAdVC];
    }
}

- (void)pnAdReady:(UIViewController*)ad
{
    if(self.originalDelegate)
    {
        if([self.originalDelegate respondsToSelector:@selector(pnAdReady:)])
        {
            [self.originalDelegate pnAdReady:ad];
        }
    }
    else
    {
        [Pubnative cleanCurrentAdVC];
    }
}

- (void)pnAdDidFail:(NSError *)error
{
    if(self.originalDelegate)
    {
        if([self.originalDelegate respondsToSelector:@selector(pnAdDidFail:)])
        {
            [self.originalDelegate pnAdDidFail:error];
        }
    }
    else
    {
        [Pubnative cleanCurrentAdVC];
    }
}

- (void)pnAdWillShow
{
    if(self.originalDelegate)
    {
        if([self.originalDelegate respondsToSelector:@selector(pnAdWillShow)])
        {
            [self.originalDelegate pnAdWillShow];
        }
    }
    else
    {
        [Pubnative cleanCurrentAdVC];
    }
}

- (void)pnAdDidShow
{
    if(self.originalDelegate)
    {
        if([self.originalDelegate respondsToSelector:@selector(pnAdDidShow)])
        {
            [self.originalDelegate pnAdDidShow];
        }
    }
    else
    {
        [Pubnative cleanCurrentAdVC];
    }
}

- (void)pnAdWillClose
{
    if(self.originalDelegate)
    {
        if([self.originalDelegate respondsToSelector:@selector(pnAdWillClose)])
        {
            [self.originalDelegate pnAdWillClose];
        }
    }
    else
    {
        [Pubnative cleanCurrentAdVC];
    }
}

- (void)pnAdDidClose
{
    if([self.originalDelegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.originalDelegate pnAdDidClose];
    }
    
    [Pubnative cleanCurrentAdVC];
}

@end
