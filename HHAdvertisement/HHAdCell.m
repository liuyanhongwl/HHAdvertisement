//
//  SUAdCell.m
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHAdCell.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "PNNativeAdModel.h"
#import "UIImageView+WebCache.h"

@interface HHAdCell ()

@property (nonatomic, strong) FBMediaView *mediaView;
@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) UIImageView *adIcon;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *actionButton;

@end

@implementation HHAdCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _mediaView = [[FBMediaView alloc] init];
        [self.contentView addSubview:self.mediaView];
        
        _adImageView = [[UIImageView alloc] init];
        self.adImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.adImageView];
        
        _adIcon = [[UIImageView alloc] init];
        self.adIcon.image = [UIImage imageNamed:@"AD"];
        [self.contentView addSubview:self.adIcon];
        
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.removeButton setImage:[UIImage imageNamed:@"common_close"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.removeButton];
        
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.subtitleLabel];
        
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.actionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.actionButton];
        
        //约束
        self.mediaView.translatesAutoresizingMaskIntoConstraints = NO;
        self.adImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.adIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.removeButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *mediaViewConstraints = @[
                                          [NSLayoutConstraint constraintWithItem:self.mediaView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                          [NSLayoutConstraint constraintWithItem:self.mediaView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                          [NSLayoutConstraint constraintWithItem:self.mediaView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                          [NSLayoutConstraint constraintWithItem:self.mediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.mediaView attribute:NSLayoutAttributeHeight multiplier:2 constant:0],
                                          ];
        
        NSArray *adImageViewConstraints = @[
                                            [NSLayoutConstraint constraintWithItem:self.adImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.adImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.adImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                            [NSLayoutConstraint constraintWithItem:self.adImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.adImageView attribute:NSLayoutAttributeHeight multiplier:2 constant:0],
                                            ];
        
        NSArray *adIconConstraints = @[
                                       [NSLayoutConstraint constraintWithItem:self.adIcon attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                       [NSLayoutConstraint constraintWithItem:self.adIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]
                                       ];
        
        NSArray *removeButtonConstraints = @[
                                             [NSLayoutConstraint constraintWithItem:self.removeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                             [NSLayoutConstraint constraintWithItem:self.removeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.mediaView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]
                                             ];
        
        NSArray *titleLabelConstraints = @[
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mediaView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mediaView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.actionButton attribute:NSLayoutAttributeLeading multiplier:1 constant:0]
                                           ];
        
        NSArray *subTitleLabelConstraints = @[
                                              [NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mediaView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.actionButton attribute:NSLayoutAttributeLeading multiplier:1 constant:0]
                                              ];
        
        NSArray *actionButtonConstraints = @[
                                             [NSLayoutConstraint constraintWithItem:self.actionButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                             [NSLayoutConstraint constraintWithItem:self.actionButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]
                                             ];
        
        [self.contentView addConstraints:mediaViewConstraints];
        [self.contentView addConstraints:adImageViewConstraints];
        [self.contentView addConstraints:adIconConstraints];
        [self.contentView addConstraints:removeButtonConstraints];
        [self.contentView addConstraints:titleLabelConstraints];
        [self.contentView addConstraints:subTitleLabelConstraints];
        [self.contentView addConstraints:actionButtonConstraints];
        
        [self.actionButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.fbAd) {
        
        [self.actionButton setTitle:[NSString stringWithFormat:@"%@", self.fbAd.callToAction] forState:UIControlStateNormal];
        self.titleLabel.text = self.fbAd.title;
        self.subtitleLabel.text = self.fbAd.subtitle;
        
    }else if (self.pnAd){
        
        [self.actionButton setTitle:self.pnAd.cta_text forState:UIControlStateNormal];
        self.titleLabel.text = self.pnAd.title;
        self.subtitleLabel.text = self.pnAd.Description;
     
        [self.adImageView sd_setImageWithURL:[NSURL URLWithString:self.pnAd.banner_url]];
    }
}

#pragma mark - Public

- (void)setFbAd:(FBNativeAd *)fbAd
{
    _fbAd = fbAd;
    
    [self.mediaView setNativeAd:fbAd];
}

- (void)setPnAd:(PNNativeAdModel *)pnAd
{
    _pnAd = pnAd;
}

@end
