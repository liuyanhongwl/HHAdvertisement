//
//  PNAdRequestParameters.m
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


#import "PNAdRequestParameters.h"
#import <objc/runtime.h>
#import "NSString+PNMD5.h"
#import "NSString+PNSHA1.h"

NSString *  const kPNAdRequestParametersIpadDeviceName      = @"tablet";
NSString *  const kPNAdRequestParametersIphoneDeviceName    = @"phone";
NSInteger   const kPNAdRequestParametersDefaultAdCount      = 1;
NSString *  const kPNAdRequestParametersDefaultNoUserID     = @"1";

@interface PNAdRequestParameters ()

@end

@implementation PNAdRequestParameters

#pragma mark NSObject

- (void)dealloc
{
    self.app_token = nil;
    self.bundle_id = nil;
    self.zone_id = nil;
    self.ad_count = nil;
    self.user_agent = nil;
    self.os = nil;
    self.os_version = nil;
    self.device_model = nil;
    self.ip = nil;
    self.locale = nil;
    self.icon_size = nil;
    self.banner_size = nil;
    self.portrait_banner_size = nil;
    self.device_resolution = nil;
    self.device_type = nil;
    self.latitude = nil;
    self.longitude = nil;
    self.gender = nil;
    self.age = nil;
    self.keywords = nil;
    self.partner = nil;
    self.apple_idfa = nil;
    self.apple_idfa_sha1 = nil;
    self.apple_idfa_md5 = nil;
    self.android_imei = nil;
    self.android_imei_sha1 = nil;
    self.android_imei_md5 = nil;
    self.mac_address = nil;
    self.mac_address_sha1 = nil;
    self.mac_address_md5 = nil;
    self.no_user_id = nil;
    self.server_integration = nil;
}

#pragma mark PNAdRequestParameters

+ (instancetype)requestParameters
{
    PNAdRequestParameters *result = [[PNAdRequestParameters alloc] init];
    return result;
}

- (void)fillWithDefaults
{
    if(!self.ad_count)
    {
        self.ad_count = @(kPNAdRequestParametersDefaultAdCount);
    }
    
    if(!self.os)
    {
        self.os = [[UIDevice currentDevice] systemName];
    }
    
    if(!self.os_version)
    {
        self.os_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if(!self.device_model)
    {
        self.device_model = [[UIDevice currentDevice] model];
    }
    
    if(!self.device_type)
    {
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            self.device_type = kPNAdRequestParametersIpadDeviceName;
        }
        else if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM())
        {
            self.device_type = kPNAdRequestParametersIphoneDeviceName;
        }
    }

    if(!self.device_resolution)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
        self.device_resolution = [NSString stringWithFormat:@"%ix%i",
                                  [@(screenSize.width) intValue],
                                  [@(screenSize.height) intValue]];
    }
    
    if(!self.bundle_id)
    {
        self.bundle_id = [[NSBundle mainBundle] bundleIdentifier];
    }
    
    if(!self.locale)
    {
        NSLocale *currentLocale = [NSLocale currentLocale];
        self.locale = [currentLocale objectForKey:NSLocaleLanguageCode];
    }
    
    if(!self.apple_idfa)
    {
        if(NSClassFromString(@"ASIdentifierManager"))
        {
            if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled])
            {
                NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                if(idfa)
                {
                    self.apple_idfa = idfa;
                    self.apple_idfa_md5 = [self.apple_idfa md5String];
                    self.apple_idfa_sha1 = [self.apple_idfa sha1String];
                }
            }
        }
    }
    
    if (!self.apple_idfa)
    {
        self.no_user_id = kPNAdRequestParametersDefaultNoUserID;
    }
}

@end
