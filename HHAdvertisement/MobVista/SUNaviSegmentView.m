//
//  LDNaviSegmentView.m
//  LesDo
//
//  Created by hong on 15/4/11.
//  Copyright (c) 2015年 xin wang. All rights reserved.
//

#import "SUNaviSegmentView.h"
 
 

#define Tag_SegmentButton 100

@interface SUNaviSegmentView ()

@end

@implementation SUNaviSegmentView

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andSpace:(float)space isAutoSliderWidth:(BOOL)isAutoSliderWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.space = space;
        self.titleArray = titleArray;
        [self _prepareData];
        [self _prepareUI];
        
        self.isAutoSliderWidth = isAutoSliderWidth;
    }
    return self;
}


- (void)_prepareData
{
    //      实例化 按钮缓存数组
    _buttonArray = [NSMutableArray arrayWithCapacity:3];
}

- (void)_prepareUI
{
    self.backgroundColor = [UIColor clearColor];
    
    self.itemWidth = CGRectGetWidth(self.frame) / self.titleArray.count - self.space * (self.titleArray.count - 1);
    
    //      控件
    for (int i = 0; i < _titleArray.count; i ++) {
        //     控件上面的按钮
        UIButton * segmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        segmentButton.frame = CGRectMake((self.itemWidth + self.space) * i, 0, self.itemWidth, CGRectGetHeight(self.frame));
        segmentButton.backgroundColor = self.backgroundColor;
        [segmentButton setTitle:_titleArray[i] forState:UIControlStateNormal];
        //      默认选中第一个按钮
        if (i == 0) {
            [segmentButton setSelected:YES];
        } else {
            [segmentButton setSelected:NO];
        }
        [segmentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [segmentButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [segmentButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        segmentButton.tag = Tag_SegmentButton + i;
        [segmentButton addTarget:self action:@selector(segmentViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:segmentButton];
        [_buttonArray addObject:segmentButton];
    }
    
    
    //      底部 绿色滑块
    _selectedSliderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 2, self.itemWidth, 2)];
    _selectedSliderView.backgroundColor = [UIColor redColor];
    [self addSubview:_selectedSliderView];
    
}

#pragma mark - Button Action
///     按钮触发方法
- (void)segmentViewButtonAction:(UIButton *)button {
    
    NSInteger pageIndex = button.tag - Tag_SegmentButton;
    if (_segmentDelegate && [_segmentDelegate respondsToSelector:@selector(naviSegmentView:clickSegmentButtonAtIndex:)]) {
        [_segmentDelegate naviSegmentView:self clickSegmentButtonAtIndex:pageIndex];
    }
    
}

//  更改SegmentButton的 状态
- (void)changeSegmentButtonAtIndex:(NSInteger)pageIndex
{
    
    for (UIButton * segmentButton in _buttonArray) {
        //      更新 按钮颜色
        if (segmentButton.tag == pageIndex + Tag_SegmentButton) {
            //      此为被点击的按钮
            [segmentButton setSelected:YES];
        } else {
            [segmentButton setSelected:NO];
        }
    }
    
    if (pageIndex >= 0 && pageIndex < _buttonArray.count && _isAutoSliderWidth) {
        UIButton *segmentButton = [_buttonArray objectAtIndex:pageIndex];
        
        CGRect frame = _selectedSliderView.frame;
        frame.size.width = CGRectGetWidth(segmentButton.titleLabel.frame);
        _selectedSliderView.frame = frame;
        
    }
}

///     更新 选中滑块的 坐标
- (void)updateSelectedSliderCenterX:(CGFloat)centerX {
    CGPoint center_sliderView = _selectedSliderView.center;
    center_sliderView.x = centerX;
    _selectedSliderView.center = center_sliderView;
    
    NSInteger pageIndex = _selectedSliderView.center.x / (CGRectGetWidth(self.frame) / _buttonArray.count);
    [self changeSegmentButtonAtIndex:pageIndex];

}

///     设置 样式
- (void)setStyleFont:(UIFont *)font tintColor:(UIColor *)tintColor defaultColor:(UIColor *)defaultColor
{
    for (UIButton * segmentButton in _buttonArray) {
        //      更新 按钮颜色
        segmentButton.titleLabel.font = font;
        [segmentButton setTitleColor:defaultColor forState:UIControlStateNormal];
        [segmentButton setTitleColor:tintColor forState:UIControlStateHighlighted];
        [segmentButton setTitleColor:tintColor forState:UIControlStateSelected];
        _selectedSliderView.backgroundColor = tintColor;
    }
}

-(void)setIsAutoSliderWidth:(BOOL)isAutoSliderWidth
{
    _isAutoSliderWidth = isAutoSliderWidth;
    if (_isAutoSliderWidth) {
        UIButton *segmentButton = [_buttonArray objectAtIndex:0];
        
        CGRect frame = _selectedSliderView.frame;
        frame.size.width = [self.titleArray.firstObject sizeWithFont:segmentButton.titleLabel.font].width;
        _selectedSliderView.frame = frame;
        
        CGPoint sliderCenter = _selectedSliderView.center;
        sliderCenter.x = segmentButton.center.x;
        _selectedSliderView.center = sliderCenter;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
