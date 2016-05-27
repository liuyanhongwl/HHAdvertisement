//
// PNBannerViewController.m
//
// Created by Csongor Nagy on 12/11/14.
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

#import "PNBannerViewController.h"

#import "PNAdRequest.h"
#import "PNNativeAdModel.h"
#import "PNAdRenderingManager.h"
#import "PNTrackingManager.h"
#import "PNAMRatingControl.h"
#import "PNAdConstants.h"

@interface PNBannerViewController ()

@property (nonatomic, weak) IBOutlet UIImageView    *iconView;
@property (nonatomic, weak) IBOutlet UIView         *dataContainer;
@property (nonatomic, weak) IBOutlet UILabel        *titleLabel;
@property (nonatomic, weak) IBOutlet UIView         *ratingContainer;
@property (nonatomic, weak) IBOutlet UILabel        *ctaLabel;

@property (nonatomic, strong) PNAdRequest           *request;
@property (nonatomic, strong) PNNativeAdModel       *model;
@property (nonatomic, strong) PNAMRatingControl     *ratingControl;
@property (nonatomic, strong) NSTimer               *impressionTimer;

- (IBAction)installButtonPressed:(id)sender;

@end

@implementation PNBannerViewController

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.request = nil;
    self.model = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    [self.ratingControl removeFromSuperview];
    self.ratingControl = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.model)
    {
        self.ratingControl = [[PNAMRatingControl alloc] initWithLocation:CGPointZero
                                                            emptyColor:[UIColor lightGrayColor]
                                                            solidColor:[UIColor orangeColor]
                                                          andMaxRating:(NSInteger)5];
        NSInteger rating = 0;
        if([NSNull null] != ((NSNull*)self.model.app_details) &&
           self.model.app_details.store_rating &&
           [NSNull null] != ((NSNull*)self.model.app_details.store_rating))
        {
            rating =  (int) [self.model.app_details.store_rating doubleValue];
        }
        self.ratingControl.rating = rating;
        [self.ratingControl setUserInteractionEnabled:NO];
        [self.ratingContainer addSubview:self.ratingControl];
        
        self.iconView.layer.cornerRadius = 5.0f;
        [self.iconView setClipsToBounds:YES];
        
        self.dataContainer.layer.borderColor = [UIColor orangeColor].CGColor;
        self.dataContainer.layer.borderWidth = 1.0f;
        self.dataContainer.layer.cornerRadius = 5.0f;
    
        PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
        renderItem.title = self.titleLabel;
        renderItem.icon = self.iconView;
        renderItem.cta_text = self.ctaLabel;
        [PNAdRenderingManager renderNativeAdItem:renderItem withAd:self.model];
    }
    
    if([self.delegate respondsToSelector:@selector(pnAdDidLoad:)])
    {
        [self.delegate pnAdDidLoad:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdWillShow)])
    {
        [self.delegate pnAdWillShow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidShow)])
    {
        [self.delegate pnAdDidShow];
    }
    
    [self startImpressionTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdWillClose)])
    {
        [self.delegate pnAdWillClose];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.delegate pnAdDidClose];
    }
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

#pragma mark - PNBannerViewController

#pragma mark public

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                          model:(PNNativeAdModel*)model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.model = model;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(iconDidLoad:)
                                                     name:kPNAdRenderingManagerIconNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark private

- (void)iconDidLoad:(NSNotification*)notification
{
    if([self.delegate respondsToSelector:@selector(pnAdReady:)])
    {
        [self.delegate pnAdReady:self];
    }
}

- (void)startImpressionTimer
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
    if(self.model && timer.valid)
    {
        [PNTrackingManager trackImpressionWithAd:self.model completion:nil];
    }
}

#pragma mark IBActions

- (IBAction)installButtonPressed:(id)sender
{
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

@end
