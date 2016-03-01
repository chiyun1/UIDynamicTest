//
//  BallView.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "BallView.h"

@implementation BallView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void) setupUI
{
    self.backgroundColor = [UIColor blueColor];
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 3;
    self.layer.borderColor = [[UIColor redColor] CGColor];
}
@end
