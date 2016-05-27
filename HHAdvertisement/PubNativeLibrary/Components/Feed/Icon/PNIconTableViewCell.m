//
// PNIconTableViewCell.h
//
// Created by David Martin on 25/03/15.
// Copyright (c) 2015 PubNative. All rights reserved.
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

#import "PNIconTableViewCell.h"
#import "PNTrackingManager.h"
#import "PNAdRenderingManager.h"
#import "PNAdConstants.h"

@interface PNIconTableViewCell ()

@property (strong, nonatomic) NSTimer       *impressionTimer;
@property (strong, nonatomic) UIImageView   *iconImageView;

@end

@implementation PNIconTableViewCell

#pragma mark NSObject

- (void)dealloc
{
    [self.iconImageView removeFromSuperview];
    self.iconImageView = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

#pragma mark UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.iconImageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.iconImageView];
        
        [self addSponsorLabel];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTap:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

#pragma mark PNTableViewCell

- (void)willDisplayCell
{
    [self.impressionTimer invalidate];
    self.impressionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(impressionTimerTick:) userInfo:nil repeats:NO];
    
    [self loadAd];
}

- (void)didEndDisplayingCell
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

+ (CGFloat)cellMinHeight
{
    return 50.0f;
}

#pragma mark PNIconTableViewCell

- (void)addSponsorLabel
{
    UILabel *sponsorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 15)];
    sponsorLabel.font = [UIFont systemFontOfSize:9.0f];
    sponsorLabel.text = kPNAdConstantSponsoredContentString;
    sponsorLabel.textAlignment = NSTextAlignmentCenter;
    sponsorLabel.backgroundColor = [UIColor purpleColor];
    sponsorLabel.textColor = [UIColor whiteColor];
    sponsorLabel.alpha = 0.75f;
    [self addSubview:sponsorLabel];
}

- (void)loadAd
{
    PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
    renderItem.icon = self.iconImageView;
    [PNAdRenderingManager renderNativeAdItem:renderItem
                                      withAd:self.model];
}

- (void)iconTap:(UITapGestureRecognizer*)recognizer
{
    [self openOffer];
}

- (void)openOffer
{
    if(self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

- (void)impressionTimerTick:(NSTimer *)timer
{
    if([timer isValid])
    {
        [PNTrackingManager trackImpressionWithAd:self.model
                                      completion:nil];
    }
}

@end
