//
//  AttatchTestViewController.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "AttatchTestViewController.h"

@interface AttatchBottomView : UIView

@end

@implementation AttatchBottomView

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIView* anchor = [self.superview viewWithTag:101];
    UIView* box = [self.superview viewWithTag:102];
    
    CGContextMoveToPoint(context, anchor.center.x, anchor.center.y);
    CGContextAddLineToPoint(context, box.center.x, box.center.y);
    [[UIColor blackColor] setStroke];
    
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

@end


@implementation AttatchTestViewController
{
    AttatchBottomView* attatchBottomView;
    UIView* boxView;
    UIView* anchorPointView;
    UIDynamicAnimator* animator;
    
    CGPoint startPoint;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    attatchBottomView = [[AttatchBottomView alloc] initWithFrame:self.view.bounds];
    attatchBottomView.backgroundColor = [UIColor whiteColor];
    attatchBottomView.tag = 100;
    [self.view addSubview:attatchBottomView];
    
    CGPoint center = self.view.center;
    
    anchorPointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    anchorPointView.center = center;
    anchorPointView.tag = 101;
    anchorPointView.backgroundColor = [UIColor redColor];
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandle:)];
    [anchorPointView addGestureRecognizer:pan];
    [attatchBottomView addSubview:anchorPointView];
    
    CGPoint boxCenter = center;
    boxCenter.y += 150;
    boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    boxView.center = boxCenter;
    boxView.tag = 102;
    boxView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:.7];
    [attatchBottomView addSubview:boxView];
    
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:attatchBottomView];
    
    UIAttachmentBehavior* behavior = [[UIAttachmentBehavior alloc] initWithItem:boxView attachedToAnchor:center];
    
    //如果要实现弹性吸附，需要设置下面两个属性。好的 理想的效果需要协调这两个参数的值
    behavior.damping = 300; //值越大，则物体的惰性越大
    behavior.frequency = 500; //值越大，物体跟随吸附的速度越快
    
    behavior.action = ^{
        [attatchBottomView setNeedsDisplay];
    };
    [animator addBehavior:behavior];
    
    UIGravityBehavior* gravity = [[UIGravityBehavior alloc] initWithItems:@[boxView]];
    gravity.magnitude = 10;
    [animator addBehavior:gravity];
    
    
    UIDynamicItemBehavior* dynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[boxView]];
    dynamicItem.resistance = 5.0;
    dynamicItem.elasticity = 1;
    [animator addBehavior:dynamicItem];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen)];
    [self.view addGestureRecognizer:tap];
}


- (void) panGestureRecognizerHandle:(UIPanGestureRecognizer*) pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        startPoint = [pan locationInView:attatchBottomView];
    }
    else if(pan.state == UIGestureRecognizerStateChanged){
        CGPoint offset = [pan translationInView:attatchBottomView];
        CGPoint new = CGPointMake(startPoint.x + offset.x, startPoint.y + offset.y);
        anchorPointView.center = new;
        
        UIAttachmentBehavior* attatch = [animator.behaviors firstObject];
        attatch.anchorPoint = new;
        [animator updateItemUsingCurrentState:boxView];
        
    }
    else if(pan.state == UIGestureRecognizerStateEnded ||
            pan.state == UIGestureRecognizerStateFailed ||
            pan.state == UIGestureRecognizerStateCancelled){
        
        
    }
    
}


- (void) tapScreen
{
    [animator.behaviors enumerateObjectsUsingBlock:^(__kindof UIDynamicBehavior * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIPushBehavior class]]) {
            [animator removeBehavior:obj];
            *stop = YES;
        }
    }];
    
    UIPushBehavior* push = [[UIPushBehavior alloc] initWithItems:@[boxView] mode:UIPushBehaviorModeInstantaneous];
    push.magnitude = 20.0;
    push.pushDirection = CGVectorMake(1, 0);
    [animator addBehavior:push];
}

@end
