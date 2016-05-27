//
//  SUAdCell.h
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FBNativeAd;
@class PNNativeAdModel;

@interface HHAdCell : UITableViewCell

@property (nonatomic, strong) FBNativeAd *fbAd;

@property (nonatomic, strong) PNNativeAdModel *pnAd;

@end
