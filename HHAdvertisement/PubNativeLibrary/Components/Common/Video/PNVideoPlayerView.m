//
// PNVideoPlayerView.m
//
// Created by Csongor Nagy on 06/03/14.
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

#import "PNVideoPlayerView.h"

@interface PNVideoPlayerView () <PNVideoCacherDelegate>

@property (nonatomic, weak)   NSObject<PNVideoPlayerViewDelegate>   *delegate;

@property (nonatomic, assign) BOOL                                  autoStart;
@property (nonatomic, assign) CGRect                                frame;

@property (nonatomic, strong) NSMutableArray                        *trackingEvents;
@property (nonatomic, strong) PNVideoCacher                         *cacher;

@end

@implementation PNVideoPlayerView

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.model = nil;
    self.vastAd = nil;
    
    [self.videoPlayer stop];
    self.videoPlayer = nil;
    
    [self.loadLabel removeFromSuperview];
    self.loadLabel = nil;
    
    
    [self.cacher cancelCaching];
    self.cacher = nil;
    
    [self.trackingEvents removeAllObjects];
    self.trackingEvents = nil;
}

#pragma mark UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = self.frame;
    
    self.loadLabel = [[PNKAProgressLabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.loadLabel setBorderWidth: 6.0];
    [self.loadLabel setColorTable: @{
                                     PNStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor clearColor],
                                     PNStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor whiteColor],
                                     PNStringFromProgressLabelColorTableKey(ProgressLabelFillColor):[UIColor clearColor]
                                     }];
    [self.loadLabel setTextColor:[UIColor whiteColor]];
    [self.loadLabel setShadowColor:[UIColor darkGrayColor]];
    self.loadLabel.shadowOffset = CGSizeMake(1, 1);
    [self.loadLabel setTextAlignment:NSTextAlignmentCenter];
    [self.loadLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [self.loadContainer addSubview:self.loadLabel];
    
    // Image lookup inside the bundle
    [self.muteButton setBackgroundImage:[UIImage imageNamed:@"PnUnMute" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]
                                forState:UIControlStateNormal];
    [self.muteButton setBackgroundImage:[UIImage imageNamed:@"PnMute" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]
                                forState:UIControlStateSelected];
    
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"PnClose" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]
                                forState:UIControlStateNormal];
    
    [self.learnMoreButton setBackgroundImage:[UIImage imageNamed:@"PNExternalLink" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]
                                    forState:UIControlStateNormal];
    
    [self.fullScreenButton setBackgroundImage:[UIImage imageNamed:@"PnFullScreen" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]
                                     forState:UIControlStateNormal];
    
    
    
    [self.skipButton setTitle:self.model.skip_video_button forState:UIControlStateNormal];
    [self.skipButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
}

#pragma mark PNVideoPlayerView

- (id)initWithFrame:(CGRect)frame
              model:(PNVastModel*)model
           delegate:(id<PNVideoPlayerViewDelegate>)delegate
{
    self = [super initWithNibName:NSStringFromClass([PNVideoPlayerView class]) bundle:[NSBundle bundleForClass:[PNVideoPlayerView class]]];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(close)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:NULL];
        
        self.trackingEvents = [[NSMutableArray alloc] init];
        self.delegate = delegate;
        self.model = model;
        self.skipTime = [model.video_skip_time intValue];
        self.frame = frame;
    }
    
    return self;
}

- (void)displayCloseButton
{
    self.isMaximized = YES;
    
    [self.closeButton setHidden:NO];
    [self.closeButton setEnabled:YES];
    
    [self.learnMoreButton setHidden:YES];
    [self.learnMoreButton setEnabled:NO];
    
    [self.fullScreenButton setHidden:YES];
    [self.fullScreenButton setEnabled:NO];
}

- (void)hideCloseButton
{
    self.isMaximized = NO;
    
    [self.closeButton setHidden:YES];
    [self.closeButton setEnabled:NO];
    
    [self.fullScreenButton setHidden:YES];
    [self.fullScreenButton setEnabled:NO];
    
    [self.learnMoreButton setHidden:NO];
    [self.learnMoreButton setEnabled:YES];
}

- (void)displayFullscreenButton
{
    self.isMaximized = NO;

    [self.learnMoreButton setHidden:YES];
    [self.learnMoreButton setEnabled:NO];
    
    [self.fullScreenButton setHidden:NO];
    [self.fullScreenButton setEnabled:YES];
}

- (void)hideFullscreenButton
{
    self.isMaximized = YES;
    
    [self.learnMoreButton setHidden:NO];
    [self.learnMoreButton setEnabled:YES];
    
    [self.fullScreenButton setHidden:YES];
    [self.fullScreenButton setEnabled:NO];
}

- (void)prepareAd:(VastContainer*)ad
{
    [self ad:ad autoStart:NO];
}

- (void)showAd:(VastContainer*)ad
{
    [self ad:ad autoStart:YES];
}

- (void)close
{
    [self.videoPlayer stop];
    
    if([self isModal])
    {
        [self dismissViewControllerAnimated:NO completion:^{
            [self invokeVideoCompleted];
        }];
    }
    else
    {
        if (self.isMaximized)
        {
            [self hideCloseButton];
            
            if (!self.isCompleted)
            {
                [self invokeVideoDismissedFullscreen];
            }
        }
        
        [self invokeVideoCompleted];
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.videoPlayer = nil;
}

- (void)invokeVideoDismissedFullscreen
{
    if ([self.delegate respondsToSelector:@selector(videoDismissedFullscreen)])
    {
        [self.delegate videoDismissedFullscreen];
    }
}

- (void)invokeVideoCompleted
{
    if([self.delegate respondsToSelector:@selector(videoCompleted)])
    {
        [self.delegate videoCompleted];
    }
}

- (void)invokeVideoClicked
{
    if([self.delegate respondsToSelector:@selector(videoClicked:)])
    {
        [self.delegate videoClicked:self.vastAd.mediaFile];
    }
}

- (void)invokeVideoReady
{
    if([self.delegate respondsToSelector:@selector(videoReady)])
    {
        [self.delegate videoReady];
    }
}

- (void)invokeVideoError:(NSInteger)errorCode withDetails:(NSString*)details
{
    if([self.delegate respondsToSelector:@selector(videoError:details:)])
    {
        [self.delegate videoError:errorCode details:details];
    }
}

- (void)invokeVideoPreparing
{
    if([self.delegate respondsToSelector:@selector(videoPreparing)])
    {
        [self.delegate videoPreparing];
    }
}

- (void)invokeVideoStartedWithDuration:(NSTimeInterval)duration
{
    if([self.delegate respondsToSelector:@selector(videoStartedWithDuration:)])
    {
        [self.delegate videoStartedWithDuration:duration];
    }
}

- (void)invokeVideoProgress:(NSTimeInterval)progress duration:(NSTimeInterval)duration
{
    if([self.delegate respondsToSelector:@selector(invokeVideoProgress:duration:)])
    {
        [self.delegate videoProgress:progress duration:duration];
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

#pragma mark - IBAction Methods

- (IBAction)skipAd:(id)sender
{
    [self close];
}

- (IBAction)muteAd:(id)sender;
{
    [self.videoPlayer mute];
    
    if (!self.videoPlayer.silenced)
    {
        [self.muteButton setSelected:NO];
    }
    else
    {
        [self.muteButton setSelected:YES];
    }
}

- (IBAction)learnMoreAd:(id)sender;
{
    [self tapGesture:nil];
}

- (IBAction)closeAd:(id)sender
{
    [self close];
}

- (IBAction)fullscreenAd:(id)sender
{
    [self.view removeFromSuperview];
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(presentingController.presentedViewController)
    {
        presentingController = presentingController.presentedViewController;
    }
    
    CGRect newFrame = presentingController.view.frame;
    self.view.frame = newFrame;
    self.videoPlayer.layer.frame = newFrame;
    [self displayCloseButton];
    [presentingController.view addSubview:self.view];
}

#pragma mark - Private Methods

- (void)ad:(VastContainer*)ad autoStart:(BOOL)autoStart
{
    self.vastAd = ad;
    self.autoStart = autoStart;
    
    self.cacher = [[PNVideoCacher alloc] initWithURL:self.vastAd.mediaFile];
    self.cacher.delegate = self;
    [self.cacher startCaching];
}

- (void)tapGesture:(UIGestureRecognizer*)sender
{
    [self.trackingEvents addObject:@"clickThrough"];
    if ((NSNull*)self.vastAd.clickThrough != [NSNull null])
    {
        [PNTrackingManager trackURLString:self.vastAd.clickThrough completion:nil];
    }
    
    [self invokeVideoClicked];
}

#pragma mark - DELEGATES -

#pragma mark PNVideoCacherDelegate

- (void)videoCacherDidCache:(NSString *)videoFile
{
    self.videoPlayer = [[PNVideoPlayer alloc] initWithDelegate:self];
    
    [self.videoPlayer open:videoFile autoplay:self.autoStart];
    [self invokeVideoReady];
}

- (void)videoCacherDidFail:(NSError *)error
{
    [self invokeVideoError:0 withDetails:[error description]];
}

#pragma mark PNVideoPlayerDelegate

- (void)videoViewAvailable:(AVPlayerLayer*)videolayer
{
    if (videolayer)
    {
        for(CALayer *layer in self.videoContainer.layer.sublayers)
        {
            [layer removeFromSuperlayer];
        }
        
        videolayer.frame = [self.view bounds];
        [self.videoContainer.layer addSublayer:videolayer];
    }
}

- (void)playbackPreparing
{
    [self invokeVideoPreparing];
    [self.videoPlayer pause];
}

- (void)playbackStartedWithDuration:(NSTimeInterval)duration
{
    [self.trackingEvents addObject:@"trackingStart"];
    if ((NSNull*)self.vastAd.trackingStart != [NSNull null])
    {
        [PNTrackingManager trackURLString:self.vastAd.trackingStart completion:nil];
    }
    
    [self invokeVideoStartedWithDuration:duration];
}

- (void)playbackCompleted
{
    self.isCompleted = YES;
    [self close];
    [self.trackingEvents addObject:@"trackingComplete"];
    if ((NSNull*)self.vastAd.trackingComplete != [NSNull null])
    {
        [PNTrackingManager trackURLString:self.vastAd.trackingComplete completion:nil];
    }
}

- (void)playbackProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration
{
    if (currentTime > 0)
    {
        if (currentTime >= duration/4 &&
            currentTime < duration/2 &&
            ![self.trackingEvents containsObject:@"trackingFirstQuartile"])
        {
            [self.trackingEvents addObject:@"trackingFirstQuartile"];
            if ((NSNull*)self.vastAd.trackingFirstQuartile != [NSNull null])
            {
                [PNTrackingManager trackURLString:self.vastAd.trackingFirstQuartile completion:nil];
            }
        }
        else if (currentTime > duration/2-1 &&
                 currentTime < duration/2+1 &&
                 ![self.trackingEvents containsObject:@"trackingMidpoint"])
        {
            [self.trackingEvents addObject:@"trackingMidpoint"];
            if ((NSNull*)self.vastAd.trackingMidpoint != [NSNull null])
            {
                [PNTrackingManager trackURLString:self.vastAd.trackingMidpoint completion:nil];
            }
        }
        else if (currentTime >= duration/4*3 &&
                 currentTime < duration &&
                 ![self.trackingEvents containsObject:@"trackingThirdQuartile"])
        {
            [self.trackingEvents addObject:@"trackingThirdQuartile"];
            if ((NSNull*)self.vastAd.trackingThirdQuartile != [NSNull null])
            {
                [PNTrackingManager trackURLString:self.vastAd.trackingThirdQuartile completion:nil];
            }
        }
        
        [self.loadLabel setProgress:currentTime/duration];
        [self.loadLabel setStartDegree:0.0];
        [self.loadLabel setStartDegree:359.9];
        
        if (currentTime >= self.skipTime)
        {
            [self.skipView setHidden:NO];
        }
        
        self.loadLabel.text = [NSString stringWithFormat:@"%.f", duration - currentTime];
        
        [self invokeVideoProgress:currentTime duration:duration];
    }
}

- (void)playbackError:(NSInteger)errorCode
{
    [self invokeVideoError:errorCode withDetails:[NSString stringWithFormat:@"Ad video playback failed %li", (long)errorCode]];
}

@end
