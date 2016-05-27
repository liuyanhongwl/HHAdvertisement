//
// PNGameListTableViewCell.m
//
// Created by David Martin on 16/03/15.
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

#import "PNGameListTableViewCell.h"
#import "PNAdRenderingManager.h"
#import "PNAMRatingControl.h"
#import "PNAdConstants.h"
#import "PNTrackingManager.h"

@interface PNGameListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView    *icon;
@property (weak, nonatomic) IBOutlet UILabel        *title;
@property (weak, nonatomic) IBOutlet UILabel        *cta_text;
@property (weak, nonatomic) IBOutlet UIView         *ratingContainer;
@property (weak, nonatomic) IBOutlet UILabel        *totalRatings;
@property (weak, nonatomic) IBOutlet UIView         *darkBG;

@property (weak, nonatomic)     PNNativeAdModel     *model;
@property (strong, nonatomic)   PNAMRatingControl   *ratingControl;
@property (strong, nonatomic)   NSTimer             *impressionTimer;

@end

@implementation PNGameListTableViewCell

#pragma mark NSObject

- (void)dealloc
{
    [self.ratingControl removeFromSuperview];
    self.ratingControl = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

#pragma mark UITableViewCell

- (void)awakeFromNib
{
    self.cta_text.layer.cornerRadius = 5;
    
    // Rating stars
    self.ratingControl = [[PNAMRatingControl alloc] initWithLocation:CGPointZero
                                                        emptyColor:[UIColor lightGrayColor]
                                                        solidColor:[PNAdConstants pubnativeColor]
                                                      andMaxRating:(NSInteger)5];
    self.ratingControl.rating = 0;
    [self.ratingControl setUserInteractionEnabled:NO];
    [self.ratingContainer addSubview:self.ratingControl];
}

#pragma mark PNGameListTableViewCell

- (void)didDisplay
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

- (void)willDisplay
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    self.impressionTimer = [NSTimer scheduledTimerWithTimeInterval:kPNAdConstantShowTimeForImpression
                                                            target:self
                                                          selector:@selector(impressionTimerTick:)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)impressionTimerTick:(NSTimer *)timer
{
    if(self.model)
    {
        [PNTrackingManager trackImpressionWithAd:self.model completion:nil];
    }
}

- (void)setModel:(PNNativeAdModel*)model
{
    _model = model;
    
    if(self.model)
    {
        NSInteger rating = 0;
        if([NSNull null] != ((NSNull*)self.model.app_details) &&
           self.model.app_details.store_rating &&
           [NSNull null] != ((NSNull*)self.model.app_details.store_rating))
        {
            rating =  (int) [self.model.app_details.store_rating doubleValue];
        }
        
        NSString *totalRatings = @"";
        if ((NSNull*)self.model.app_details.total_ratings != [NSNull null])
        {
            totalRatings = [NSString stringWithFormat:@"(%@)", self.model.app_details.total_ratings];
        }
        self.totalRatings.text = totalRatings;
        self.ratingControl.rating = rating;
        
        PNNativeAdRenderItem *item = [PNNativeAdRenderItem renderItem];
        item.title = self.title;
        item.icon = self.icon;
        item.cta_text = self.cta_text;
        
        [PNAdRenderingManager renderNativeAdItem:item withAd:self.model];
    }
}

- (void)setDark:(BOOL)set
{
    self.darkBG.hidden = !set;
}

- (IBAction)touchUpInside:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnGameListCellSelected)])
    {
        [self.delegate pnGameListCellSelected];
    }
    
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

@end
