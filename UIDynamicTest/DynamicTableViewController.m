//
//  DynamicTableViewController.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "DynamicTableViewController.h"

#import "DynamicTableFlowLayout.h"

@interface UIColor (randomColor)
+ (id) randomColor;
@end

@implementation UIColor (randomColor)

+ (UIColor*) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}


@end

@interface DynamicTableViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@end

@implementation DynamicTableViewController
{
    UICollectionView* collectionViewTest;
    DynamicTableFlowLayout* flowlayout;
}


- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    flowlayout = [[DynamicTableFlowLayout alloc] init];
    flowlayout.itemSize = CGSizeMake(self.view.bounds.size.width, 100);
    flowlayout.minimumLineSpacing = 10;
    
    collectionViewTest = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowlayout];
    collectionViewTest.delegate = self;
    collectionViewTest.dataSource = self;
    [collectionViewTest registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"reuseid"];
    collectionViewTest.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionViewTest];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseid" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColor];
    return cell;
}


@end

