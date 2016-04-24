//
//  HHAdColonyViewController.m
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHAdColonyViewController.h"
#import "HHAdvertisementManager.h"
#import "HHVideoAdCell.h"

@interface HHAdColonyViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) HHAdvertisementManager *adManager;

@end

@implementation HHAdColonyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    __weak HHAdColonyViewController *weakSelf = self;
    
    self.adManager = [[HHAdvertisementManager alloc] init];
    [self.adManager fetchAdColonyNativeAdViews:^(NSArray *resultArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.dataArray = resultArray;
        });
    } presentingViewController:self];
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
    HHVideoAdCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HHVideoAdCell class])];
    if (!cell) {
        cell = [[HHVideoAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([HHVideoAdCell class])];
    }
    cell.adColonyView = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}


@end
