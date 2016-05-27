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
#import "Pubnative.h"
#import "HHMobVistaManager.h"

@interface HHAdvertisementManager ()<FBNativeAdsManagerDelegate>

@property (nonatomic, strong) FBNativeAdsManager *fbManager;
@property (nonatomic, strong) PNAdRequest *pnRequest;
@property (nonatomic, strong) HHMobVistaManager *mvManager;
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

- (void)dealloc
{
    self.pnRequest = nil;
}

#pragma mark - Public

- (void)fetchFBNatives:(void (^)(NSArray<FBNativeAd *> *resultArray))completion
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

- (void)fetchPNNatives:(void (^)(NSArray<PNNativeAdModel *> *resultArray))completion
{
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    [parameters fillWithDefaults];
    parameters.app_token = @"e1a8e9fcf8aaeff31d1ddaee1f60810957f4c297859216dea9fa283043f8680f";
    parameters.ad_count = @20;
        
    self.pnRequest = [PNAdRequest request:PNAdRequest_Native withParameters:parameters andCompletion:^(NSArray *ads, NSError *error) {
        if(error)
        {
            NSLog(@"Pubnative - Request error: %@", error);
        }
        else
        {
            NSLog(@"Pubnative - Request end");
            
            if(completion){
                completion(ads);
            }
        }
    }];
    
    [self.pnRequest startRequest];
}

- (void)fetchMobVista:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)viewController
{
    self.mvManager = [[HHMobVistaManager alloc] init];
    
    [self.mvManager fetchMobVista:completion presentingViewController:viewController];
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
