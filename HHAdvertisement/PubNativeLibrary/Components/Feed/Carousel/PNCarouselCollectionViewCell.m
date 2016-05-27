//
// PNCarouselCollectionViewCell.m
//
// Created by David Martin on 24/10/14.
// Copyright (c) 2014 PubNative.
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
//

#import "PNCarouselCollectionViewCell.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"
#import "PNTrackingManager.h"
#include "PNAMRatingControl.h"

CGFloat const kPNCarouselCollectionViewCellVisibilityTimer  = 0.1f;
CGFloat const kPNCarouselCollectionViewCellTimeToConfirm    = 1.0f;

@interface PNCarouselCollectionViewCell ()

@property (weak, nonatomic) IBOutlet    UILabel         *titleLabel;
@property (weak, nonatomic) IBOutlet    UITextView      *descriptionTextView;
@property (weak, nonatomic) IBOutlet    UIImageView     *iconImageView;
@property (weak, nonatomic) IBOutlet    UIImageView     *bannerImageView;
@property (weak, nonatomic) IBOutlet    UIButton        *downloadButton;
@property (weak, nonatomic) IBOutlet    UIView          *starsView;
@property (weak, nonatomic) IBOutlet    UIView          *dataView;

@property (strong, nonatomic)           PNNativeAdModel *model;
@property (strong, nonatomic)           NSTimer         *displayTimer;

@property (assign, nonatomic)           NSTimeInterval  initTimeStamp;
@property (assign, nonatomic)           NSTimeInterval  elapsedTime;
@property (assign, nonatomic)           BOOL            adConfirmed;

@end

@implementation PNCarouselCollectionViewCell

#pragma mark NSObject

- (void)dealloc
{
    [self invalidateDisplayTimer];
    
    self.model = nil;
}

- (void)awakeFromNib
{
    CGFloat cornerRadius = 5;
    self.elapsedTime = 0;
    
    [self.iconImageView.layer setCornerRadius:cornerRadius];
    [self.iconImageView setClipsToBounds:YES];
    
    [self.downloadButton.layer setCornerRadius:cornerRadius];
    [self.downloadButton setClipsToBounds:YES];
    
    [self.dataView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.dataView.layer setBorderWidth:2.0f];
}

#pragma mark PNCarouselCollectionViewCell

- (void)setData:(PNNativeAdModel*)data
{
    _model = data;
    self.adConfirmed = false;
    [self load];
    [self initConfirmTimer];
}

- (void)initConfirmTimer
{
    self.initTimeStamp = [[NSDate date] timeIntervalSince1970];
    self.displayTimer = [NSTimer scheduledTimerWithTimeInterval:kPNCarouselCollectionViewCellVisibilityTimer
                                                         target:self
                                                       selector:@selector(checkAdVisibility)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)load
{
    PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
    renderItem.title                = self.titleLabel;
    renderItem.descriptionField     = self.descriptionTextView;
    renderItem.icon                 = self.iconImageView;
    renderItem.banner               = self.bannerImageView;
    [PNAdRenderingManager renderNativeAdItem:renderItem
                                      withAd:self.model];
    
    [self.descriptionTextView sizeToFit];
    [self.downloadButton setTitle:self.model.cta_text forState:UIControlStateNormal];
    
    PNAMRatingControl *ratingControl = [[PNAMRatingControl alloc] initWithLocation:CGPointZero
                                                                    emptyColor:[UIColor lightGrayColor]
                                                                    solidColor:[UIColor orangeColor]
                                                                  andMaxRating:(NSInteger)5];
    
    if ((NSNull*)self.model.app_details.store_rating != [NSNull null])
    {
        [ratingControl setRating:[self.model.app_details.store_rating intValue]];
    }
    ratingControl.enabled = NO;
    ratingControl.center = self.starsView.center;
    [self.dataView addSubview:ratingControl];
}

- (void)invalidateDisplayTimer
{
    [self.displayTimer invalidate];
    self.displayTimer = nil;
}

- (void)didEndDisplayingCell
{
    [self checkAdVisibility];
    [self invalidateDisplayTimer];
}

- (void)checkAdVisibility
{
    if([self.displayTimer isValid])
    {
        self.elapsedTime += ([[NSDate date] timeIntervalSince1970] - self.initTimeStamp);
        self.initTimeStamp = [[NSDate date] timeIntervalSince1970];
        
        if(kPNCarouselCollectionViewCellTimeToConfirm <= self.elapsedTime && !self.adConfirmed)
        {
            [self invalidateDisplayTimer];
            self.adConfirmed = YES;
            [PNTrackingManager trackImpressionWithAd:self.model
                                          completion:nil];
        }
    }
}

@end
