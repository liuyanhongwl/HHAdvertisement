//
//  HHMobVistaManager.h
//  HHAdvertisement
//
//  Created by Hong on 16/5/24.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HHMobVistaManager : NSObject

- (void)fetchMobVista:(void (^)(NSArray *resultArray))completion presentingViewController:(UIViewController *)viewController;

@end
