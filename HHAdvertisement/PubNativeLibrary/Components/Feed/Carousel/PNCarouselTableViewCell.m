//
// PNCarouselTableViewCell.m
//
// Created by David Martin on 24/10/14.
// Copyright (c) 2014 PubNative.
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
//

#import "PNCarouselTableViewCell.h"
#import "PNCarouselContainerView.h"

@interface PNCarouselTableViewCell ()

@property (strong, nonatomic) PNCarouselContainerView *collectionView;

@end

@implementation PNCarouselTableViewCell

#pragma mark NSObject

- (void)dealloc
{
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

#pragma mark UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSString *className = NSStringFromClass([PNCarouselContainerView class]);
        _collectionView = [[NSBundle bundleForClass:[PNCarouselContainerView class]]
                                      loadNibNamed:className
                                             owner:self
                                           options:nil][0];
        _collectionView.frame = self.bounds;
        [self.contentView addSubview:_collectionView];
    }
    return self;
}

#pragma mark PNTableViewCell

+ (CGFloat)cellMinHeight
{
    return [PNCarouselContainerView itemSize].height;
}

#pragma mark PNArrayModelTAbleViewCell

- (void)setModel:(NSArray *)model
{
    self.collectionView.model = model;
}

@end
