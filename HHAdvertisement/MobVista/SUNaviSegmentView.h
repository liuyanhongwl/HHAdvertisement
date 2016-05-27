
//
//  LDNaviSegmentView.h
//  LesDo
//
//  Created by hong on 15/4/11.
//  Copyright (c) 2015年 xin wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUNaviSegmentView;
@protocol SUNaviSegmentViewDelegate <NSObject>

///     点击分页控制器后    用于更新数据
- (void)naviSegmentView:(SUNaviSegmentView *)segmentView clickSegmentButtonAtIndex:(NSInteger)index;

@end

@interface SUNaviSegmentView : UIView
{
    //      Data
    ///     用于缓存 所有按钮
    NSMutableArray * _buttonArray;
    
    //      UI
    ///     选中状态滑块
    UIView * _selectedSliderView;
}

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andSpace:(float)space isAutoSliderWidth:(BOOL)isAutoSliderWidth;

@property (nonatomic, assign)id<SUNaviSegmentViewDelegate> segmentDelegate;

@property (nonatomic, strong)NSArray *titleArray;

///  是否自动变化线的宽度
@property (nonatomic, assign)BOOL isAutoSliderWidth;

@property (nonatomic, assign)float space;

@property (nonatomic, assign)float itemWidth;

///     更新 选中滑块
//- (void)changeSegmentButtonAtIndex:(NSInteger)pageIndex;

///     更新 选中滑块的 坐标
- (void)updateSelectedSliderCenterX:(CGFloat)centerX;

///     设置 样式
/// font : 标题字体
/// tintColor : 选中颜色
/// defaultColor : 默认颜色
- (void)setStyleFont:(UIFont *)font tintColor:(UIColor *)tintColor defaultColor:(UIColor *)defaultColor;


@end
