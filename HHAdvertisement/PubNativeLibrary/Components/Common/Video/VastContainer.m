//
// VastContainer.m
//
// Created by Csongor Nagy on 12/08/14.
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

#import "VastContainer.h"

@implementation VastContainer

#pragma mark - NSObject

- (void)dealloc
{
    self.adId = nil;
    self.adSystem = nil;
    self.adTitle = nil;
    self.adDescription = nil;
    self.impressionID = nil;
    self.duration = nil;
    self.trackingCreativeView = nil;
    self.trackingStart = nil;
    self.trackingFirstQuartile = nil;
    self.trackingMidpoint = nil;
    self.trackingThirdQuartile = nil;
    self.trackingComplete = nil;
    self.trackingMute = nil;
    self.trackingUnmute = nil;
    self.trackingPause = nil;
    self.trackingFullscreen = nil;
    self.clickThrough = nil;
    self.mediaFile = nil;
    self.mediaHeight = nil;
    self.mediaWidth = nil;
    self.mediaType = nil;
    self.mediaDelivery = nil;
    self.mediaScalable = nil;
}

@end
