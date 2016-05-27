//
// PNVideoTableViewCell.m
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

#import "PNVideoTableViewCell.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"
#import "PNVastModel.h"
#import "PNVideoPlayerView.h"
#import "VastXMLParser.h"

NSString * const kPNTableViewCellContentViewFrameKey = @"contentView.frame";
FOUNDATION_IMPORT NSString * const kPNTableViewManagerClearAllNotification;

@interface PNVideoTableViewCell () <VastXMLParserDelegate, PNVideoPlayerViewDelegate>

@property (nonatomic, strong) UIImageView       *banner;
@property (nonatomic, strong) PNVideoPlayerView *playerContainer;
@property (nonatomic, strong) VastContainer     *vastModel;
@property (nonatomic, strong) NSTimer           *impressionTimer;
@end

@implementation PNVideoTableViewCell

#pragma mark NSObject

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kPNTableViewCellContentViewFrameKey];
    
    self.vastModel = nil;
    
    [self.banner removeFromSuperview];
    self.banner = nil;
    
    if(self.playerContainer)
    {
        [self.playerContainer.videoPlayer stop];
        [self.playerContainer.view removeFromSuperview];
    }
    self.playerContainer = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([kPNTableViewCellContentViewFrameKey isEqualToString:keyPath])
    {
        if([object valueForKeyPath:keyPath] != [NSNull null])
        {
            CGRect frame = [[object valueForKeyPath:keyPath] CGRectValue];
            if(self.playerContainer.view.superview == self.contentView)
            {
                self.playerContainer.view.frame = frame;
                self.playerContainer.videoPlayer.layer.frame = frame;
            }
        }
    }
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

#pragma mark UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.banner = [[UIImageView alloc] initWithFrame:self.frame];
        self.banner.contentMode = UIViewContentModeScaleAspectFit;
        self.banner.hidden = YES;
        self.backgroundView = self.banner;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(openOffer)];
        tapRecognizer.delegate = self;
        [self addGestureRecognizer:tapRecognizer];
        
        self.playerContainer = [[PNVideoPlayerView alloc] initWithFrame:self.frame
                                                                  model:nil
                                                               delegate:self];
        
        [self.contentView addSubview:self.playerContainer.view];
        
        [self addObserver:self
               forKeyPath:kPNTableViewCellContentViewFrameKey
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearCell:)
                                                     name:kPNTableViewManagerClearAllNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark PNTableViewCell

- (void)willDisplayCell
{
    self.banner.hidden = YES;
    self.playerContainer.view.hidden = YES;
    [self.playerContainer displayFullscreenButton];
    
    [self.impressionTimer invalidate];
    self.impressionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(impressionTimerTick:) userInfo:nil repeats:NO];
    
    [self loadAd];
}

- (void)didEndDisplayingCell
{
    if(self.playerContainer)
    {
        self.playerContainer.view.hidden = YES;
        [self.playerContainer.videoPlayer stop];
        
        if(self.playerContainer.view.superview != self.contentView)
        {
            [self.playerContainer.view removeFromSuperview];
            self.playerContainer.view.frame = self.contentView.frame;
            self.playerContainer.videoPlayer.layer.frame = self.contentView.frame;
            [self.contentView addSubview:self.playerContainer.view];
        }
    }
    
    if(self.banner)
    {
        [self.banner setImage:nil];
        self.banner.hidden = YES;
    }
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

+ (CGFloat)cellMinHeight
{
    return 150.0f;
}

#pragma mark PNVideoAdModelTableViewCell

- (void)setModel:(PNNativeVideoAdModel*)model
{
    [super setModel:model];
    [self loadAd];
}

#pragma mark PNVideoTableViewCell

- (void)didRotate:(NSNotification*)notification
{
    if(self.playerContainer.view.superview != self.contentView)
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

- (void)clearCell:(NSNotification*)notification
{
    [self didEndDisplayingCell];
}

- (void)loadAd
{
    self.banner.hidden = NO;
    
    PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
    renderItem.banner = self.banner;
    [PNAdRenderingManager renderNativeAdItem:renderItem
                                      withAd:self.model];
    
    PNVastModel *vast = [self.model.vast firstObject];
    if(self.model)
    {
        [self.playerContainer.skipButton setTitle:vast.skip_video_button forState:UIControlStateNormal];
    }
        
    if (vast.ad)
    {
        [[VastXMLParser sharedParser] parseString:vast.ad andDelegate:self];
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

#pragma mark - DELEGATES -

#pragma mark VastXMLParserDelegate

- (void)parserReady:(VastContainer*)ad
{
    self.vastModel = ad;
    [self.playerContainer prepareAd:self.vastModel];
}

#pragma mark PNVideoPlayerViewDelegate

- (void)videoClicked:(NSString*)clickThroughUrl
{
    [self openOffer];
}

- (void)videoReady
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playerContainer.view.hidden = NO;
        [self.playerContainer.videoPlayer play];
    });
}

- (void)videoCompleted
{
    self.playerContainer.view.hidden = YES;
}

- (void)videoDismissedFullscreen
{
    self.playerContainer.view.frame = self.contentView.frame;
    self.playerContainer.videoPlayer.layer.frame = self.contentView.frame;
    [self.playerContainer displayFullscreenButton];
    [self.contentView addSubview:self.playerContainer.view];
}

- (void)videoError:(NSInteger)errorCode details:(NSString*)description
{
    NSLog(@"Video error: %@", description);
}

- (void)videoPreparing {}
- (void)videoStartedWithDuration:(NSTimeInterval)duration {}
- (void)videoProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {}
- (void)videoTrackingEvent:(NSString*)event {}

@end
