//
//  PNAdRenderingManager.m
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

#import "PNAdRenderingManager.h"

NSString *kPNAdRenderingManagerIconNotification = @"kPNAdRenderingManagerIconNotification";
NSString *kPNAdRenderingManagerBannerNotification = @"kPNAdRenderingManagerBannerNotification";
NSString *kPNAdRenderingManagerPortraitBannerNotification = @"kPNAdRenderingManagerPortraitBannerNotification";

@interface PNAdRenderingManager ()

+ (BOOL)isNotNullOrEmpty:(id)value;

@end

@implementation PNAdRenderingManager

#pragma mark PNAdRenderingManager

+ (void)renderNativeAdItem:(PNNativeAdRenderItem*)renderItem withAd:(PNNativeAdModel*)ad
{
    if (ad)
    {
        if (renderItem.title && [PNAdRenderingManager isNotNullOrEmpty:ad.title])
        {
            renderItem.title.text = ad.title;
        }
        if (renderItem.descriptionField && [PNAdRenderingManager isNotNullOrEmpty:ad.Description])
        {
            renderItem.descriptionField.text = ad.Description;
        }
        
        if (renderItem.icon && [PNAdRenderingManager isNotNullOrEmpty:ad.icon_url])
        {
            renderItem.icon.alpha = 0;
            [PNCacheManager dataWithURLString:ad.icon_url
                                andCompletion:^(NSData *data) {
                                    
                                    UIImage *iconImage = [UIImage imageWithData:data];
                                    
                                    dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        [renderItem.icon setImage:iconImage];
                                        [UIView animateWithDuration:0.3f
                                                         animations:^{
                                                             renderItem.icon.alpha = 1;
                                                         }];
                                    
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPNAdRenderingManagerIconNotification object:renderItem.icon];
                                    });
                                }];
        }

        if(renderItem.banner && [PNAdRenderingManager isNotNullOrEmpty:ad.banner_url])
        {
            renderItem.banner.alpha = 0;
            [PNCacheManager dataWithURLString:ad.banner_url
                                andCompletion:^(NSData *data) {
                                    UIImage *bannerImage = [UIImage imageWithData:data];
                                    
                                    dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        [renderItem.banner setImage:bannerImage];
                                    
                                        [UIView animateWithDuration:0.3f
                                                         animations:^{
                                                             renderItem.banner.alpha = 1;
                                                         }];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPNAdRenderingManagerBannerNotification object:renderItem.banner];
                                    });
                                }];
        }
        
        if(renderItem.portrait_banner && [PNAdRenderingManager isNotNullOrEmpty:ad.portrait_banner_url])
        {
            renderItem.portrait_banner.alpha = 0;
            [PNCacheManager dataWithURLString:ad.portrait_banner_url
                                andCompletion:^(NSData *data) {
                                    UIImage *portraitBannerImage = [UIImage imageWithData:data];
                                    
                                    dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        [renderItem.portrait_banner setImage:portraitBannerImage];
                                    
                                        [UIView animateWithDuration:0.3f
                                                         animations:^{
                                                             renderItem.portrait_banner.alpha = 1;
                                                         }];
                                    
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kPNAdRenderingManagerPortraitBannerNotification object:renderItem.portrait_banner];
                                    });
                                }];
        }
        
        if (renderItem.cta_text && [PNAdRenderingManager isNotNullOrEmpty:ad.cta_text])
        {
            renderItem.cta_text.text = ad.cta_text;
        }
        
        if([PNAdRenderingManager isNotNullOrEmpty:ad.app_details])
        {
            if (renderItem.app_name && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.name])
            {
                renderItem.app_name.text = ad.app_details.name;
            }
            if (renderItem.app_review && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.review])
            {
                renderItem.app_review.text = ad.app_details.review;
            }
            if (renderItem.app_publisher && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.publisher])
            {
                renderItem.app_publisher.text = ad.app_details.publisher;
            }
            if (renderItem.app_developer && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.developer])
            {
                renderItem.app_developer.text = ad.app_details.developer;
            }
            if (renderItem.app_version && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.version])
            {
                renderItem.app_version.text = ad.app_details.version;                
            }
            if (renderItem.app_size && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.size])
            {
                renderItem.app_size.text = ad.app_details.size;
            }
            if (renderItem.app_category && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.category])
            {
                renderItem.app_category.text = ad.app_details.category;
            }
            if (renderItem.app_sub_category && [PNAdRenderingManager isNotNullOrEmpty:ad.app_details.sub_category])
            {
                renderItem.app_sub_category.text = ad.app_details.sub_category;
            }
        }
    }
}

+ (BOOL)isNotNullOrEmpty:(id)value
{
    BOOL result = (nil != value && [NSNull null] != value);
    return result;
}

@end
