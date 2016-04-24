//
//  HHAdvertisementManager.m
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHAdvertisementManager.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <AdColony/AdColony.h>
#import <AdColony/AdColonyNativeAdView.h>

@interface HHAdvertisementManager ()<FBNativeAdsManagerDelegate>

@property (nonatomic, strong) FBNativeAdsManager *fbManager;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) void (^completion)(NSArray *resultArray);

@end

@implementation HHAdvertisementManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //todo
        [FBAdSettings addTestDevice:@"38ac80e0cac4c665150d5c2c25427dbc34a3a062"];

        _fbManager = [[FBNativeAdsManager alloc] initWithPlacementID:@"424528284338714_431368383654704" forNumAdsRequested:20];
        self.fbManager.delegate = self;
        self.isLoading = NO;
        
        [AdColony configureWithAppID:@"app47e016d62e2f46df9f" zoneIDs:@[@"vzbf66d21d8c174fd794"] delegate:nil logging:YES];
    }
    return self;
}

#pragma mark - Public

- (void)fetchFBNatives:(void (^)(NSArray *resultArray))completion
{
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    self.completion = completion;
    [self.fbManager loadAds];
}

- (void)fetchAdColonyNativeAdViews:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)vc
{
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    for (int i = 0; i < 20; i ++) {
        AdColonyNativeAdView *adView = [AdColony getNativeAdForZone:@"vzbf66d21d8c174fd794" presentingViewController:vc];
        adView.muted = YES;
        if (adView) {
            [dataArray addObject:adView];
        }
    }
    
    if (self.completion) {
        self.completion(dataArray);
    }
    
    self.isLoading = NO;
}

#pragma mark - Delegate
#pragma mark #pragma mark FBNativeAdsManagerDelegate

- (void)nativeAdsLoaded
{
    NSMutableArray *dataArray = [NSMutableArray array];
    
    FBNativeAd *ad = nil;
    for (int i=0; i<self.fbManager.uniqueNativeAdCount; i++) {
        ad = self.fbManager.nextNativeAd;
        if (ad) {
            [dataArray addObject:ad];
        }
    }

    if (self.completion) {
        self.completion(dataArray);
    }
    
    self.isLoading = NO;
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error
{
    if (self.completion) {
        self.completion(nil);
    }
    
    self.isLoading = NO;
}

@end
