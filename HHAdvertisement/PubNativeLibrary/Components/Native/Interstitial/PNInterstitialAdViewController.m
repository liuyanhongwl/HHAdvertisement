//
// PNInterstitialAdViewController.m
//
// Created by Csongor Nagy on 10/10/14.
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

#import "PNInterstitialAdViewController.h"
#import "PNAMRatingControl.h"
#import "PNAdRequest.h"
#import "PNNativeAdModel.h"
#import "PNTrackingManager.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"
#import "PNAdConstants.h"

CGFloat     const kPNInterstitialAdVCBannerPadding          = 5.0f;

NSInteger   const kPNInterstitialAdVCPortraitImageWidth     = 627;
NSInteger   const kPNInterstitialAdVCPortraitImageHeight    = 1200;

@interface PNInterstitialAdViewController()

@property (nonatomic, weak)     IBOutlet    UIImageView         *bannerImage;
@property (nonatomic, weak)     IBOutlet    UIView              *bannerDataView;
@property (nonatomic, weak)     IBOutlet    UIView              *ratingDataView;
@property (nonatomic, weak)     IBOutlet    UIView              *ratingContainer;
@property (nonatomic, weak)     IBOutlet    UILabel             *totalRatings;
@property (nonatomic, weak)     IBOutlet    UITextView          *descriptionLabel;
@property (nonatomic, weak)     IBOutlet    UIButton            *downloadButton;
@property (nonatomic, weak)     IBOutlet    UIImageView         *iconImage;
@property (nonatomic, weak)     IBOutlet    UILabel             *titleLabel;
@property (nonatomic, weak)     IBOutlet    UILabel             *versionLabel;
@property (nonatomic, weak)     IBOutlet    UIImageView         *pubnativeLogoImageView;
@property (weak, nonatomic)     IBOutlet    UIButton            *closeButton;

@property (nonatomic, strong)               PNAMRatingControl   *ratingControl;
@property (nonatomic, strong)               PNNativeAdModel     *model;
@property (nonatomic, strong)               NSTimer             *impressionTimer;
@property (nonatomic, assign)               BOOL                wasStatusBarHidden;
@property (nonatomic, assign)               BOOL                isLoaded;

@end

@implementation PNInterstitialAdViewController

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
        [self.pubnativeLogoImageView setImage:[UIImage imageNamed:@"PNLogoGrey"
                                                         inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        
        [self.closeButton setImage:[UIImage imageNamed:@"PNCloseIcon"
                                             inBundle:[NSBundle bundleForClass:[self class]]
                        compatibleWithTraitCollection:nil]
                          forState:UIControlStateNormal];
        
        // Rating stars
        self.ratingControl = [[PNAMRatingControl alloc] initWithLocation:CGPointZero
                                                              emptyColor:[UIColor lightGrayColor]
                                                              solidColor:[PNAdConstants pubnativeColor]
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
        
        // Total ratings
        if ((NSNull*)self.model.app_details.total_ratings != [NSNull null])
        {
            self.totalRatings.text = [NSString stringWithFormat:@"(%@)", self.model.app_details.total_ratings];
        }
        
        [self.descriptionLabel setContentOffset:CGPointMake(0.0f, 20.0f)];
        
        self.downloadButton.layer.cornerRadius = 8;
        self.downloadButton.clipsToBounds = YES;
        [self.downloadButton setTitle:self.model.cta_text forState:UIControlStateNormal];
        
        self.versionLabel.text = [PNAdConstants version];
        
        self.iconImage.layer.cornerRadius = 8;
        self.iconImage.clipsToBounds = YES;
        
        PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
        renderItem.icon = self.iconImage;
        renderItem.banner = self.bannerImage;
        renderItem.title = self.titleLabel;
        renderItem.descriptionField = self.descriptionLabel;
        [PNAdRenderingManager renderNativeAdItem:renderItem withAd:self.model];
        
        [UIView animateWithDuration:0.5
                         animations:^
         {
             self.bannerDataView.alpha = 1.0f;
         }];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidLoad:)])
    {
        [self.delegate pnAdDidLoad:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didRotate:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdWillShow)])
    {
        [self.delegate pnAdWillShow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidShow)])
    {
        [self.delegate pnAdDidShow];
    }
    
    [self startImpressionTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.wasStatusBarHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdWillClose)])
    {
        [self.delegate pnAdWillClose];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.delegate pnAdDidClose];
    }
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark PNInterstitialAdViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                          model:(PNNativeAdModel*)model
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.isLoaded = NO;
        self.model = model;
        self.wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(closePressed:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRotate:)
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(iconDidLoad:)
                                                     name:kPNAdRenderingManagerIconNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bannerDidLoad:)
                                                     name:kPNAdRenderingManagerBannerNotification
                                                   object:nil];
    }
    return self;
}

- (void)didRotate:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.descriptionLabel.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(orientation);
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
    if(self.model)
    {
        [PNTrackingManager trackImpressionWithAd:self.model completion:nil];
    }
}

- (BOOL)isModal
{
    if([self presentingViewController])
        return YES;
    if([[self presentingViewController] presentedViewController] == self)
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

- (void)checkLoaded
{
    if(!self.isLoaded)
    {
        self.isLoaded = YES;
    }
    else
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdReady:)])
        {
            [self.delegate pnAdReady:self];
        }
    }
}

- (IBAction)closePressed:(id)sender
{
    [self close];
}

- (void)close
{
    if([self isModal])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

- (IBAction)installClicked:(id)sender
{
    if (self.model && self.model.click_url)
    {
        [self close];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

#pragma mark - NOTIFICATIONS -

#pragma mark PNAdRenderingManager

- (void)iconDidLoad:(NSNotification*)notification
{
    [self checkLoaded];
}

- (void)bannerDidLoad:(NSNotification*)notification
{
    [self checkLoaded];
}

@end
