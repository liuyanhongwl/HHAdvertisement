//
// PNVideoBannerViewController.m
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

#import "PNVideoBannerViewController.h"

#import "VastXMLParser.h"
#import "PNVideoPlayerView.h"
#import "PNInterstitialAdViewController.h"

#import "PNAdConstants.h"
#import "PNAdRequest.h"
#import "PNNativeVideoAdModel.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"

@interface PNVideoBannerViewController () <VastXMLParserDelegate, PNVideoPlayerViewDelegate, PubnativeAdDelegate>

@property (nonatomic, weak) IBOutlet    UIImageView                     *bannerView;
@property (nonatomic, weak) IBOutlet    UIButton                        *playButton;

@property (nonatomic, strong)           PNNativeVideoAdModel            *model;
@property (nonatomic, strong)           VastContainer                   *vastModel;
@property (nonatomic, strong)           PNVideoPlayerView               *playerContainer;
@property (nonatomic, strong)           PNInterstitialAdViewController  *interstitialVC;
@property (nonatomic, strong)           NSTimer                         *impressionTimer;


- (IBAction)playButtonPressed:(id)sender;
- (IBAction)installButtonPressed:(id)sender;

@end

@implementation PNVideoBannerViewController

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.model = nil;
    self.vastModel = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    if (self.playerContainer)
    {
        [self.playerContainer.view removeFromSuperview];
        [self.playerContainer.videoPlayer stop];
    }
    self.playerContainer = nil;
    
    if(self.interstitialVC)
    {
        [self.interstitialVC.view removeFromSuperview];
    }
    self.interstitialVC = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.model)
    {
        // Initialize the view
        PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
        renderItem.banner = self.bannerView;
        [PNAdRenderingManager renderNativeAdItem:renderItem withAd:self.model];
        [self.bannerView setClipsToBounds:YES];
        
        // Parse model
        PNVastModel *vast = [self.model.vast firstObject];
        if (vast.ad)
        {
            [[VastXMLParser sharedParser] parseString:vast.ad andDelegate:self];
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidLoad:)])
    {
        [self.delegate pnAdDidLoad:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdWillShow)])
    {
        [self.delegate pnAdWillShow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidShow)])
    {
        [self.delegate pnAdDidShow];
    }
    
    [self startImpressionTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdWillClose)])
    {
        [self.delegate pnAdWillClose];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.delegate pnAdDidClose];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - PNVideoBannerViewController

#pragma mark public

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                          model:(PNNativeVideoAdModel*)model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.model = model;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bannerDidLoad:)
                                                     name:kPNAdRenderingManagerBannerNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark private

- (void)bannerDidLoad:(NSNotification*)notification
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdReady:)])
    {
        [self.delegate pnAdReady:self];
    }
}

- (void)didRotate:(NSNotification*)notification
{
    if(self.playerContainer.view.superview != self.view)
    {
        UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if(presentingController.presentedViewController)
        {
            presentingController = presentingController.presentedViewController;
        }
        
        CGRect newFrame = presentingController.view.frame;
        self.playerContainer.view.frame = newFrame;
        self.playerContainer.videoPlayer.layer.frame = newFrame;
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
    if(self.model)
    {
        [PNTrackingManager trackImpressionWithAd:self.model completion:nil];
    }
}


#pragma mark IBActions

- (IBAction)playButtonPressed:(id)sender
{
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(presentingController.presentedViewController)
    {
        presentingController = presentingController.presentedViewController;
    }
    
    CGRect newFrame = presentingController.view.frame;
    self.playerContainer.view.frame = newFrame;
    self.playerContainer.videoPlayer.layer.frame = newFrame;
    [presentingController presentViewController:self.playerContainer animated:NO completion:nil];
    [self.playerContainer.videoPlayer play];
}

- (IBAction)installButtonPressed:(id)sender
{
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

#pragma mark - DELEGATES 

#pragma mark VastXMLParserDelegate

- (void)parserReady:(VastContainer*)ad
{
    self.vastModel = ad;
    [self prepareVideoPlayer];
}

- (void)prepareVideoPlayer
{
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(presentingController.presentedViewController)
    {
        presentingController = presentingController.presentedViewController;
    }
    
    CGRect newFrame = presentingController.view.frame;
    PNVastModel *vast =[self.model.vast firstObject];
    self.playerContainer = [[PNVideoPlayerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             newFrame.size.height,
                                                                             newFrame.size.width)
                                                            model:vast
                                                         delegate:self];
    [self.playerContainer prepareAd:self.vastModel];
}

#pragma mark PNVideoPlayerViewDelegate

- (void)videoClicked:(NSString*)clickThroughUrl
{
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

- (void)videoReady
{
    self.playButton.hidden = NO;
}

- (void)videoCompleted
{
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(presentingController.presentedViewController)
    {
        presentingController = presentingController.presentedViewController;
    }
    CGRect newFrame = presentingController.view.frame;
    
    self.interstitialVC = [[PNInterstitialAdViewController alloc] initWithNibName:NSStringFromClass([PNInterstitialAdViewController class])
                                                                           bundle:[NSBundle bundleForClass:[PNInterstitialAdViewController class]]
                                                                            model:self.model];
    self.interstitialVC.delegate = self.delegate;
    self.interstitialVC.view.frame = newFrame;
    [presentingController presentViewController:self.interstitialVC animated:NO completion:nil];
}

- (void)videoError:(NSInteger)errorCode details:(NSString*)description
{
    NSLog(@"Video error: %@", description);
}

- (void)videoPreparing{}
- (void)videoStartedWithDuration:(NSTimeInterval)duration{}
- (void)videoProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration{}
- (void)videoTrackingEvent:(NSString*)event{}
- (void)videoDismissedFullscreen{}

#pragma mark PNAdViewControllerDelegate

- (void)pnAdWillClose
{
    [self prepareVideoPlayer];
}

@end
