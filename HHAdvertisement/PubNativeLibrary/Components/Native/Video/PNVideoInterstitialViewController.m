//
// PNVideoInterstitialViewController.m
//
// Created by David Martin on 05/02/15.
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

#import "PNVideoInterstitialViewController.h"
#import "PNVideoPlayerView.h"
#import "PNInterstitialAdViewController.h"
#import "PNNativeAdRenderItem.h"
#import "PNTrackingManager.h"
#import "VastXMLParser.h"
#import "PNAdConstants.h"

NSString * const kPNVideoInterstitialViewControllerFrameKey = @"view.frame";

@interface PNVideoInterstitialViewController () <VastXMLParserDelegate, PNVideoPlayerViewDelegate, PubnativeAdDelegate>

@property (nonatomic, strong) PNNativeVideoAdModel              *model;
@property (nonatomic, strong) VastContainer                     *vastModel;
@property (nonatomic, strong) NSTimer                           *impressionTimer;
@property (nonatomic, strong) PNVideoPlayerView                 *playerContainer;
@property (nonatomic, strong) PNInterstitialAdViewController    *interstitialVC;

@end

@implementation PNVideoInterstitialViewController

#pragma mark NSObject

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kPNVideoInterstitialViewControllerFrameKey];
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

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.playerContainer.videoPlayer play];
    
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

#pragma mark PNVideoInterstitialViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                          model:(PNNativeVideoAdModel*)model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.model = model;
        
        [self addObserver:self
               forKeyPath:kPNVideoInterstitialViewControllerFrameKey
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        
        PNVastModel *vast = [self.model.vast firstObject];
        if (vast.ad)
        {
            [[VastXMLParser sharedParser] parseString:vast.ad andDelegate:self];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([kPNVideoInterstitialViewControllerFrameKey isEqualToString:keyPath])
    {
        if([object valueForKeyPath:keyPath] != [NSNull null])
        {
            CGRect frame = [[object valueForKeyPath:keyPath] CGRectValue];
            self.playerContainer.view.frame = frame;
            self.playerContainer.videoPlayer.layer.frame = frame;
        }
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

- (void)openOffer
{
    if(self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

- (void)prepareVideoPlayer
{
    PNVastModel *vast = [self.model.vast firstObject];
    CGRect newFrame = [UIScreen mainScreen].bounds;
    self.playerContainer = [[PNVideoPlayerView alloc] initWithFrame:newFrame
                                                              model:vast
                                                           delegate:self];
    self.playerContainer.videoPlayer.layer.frame = newFrame;
    [self.view addSubview:self.playerContainer.view];
    [self.playerContainer prepareAd:self.vastModel];
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

- (void)close
{
    if(self.interstitialVC)
    {
        [self.interstitialVC.view removeFromSuperview];
    }
    
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

#pragma mark - DELEGATES -

#pragma mark VastXMLParserDelegate

- (void)parserReady:(VastContainer*)ad
{
    self.vastModel = ad;
    [self prepareVideoPlayer];
}

- (void)parserError:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidFail:)])
    {
        [self.delegate pnAdDidFail:error];
    }
}

#pragma mark PNVideoPlayerViewDelegate

- (void)videoClicked:(NSString*)clickThroughUrl
{
    [self close];
    [self openOffer];
}

- (void)videoReady
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdDidLoad:)])
    {
        [self.delegate pnAdDidLoad:self];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pnAdReady:)])
    {
        [self.delegate pnAdReady:self];
    }
}

- (void)videoCompleted
{
    self.interstitialVC = [[PNInterstitialAdViewController alloc] initWithNibName:NSStringFromClass([PNInterstitialAdViewController class])
                                                                           bundle:[NSBundle bundleForClass:[PNInterstitialAdViewController class]]
                                                                            model:self.model];
    self.interstitialVC.delegate = self;
    UIView* interstitialView = self.interstitialVC.view;
    #pragma unused(interstitialView)
}

- (void)videoDismissedFullscreen{}
- (void)videoPreparing {}
- (void)videoStartedWithDuration:(NSTimeInterval)duration {}
- (void)videoError:(NSInteger)errorCode details:(NSString*)description
{
    NSLog(@"Video error: %@", description);
}

- (void)videoProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {}
- (void)videoTrackingEvent:(NSString*)event {}

#pragma mark PubnativeAdDelegate

- (void)pnAdDidLoad:(UIViewController*)ad
{
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(presentingController.presentedViewController)
    {
        presentingController = presentingController.presentedViewController;
    }
    CGRect newFrame = presentingController.view.frame;
    self.interstitialVC.view.frame = newFrame;

    [self.view addSubview:self.interstitialVC.view];
}

- (void)pnAdReady:(UIViewController*)ad{}
- (void)pnAdDidFail:(NSError*)error{}

- (void)pnAdWillShow{}
- (void)pnAdDidShow{}

- (void)pnAdWillClose
{
    [self close];
}

- (void)pnAdDidClose{}

@end
