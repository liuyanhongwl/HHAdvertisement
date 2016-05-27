//
// PNTableViewManager.m
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

#import "PNTableViewManager.h"

NSString * const kPNTableViewCellDefaultID                  = @"pubnative_cell";
NSString * const kPNTableViewCellBannerID                   = @"pubnative_cell_banner";
NSString * const kPNTableViewCellIconID                     = @"pubnative_cell_icon";
NSString * const kPNTableViewCellVideoID                    = @"pubnative_cell_video";
NSString * const kPNTableViewCellCarouselID                 = @"pubnative_cell_carousel";
NSString * const kPNTableViewCellNativeID                   = @"pubnative_cell_native";

NSString * const kPNTableViewManagerClearAllNotification    = @"PNTableViewManagerClearAll";

@interface PNTableViewManager ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView                     *tableView;
@property (weak, nonatomic) NSObject<UITableViewDelegate>   *originalDelegate;
@property (weak, nonatomic) NSObject<UITableViewDataSource> *originalDataSource;

@end

@implementation PNTableViewManager

+ (instancetype)sharedManager
{
    static PNTableViewManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PNTableViewManager alloc] init];
    });
    return _sharedManager;
}

+ (CGFloat)heightForRowType:(Pubnative_FeedType)feedType
{
    CGFloat result = 60;
    switch (feedType)
    {
        case Pubnative_FeedType_Banner:     result = [PNBannerTableViewCell cellMinHeight];     break;
        case Pubnative_FeedType_Icon:       result = [PNIconTableViewCell cellMinHeight];       break;
        case Pubnative_FeedType_Video:      result = [PNVideoTableViewCell cellMinHeight];      break;
        case Pubnative_FeedType_Carousel:   result = [PNCarouselTableViewCell cellMinHeight];   break;
        case Pubnative_FeedType_Native:     result = [PNNativeTableViewCell cellMinHeight];     break;
    }
    return result;
}

+ (PNTableViewCell*)dequeueType:(Pubnative_FeedType)feedType
{
    NSString *reusableID = kPNTableViewCellDefaultID;
    switch (feedType)
    {
        case Pubnative_FeedType_Banner:     reusableID = kPNTableViewCellBannerID;      break;
        case Pubnative_FeedType_Icon:       reusableID = kPNTableViewCellIconID;        break;
        case Pubnative_FeedType_Video:      reusableID = kPNTableViewCellVideoID;       break;
        case Pubnative_FeedType_Carousel:   reusableID = kPNTableViewCellCarouselID;    break;
        case Pubnative_FeedType_Native:     reusableID = kPNTableViewCellNativeID;      break;
    }
    
    PNTableViewCell *cell = [[PNTableViewManager sharedManager].tableView dequeueReusableCellWithIdentifier:reusableID];
    if(!cell)
    {
        switch (feedType)
        {
            case Pubnative_FeedType_Banner:     cell = [[PNBannerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID];   break;
            case Pubnative_FeedType_Icon:       cell = [[PNIconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID];     break;
            case Pubnative_FeedType_Video:      cell = [[PNVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID];    break;
            case Pubnative_FeedType_Carousel:   cell = [[PNCarouselTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID]; break;
            case Pubnative_FeedType_Native:     cell = [[PNNativeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableID];   break;
        }
    }
    return cell;
}

+ (UITableView*)currentTable
{
    return [PNTableViewManager sharedManager].tableView;
}

+ (void)controlTable:(UITableView*)tableView
{
    if([PNTableViewManager sharedManager].tableView)
    {
        [PNTableViewManager sharedManager].tableView.delegate = [PNTableViewManager sharedManager].originalDelegate;
        [PNTableViewManager sharedManager].tableView.dataSource = [PNTableViewManager sharedManager].originalDataSource;
        [PNTableViewManager sharedManager].originalDelegate = nil;
        [PNTableViewManager sharedManager].originalDataSource = nil;
    }
    
    if(tableView)
    {
        [PNTableViewManager sharedManager].tableView = tableView;
        [PNTableViewManager sharedManager].originalDelegate = tableView.delegate;
        [PNTableViewManager sharedManager].originalDataSource = tableView.dataSource;
        
        UINib *nativeNib = [UINib nibWithNibName:NSStringFromClass([PNNativeTableViewCell class]) bundle:[NSBundle bundleForClass:[PNNativeTableViewCell class]]];
        [[PNTableViewManager sharedManager].tableView registerNib:nativeNib forCellReuseIdentifier:kPNTableViewCellNativeID];
        
        UINib *bannerNib = [UINib nibWithNibName:NSStringFromClass([PNBannerTableViewCell class]) bundle:[NSBundle bundleForClass:[PNBannerTableViewCell class]]];
        [[PNTableViewManager sharedManager].tableView registerNib:bannerNib forCellReuseIdentifier:kPNTableViewCellBannerID];
        
        tableView.delegate = [PNTableViewManager sharedManager];
        tableView.dataSource = [PNTableViewManager sharedManager];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPNTableViewManagerClearAllNotification object:nil];
    }
}

#pragma mark - Method Forwarding

- (BOOL)isKindOfClass:(Class)aClass
{
    return [super isKindOfClass:aClass] ||
    [self.originalDataSource isKindOfClass:aClass] ||
    [self.originalDelegate isKindOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [super conformsToProtocol:aProtocol] ||
    [self.originalDelegate conformsToProtocol:aProtocol] ||
    [self.originalDataSource conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] ||
    [self.originalDataSource respondsToSelector:aSelector] ||
    [self.originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.originalDataSource respondsToSelector:aSelector])
    {
        return self.originalDataSource;
    }
    else if ([self.originalDelegate respondsToSelector:aSelector])
    {
        return self.originalDelegate;
    }
    else
    {
        return [super forwardingTargetForSelector:aSelector];
    }
}

#pragma mark - DELEGATES -

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.originalDataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[PNVideoTableViewCell class]])
    {
        PNVideoTableViewCell *videoCell = (PNVideoTableViewCell*)cell;
        [videoCell willDisplayCell];
    }
    
    if([cell isKindOfClass:[PNBannerTableViewCell class]])
    {
        PNBannerTableViewCell *bannerCell = (PNBannerTableViewCell*)cell;
        [bannerCell willDisplayCell];
    }
    
    if([cell isKindOfClass:[PNIconTableViewCell class]])
    {
        PNIconTableViewCell *iconCell = (PNIconTableViewCell*)cell;
        [iconCell willDisplayCell];
    }
    
    if(self.originalDelegate != nil &&
       [self.originalDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
    {
        [self.originalDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[PNVideoTableViewCell class]])
    {
        PNVideoTableViewCell *videoCell = (PNVideoTableViewCell*)cell;
        [videoCell didEndDisplayingCell];
    }
    
    if([cell isKindOfClass:[PNBannerTableViewCell class]])
    {
        PNBannerTableViewCell *bannerCell = (PNBannerTableViewCell*)cell;
        [bannerCell didEndDisplayingCell];
    }
    
    if([cell isKindOfClass:[PNIconTableViewCell class]])
    {
        PNIconTableViewCell *iconCell = (PNIconTableViewCell*)cell;
        [iconCell didEndDisplayingCell];
    }
    
    if(self.originalDelegate != nil &&
       [self.originalDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
    {
        [self.originalDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}



@end
