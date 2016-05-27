//
//  HHPNViewController.m
//  HHAdvertisement
//
//  Created by Hong on 16/5/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHPNViewController.h"
#import "HHAdCell.h"
#import "HHAdvertisementManager.h"


@interface HHPNViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HHAdvertisementManager *adManager;
@property (nonatomic, strong) NSArray *dataArray;


@end

@implementation HHPNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    _adManager = [[HHAdvertisementManager alloc] init];
    
    __weak HHPNViewController *weakSelf = self;

    [self.adManager fetchPNNatives:^(NSArray<PNNativeAdModel *> *resultArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.dataArray = resultArray;
        });
    }];
    
}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    [self.tableView reloadData];
}

#pragma mark - Delegate
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HHAdCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HHAdCell class])];
    if (!cell) {
        cell = [[HHAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([HHAdCell class])];
    }
    cell.pnAd = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

@end
