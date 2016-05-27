//
//  PNNativeAdModel.m
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

#import "PNNativeAdModel.h"

@implementation PNNativeAdModel

@synthesize title;
@synthesize Description;
@synthesize cta_text;
@synthesize icon_url;
@synthesize banner_url;
@synthesize portrait_banner_url;
@synthesize points;
@synthesize video_url;
@synthesize app_details;

#pragma mark NSObject

- (void)dealloc
{
    self.title = nil;
    self.Description = nil;
    self.cta_text = nil;
    self.icon_url = nil;
    self.banner_url = nil;
    self.portrait_banner_url = nil;
    self.points = nil;
    self.video_url = nil;
    self.app_details = nil;
}

#pragma mark PNNativeAdModel

@end