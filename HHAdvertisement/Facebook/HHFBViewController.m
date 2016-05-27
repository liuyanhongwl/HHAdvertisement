//
//  HHFBViewController.m
//  HHAdvertisement
//
//  Created by Hong on 16/4/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHFBViewController.h"
#import "HHAdCell.h"
#import "HHAdvertisementManager.h"

@interface HHFBViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HHAdvertisementManager *adManager;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation HHFBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
 
    
    _adManager = [[HHAdvertisementManager alloc] init];
    
    __weak HHFBViewController *weakSelf = self;
    
    [self.adManager fetchFBNatives:^(NSArray *resultArray) {
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
    cell.fbAd = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

@end
