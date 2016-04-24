//
//  HHVideoAdCell.m
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHVideoAdCell.h"
#import <AdColony/AdColonyNativeAdView.h>


@interface HHVideoAdCell ()

@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) UIImageView *adIcon;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HHVideoAdCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _adContainer = [[UIImageView alloc] init];
        _adContainer.contentMode = UIViewContentModeScaleAspectFill;
        _adContainer.clipsToBounds = YES;
        _adContainer.userInteractionEnabled = YES;
        _adContainer.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:_adContainer];
        
        _adIcon = [[UIImageView alloc] init];
        self.adIcon.image = [UIImage imageNamed:@"AD"];
        [self.contentView addSubview:self.adIcon];
        
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.removeButton setImage:[UIImage imageNamed:@"common_close"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.removeButton];
        
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        
        //约束
        self.adContainer.translatesAutoresizingMaskIntoConstraints = NO;
        self.adIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.removeButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        NSArray *adContainerConstraints = @[
                                            [NSLayoutConstraint constraintWithItem:self.adContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.adContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.adContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.adContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.adContainer attribute:NSLayoutAttributeHeight multiplier:2 constant:0]
                                            ];
        
        NSArray *adIconConstraints = @[
                                       [NSLayoutConstraint constraintWithItem:self.adIcon attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                       [NSLayoutConstraint constraintWithItem:self.adIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]
                                       ];
        
        NSArray *removeButtonConstraints = @[
                                             [NSLayoutConstraint constraintWithItem:self.removeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                             [NSLayoutConstraint constraintWithItem:self.removeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.adContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0]
                                             ];
        
        NSArray *titleLabelConstraints = @[
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.adContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.adContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.adContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:0]
                                           ];
        
        [self.contentView addConstraints:adContainerConstraints];
        [self.contentView addConstraints:adIconConstraints];
        [self.contentView addConstraints:removeButtonConstraints];
        [self.contentView addConstraints:titleLabelConstraints];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.text = self.adColonyView.adTitle;
    
    self.adColonyView.frame = self.adContainer.bounds;
    self.adColonyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (!self.adColonyView.superview) {
        [self.adContainer addSubview:self.adColonyView];
    }
}

#pragma mark - Public

- (void)setAdColonyView:(AdColonyNativeAdView *)adColonyView
{
    if (_adColonyView) {
        [_adColonyView pause];
        [_adColonyView removeFromSuperview];
    }
    
    _adColonyView = adColonyView;
    
    [self setNeedsLayout];
}

@end
