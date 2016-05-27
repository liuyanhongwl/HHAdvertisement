//
//  HHMobVistaTableView.m
//  HHAdvertisement
//
//  Created by Hong on 16/5/24.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "HHMobVistaTableView.h"

@interface HHMobVistaTableView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation HHMobVistaTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

#pragma mark - Delegate
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
