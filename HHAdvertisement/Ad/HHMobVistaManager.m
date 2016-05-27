//
//  HHMobVistaManager.m
//  HHAdvertisement
//
//  Created by Hong on 16/5/24.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHMobVistaManager.h"
#import <MVSDK/MVSDK.h>

#define KMobVista_NativeUnitID @"128"
#define KMobVista_PlacementID @"448464445332858_460157654163537"

@interface HHMobVistaManager ()<MVNativeAdManagerDelegate>

@property (nonatomic, strong) MVNativeAdManager *mvManager;

@end

@implementation HHMobVistaManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[MVSDK sharedInstance] setAppID:@"22050" ApiKey:@"7c22942b749fe6a6e361b675e96b3ee9"];
        
        
    }
    return self;
}


- (void)fetchMobVista:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)viewController
{
    _mvManager = [[MVNativeAdManager alloc] initWithUnitID:KMobVista_NativeUnitID fbPlacementId:KMobVista_PlacementID supportedTemplates:@[[MVTemplate templateWithType:MVAD_TEMPLATE_ONLY_ICON adsNum:50]] autoCacheImage:NO adCategory:MVAD_CATEGORY_GAME presentingViewController:viewController];
    
    self.mvManager.delegate = self;
    
    [_mvManager loadAds];
}

#pragma mark - Delegate
#pragma mark MVNativeAdManagerDelegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds
{
    
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error
{
    
}

- (void)nativeAdDidClick:(nonnull MVCampaign *)nativeAd
{
    
}

- (void)nativeAdClickUrlWillStartToJump:(nonnull NSURL *)clickUrl
{
    
}

- (void)nativeAdClickUrlDidJumpToUrl:(nonnull NSURL *)jumpUrl
{
    
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error
{
    
}

@end
