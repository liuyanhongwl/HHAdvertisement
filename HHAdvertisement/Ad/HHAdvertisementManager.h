//
//  HHAdvertisementManager.h
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class PNNativeAdModel;
@class FBNativeAd;

@interface HHAdvertisementManager : NSObject

@property (nonatomic, assign) NSUInteger count;

- (void)fetchFBNatives:(void (^)(NSArray<FBNativeAd *> *resultArray))completion;

- (void)fetchAdColonyNativeAdViews:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)vc;

- (void)fetchPNNatives:(void (^)(NSArray<PNNativeAdModel *> *resultArray))completion;

- (void)fetchMobVista:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)viewController;

@end
