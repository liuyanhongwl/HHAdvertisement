//
// PNBannerTableViewCell.m
//
// Created by Csongor Nagy on 30/10/14.
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

#import "PNBannerTableViewCell.h"
#include "PNAMRatingControl.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"
#import "PNTrackingManager.h"
#import "PNAdConstants.h"

@interface PNBannerTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView    *iconImage;
@property (nonatomic, weak) IBOutlet UILabel        *titleLabel;
@property (nonatomic, weak) IBOutlet UIView         *ratingContainer;
@property (nonatomic, weak) IBOutlet UILabel        *totalRatings;
@property (nonatomic, weak) IBOutlet UIButton       *downloadButton;

@property (nonatomic, strong) PNAMRatingControl     *ratingControl;
@property (nonatomic, strong) NSTimer               *cellViewTimer;
@property (nonatomic, strong) NSTimer               *impressionTimer;

@end

@implementation PNBannerTableViewCell


#pragma mark NSObject

- (void)dealloc
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    [self.cellViewTimer invalidate];
    self.cellViewTimer = nil;
    
    [self.ratingControl removeFromSuperview];
    self.ratingControl = nil;
}

- (void)awakeFromNib
{
    [self.iconImage.layer setCornerRadius:5];
    [self.iconImage setClipsToBounds:YES];
    [self.downloadButton.layer setCornerRadius:5];
    [self.downloadButton setClipsToBounds:YES];
    
    self.ratingControl = [[PNAMRatingControl alloc]
                          initWithLocation:CGPointZero
                          emptyColor:[UIColor lightGrayColor]
                          solidColor:[UIColor orangeColor]
                          andMaxRating:(NSInteger)5];
    [self.ratingControl setUserInteractionEnabled:NO];
    [self.ratingContainer addSubview:self.ratingControl];
    
    [self addSponsorLabel];
}

#pragma mark UIView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[gestureRecognizer view] isKindOfClass:[UITableViewCell class]])
    {
        return YES;
    }
    return NO;
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
    return 80.0f;
}

#pragma mark PNBannerTableViewCell

- (void)clearCell:(NSNotification*)notification
{
    [self didEndDisplayingCell];
}

- (void)setModel:(PNNativeAdModel*)model
{
    [super setModel:model];
    [self loadAd];
}

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
    renderItem.icon = self.iconImage;
    renderItem.title = self.titleLabel;
    [PNAdRenderingManager renderNativeAdItem:renderItem
                                      withAd:self.model];
    
    [self.downloadButton setTitle:self.model.cta_text forState:UIControlStateNormal];
    
    if ((NSNull*)self.model.app_details.store_rating != [NSNull null])
    {
        [self.ratingControl setRating:[self.model.app_details.store_rating intValue]];
    }
    
    if ((NSNull*)self.model.app_details.total_ratings != [NSNull null])
    {
        self.totalRatings.text = [NSString stringWithFormat:@"(%@)", self.model.app_details.total_ratings];
    }
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

- (IBAction)installButtonPressed:(id)sender
{
    [self openOffer];
}

@end
