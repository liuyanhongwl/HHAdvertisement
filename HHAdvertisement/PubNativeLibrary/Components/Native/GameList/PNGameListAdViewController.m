//
// PNGameListAdTableViewController.m
//
// Created by David Martin on 16/03/15.
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


#import "PNGameListAdViewController.h"
#import "PNTrackingManager.h"
#import "PNAdConstants.h"
#import "PNGameListTableViewCell.h"

NSString * const kPNGameListAdViewControllerCellReusableID = @"PNGameListTableViewCell";

@interface PNGameListAdViewController () <UITableViewDataSource, UITableViewDelegate, PNGameListTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pubnativeLogoImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, assign)BOOL       wasStatusBarHidden;
@property (nonatomic, strong)NSArray    *ads;

@end

@implementation PNGameListAdViewController

#pragma mark NSObject

- (void)dealloc
{
    self.ads = nil;
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.versionLabel.text = [PNAdConstants version];
    
    [self.closeButton setImage:[UIImage imageNamed:@"PNCloseIcon"
                                          inBundle:[NSBundle bundleForClass:[self class]]
                     compatibleWithTraitCollection:nil]
                      forState:UIControlStateNormal];
    
    [self.pubnativeLogoImageView setImage:[UIImage imageNamed:@"PNLogoGrey"
                                                     inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PNGameListTableViewCell class]) bundle:[NSBundle bundleForClass:[PNGameListTableViewCell class]]]
         forCellReuseIdentifier:kPNGameListAdViewControllerCellReusableID];
    
    if([self.delegate respondsToSelector:@selector(pnAdDidLoad:)])
    {
        [self.delegate pnAdDidLoad:self];
    }
    
    if([self.delegate respondsToSelector:@selector(pnAdReady:)])
    {
        [self.delegate pnAdReady:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdWillShow)])
    {
        [self.delegate pnAdWillShow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidShow)])
    {
        [self.delegate pnAdDidShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.wasStatusBarHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(pnAdWillClose)])
    {
        [self.delegate pnAdWillClose];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.delegate pnAdDidClose];
    }
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark PNGameListAdViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                            ads:(NSArray *)ads
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self)
    {
        self.wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        self.ads = ads;
    }
    
    return self;
}

- (IBAction)closePressed:(id)sender
{
    if([self isModal])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
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

#pragma mark -  DELEGATES -

#pragma mark PNGameListTableViewCellDelegate

- (void)pnGameListCellSelected
{
    [self closePressed:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 0;
    if(self.ads)
    {
        result = [self.ads count];
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNGameListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPNGameListAdViewControllerCellReusableID];
    cell.delegate = self;
    [cell setModel:[self.ads objectAtIndex:indexPath.row]];
    [cell setDark:((indexPath.row+1) % 2 == 0)?YES:NO];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNGameListTableViewCell *gameCell = (PNGameListTableViewCell*)cell;
    [gameCell didDisplay];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNGameListTableViewCell *gameCell = (PNGameListTableViewCell*)cell;
    [gameCell willDisplay];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
