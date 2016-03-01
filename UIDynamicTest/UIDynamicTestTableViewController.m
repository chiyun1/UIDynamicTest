//
//  UIDynamicTestTableViewController.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "UIDynamicTestTableViewController.h"
#import "NewtonViewController.h"
#import "dropBallViewController.h"
#import "DynamicTableViewController.h"
#import "AttatchTestViewController.h"

@implementation UIDynamicTestTableViewController

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* array = @[@"牛顿摆", @"掉落的小球", @"有重力效果的列表", @"吸附效果"];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reuseid"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseid"];
    }
    
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NewtonViewController* vc = [[NewtonViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == 1){
        dropBallViewController* vc = [[dropBallViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == 2){
        DynamicTableViewController* vc = [[DynamicTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == 3){
        AttatchTestViewController* vc = [[AttatchTestViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
