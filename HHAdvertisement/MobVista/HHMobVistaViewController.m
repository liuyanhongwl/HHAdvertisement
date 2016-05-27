//
//  HHMobVistaViewController.m
//  HHAdvertisement
//
//  Created by Hong on 16/5/24.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHMobVistaViewController.h"
#import "HHMobVistaTableView.h"
#import "SUNaviSegmentView.h"
#import "HHAdvertisementManager.h"

@interface HHMobVistaViewController ()<UIScrollViewDelegate, SUNaviSegmentViewDelegate>

@property (nonatomic, strong) SUNaviSegmentView *segmentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HHMobVistaTableView *featuredTableView;
@property (nonatomic, strong) HHMobVistaTableView *gameTableView;

@property (nonatomic, strong) HHAdvertisementManager *adManager;

@end

@implementation HHMobVistaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    _segmentView = [[SUNaviSegmentView alloc] initWithFrame:CGRectMake(0, navigationBarHeight + statusBarHeight, CGRectGetWidth(self.view.frame), 40)
                                              andTitleArray:@[@"FEATURED",@"GAMES"]
                                                   andSpace:12
                                          isAutoSliderWidth:NO];
    self.segmentView.segmentDelegate = self;
    self.segmentView.isAutoSliderWidth = NO;
    [self.view addSubview:self.segmentView];
    
    CGFloat topY = navigationBarHeight + statusBarHeight + CGRectGetHeight(self.segmentView.frame);
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - topY)];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * 2, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.scrollView];
    
    _featuredTableView = [[HHMobVistaTableView alloc] initWithFrame:self.scrollView.bounds];
    [self.scrollView addSubview:self.featuredTableView];
    
    _gameTableView = [[HHMobVistaTableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))];
    [self.scrollView addSubview:self.gameTableView];
    
    _adManager = [[HHAdvertisementManager alloc] init];
    [self.adManager fetchMobVista:^(NSArray *resultArray) {
        
    } presentingViewController:self];
}

#pragma mark - Delegate
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // update segmentView slider centerX
    CGFloat scrollScale = scrollView.contentOffset.x / scrollView.contentSize.width;
    CGFloat segmentWidth = CGRectGetWidth(self.segmentView.frame);
    CGFloat segmentItemWidth = self.segmentView.itemWidth;
    CGFloat segmentOffsetX = segmentWidth * scrollScale;
    
    [self.segmentView updateSelectedSliderCenterX:segmentOffsetX + segmentItemWidth / self.segmentView.titleArray.count];
}

#pragma mark SUNaviSegmentViewDelegate

- (void)naviSegmentView:(SUNaviSegmentView *)segmentView clickSegmentButtonAtIndex:(NSInteger)index
{
    [self.scrollView scrollRectToVisible:CGRectMake(index * CGRectGetWidth(self.scrollView.frame), 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)) animated:YES];
}

@end
