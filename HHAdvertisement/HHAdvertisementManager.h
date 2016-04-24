//
//  HHAdvertisementManager.h
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HHAdvertisementManager : NSObject

@property (nonatomic, assign) NSUInteger count;

- (void)fetchFBNatives:(void (^)(NSArray *resultArray))completion;

- (void)fetchAdColonyNativeAdViews:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)vc;

@end
