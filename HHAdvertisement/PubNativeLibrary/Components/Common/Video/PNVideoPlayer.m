//
// PNVideoPlayer.m
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

#import "PNVideoPlayer.h"

@implementation PNVideoPlayer

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.avPlayer pause];
    self.avPlayer = nil;
    
    [self.layer removeFromSuperlayer];
    self.layer = nil;
}

#pragma mark PNVideoPlayer

- (id)initWithDelegate:(id<PNVideoPlayerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
    }
    return self;
}

- (void)open:(NSString*)urlString autoplay:(BOOL)autoplay
{
    [self cleanup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.avPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidStarted:)
                                                 name:@"PlaybackStartedNotification"
                                               object:nil];
    
    NSURL *url = nil;
    
	if ([urlString hasPrefix:@"/"])
    {
        url = [NSURL fileURLWithPath:urlString];
    }
    else
    {
        url= [NSURL URLWithString:urlString];
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    self.avPlayer = avPlayer;
    
    __weak PNVideoPlayer *weakSelf = self;
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC)
                                                queue:nil
                                           usingBlock:^(CMTime time) {
                                               [weakSelf onProgressTimer];
                                           }];
    
    self.layer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    if ([self.delegate respondsToSelector:@selector(videoViewAvailable:)])
    {
        [self.delegate videoViewAvailable:self.layer];
    }
    
    if ([self.delegate respondsToSelector:@selector(playbackPreparing)])
    {
        [self.delegate playbackPreparing];
    }
}

- (void)close
{
    [self stop];
    [self cleanup];
}

- (void)cleanup
{
    [self.layer removeFromSuperlayer];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)play
{
    [self.avPlayer play];
}

- (void)stop
{
    [self.avPlayer pause];
}

- (void)pause
{
    [self.avPlayer pause];
}

- (void)mute
{
    if (![self silenced])
    {
        self.avPlayer.volume = 0.0f;
        self.silenced = YES;
    }
    else
    {
        self.avPlayer.volume = 1.0f;
        self.silenced = NO;
    }
}

- (NSInteger)duration
{
    AVPlayerItem *currentItem = self.avPlayer.currentItem;
    NSInteger i = (long)CMTimeGetSeconds([currentItem duration]);
    return i;
}

- (NSInteger)currentPosition
{
    AVPlayerItem *currentItem = self.avPlayer.currentItem;
    NSInteger i = (long)CMTimeGetSeconds([currentItem currentTime]);
    return i;
}


#pragma mark - NOTIFICATIONS -
#pragma mark MPMoviePlayer Notifications

- (void)moviePlayBackDidStarted:(NSNotification*)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playbackStartedWithDuration:)])
    {
        [self.delegate playbackStartedWithDuration:[self duration]];
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playbackCompleted)])
    {
        [self.delegate playbackCompleted];
    }
}

- (void)onProgressTimer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playbackProgress:duration:)])
    {
        [self.delegate playbackProgress:[self currentPosition]
                               duration:[self duration]];
    }
}

@end
