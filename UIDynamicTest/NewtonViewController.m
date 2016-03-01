//
//  NewtonViewController.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "NewtonViewController.h"
#import "NewtonView.h"

@implementation NewtonViewController{
    NewtonView* testView;
}


- (void) viewDidLoad
{
    testView = [[NewtonView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:testView];
}
@end
