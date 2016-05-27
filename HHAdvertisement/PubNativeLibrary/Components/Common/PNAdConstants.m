//
// PNAdConstants.m
//
// Created by Csongor Nagy on 19/06/14.
// Copyright (c) 2014 PubNative
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PNAdConstants.h"\

NSInteger  const kPNPadding                                         = 5;
NSInteger  const kPNPortraitBannerWidth                             = 627;
NSInteger  const kPNPortraitBannerHeigth                            = 1200;
NSInteger  const kPNLandscapeBannerWidth                            = 960;
NSInteger  const kPNLandscapeBannerHeigth                           = 640;

NSString * const kPNAdConstantAPIModelStatusSuccess                 = @"ok";
NSInteger  const kPNAdConstantShowTimeForImpression                 = 1;

// Request
NSInteger  const kPNAdConstantRequestDefaultTimeout                 = 30;
NSString * const kPNAdConstantRequestAPINativeUrlString             = @"https://api.pubnative.net/api/partner/v2/promotions/native";
NSString * const kPNAdConstantRequestAPINativeVideoUrlString        = @"https://api.pubnative.net/api/partner/v2/promotions/native/video";
NSString * const kPNAdConstantMethodGET                             = @"GET";

// Request parameters
NSString * const kPNAdConstantRequestParametersIpadDeviceName       = @"tablet";
NSString * const kPNAdConstantRequestParametersIphoneDeviceName     = @"phone";
NSInteger  const kPNAdConstantRequestParametersDefaultAdCount       = 1;
NSString * const kPNAdConstantRequestParametersDefaultNoUserID      = @"1";

// Tracking
NSString * const kPNAdConstantTrackingConfirmedAdsKey               = @"com.pubnative.ImpressionManager:confirmedAds";
NSString * const kPNAdConstantTrackingBeaconImpressionTypeString    = @"impression";

// Strings
NSString * const kPNAdConstantSponsoredContentString                = @"Sponsored by Pubnative";

@implementation PNAdConstants

+ (NSString*)version
{
    NSString *version = @"";
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"PNVersion" ofType:@"plist"];
    if (path)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        version = [NSString stringWithFormat:@"v.%@", [dict objectForKey:@"version"]];
    }

    return version;
}

+ (UIColor*)pubnativeColor
{
    return [UIColor colorWithRed:(122.0f/255.0f) green:(33.0f/255.0f) blue:(127.0f/255.0f) alpha:1.0f];
}

@end
