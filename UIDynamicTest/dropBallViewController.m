//
//  dropBallViewController.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "dropBallViewController.h"
#import "BallView.h"


const CGFloat kStageHeight = 100;

@interface backgroundTestView : UIView

@end

@implementation backgroundTestView

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();


    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextSetLineWidth(context, 1);
    
    CGPathMoveToPoint(path, nil, 0, self.bounds.size.height - kStageHeight);
    CGPathAddCurveToPoint(path, nil, 0, self.bounds.size.height - kStageHeight, self.bounds.size.width/2, self.bounds.size.height+kStageHeight, self.bounds.size.width, self.bounds.size.height - kStageHeight);
    CGPathAddLineToPoint(path, nil, self.bounds.size.width, 0);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

@end

@interface dropBallViewController ()<UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate>

@end

@implementation dropBallViewController{
    UIView* stageView;
    NSArray* ballArray;
    
    UIDynamicAnimator* animator;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBallHandle:)];
    [self.view addGestureRecognizer:tap];
    
    [self createStageView];
    
}


- (void) tapBallHandle: (UITapGestureRecognizer*) gesture
{
    BallView* ball = [self createBall:[gesture locationInView:self.view]];
    
    [self createDynamicAffect:ball];
}

- (void) createStageView
{
    backgroundTestView* testView = [[backgroundTestView alloc] initWithFrame:self.view.bounds];
    testView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:testView];
    
    stageView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - kStageHeight, CGRectGetWidth(self.view.bounds), kStageHeight)];
    stageView.backgroundColor = [UIColor orangeColor];
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, 0);
    CGPathAddLineToPoint(path, nil, 0, stageView.bounds.size.height);
    CGPathAddLineToPoint(path, nil, stageView.bounds.size.width, stageView.bounds.size.height);
    CGPathAddLineToPoint(path, nil, stageView.bounds.size.width, 0);
    CGPathAddCurveToPoint(path, nil, stageView.bounds.size.width, 0, stageView.bounds.size.width/2, stageView.bounds.size.height, 0, 0);
    CGPathCloseSubpath(path);
    
    maskLayer.path = path;
    stageView.layer.mask = maskLayer;
    
    //[self.view addSubview:stageView];
}

- (BallView*) createBall: (CGPoint) pt
{
    BallView* ball = [[BallView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    ball.center = pt;
    [self.view addSubview:ball];
    return ball;
}

- (void) createDynamicAffect : (BallView*) ball                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         {

    if (!animator) {
        animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        UIDynamicBehavior* behavior = [[UIDynamicBehavior alloc ] init];
        [behavior addChildBehavior:[self createGravityBehaviorForBall:ball]];
        [behavior addChildBehavior:[self createCollisionBehavior:ball]];
        [behavior addChildBehavior:[self createDynamicItemBehavior:ball]];
        
        [animator addBehavior:behavior];
    }
    else{
        NSArray* behaviors = animator.behaviors;
        if (behaviors && behaviors.count != 0) {
            UIDynamicBehavior* behavior = [behaviors objectAtIndex:0];
            
            if (behavior.childBehaviors && behavior.childBehaviors.count != 0) {
                [behavior.childBehaviors enumerateObjectsUsingBlock:^(__kindof UIDynamicBehavior * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj isKindOfClass:[UIGravityBehavior class]]) {
                        UIGravityBehavior* gravity = (UIGravityBehavior*)obj;
                        [gravity addItem:ball];
                    }
                    else if([obj isKindOfClass:[UICollisionBehavior class]]){
                        UICollisionBehavior* collision = (UICollisionBehavior*)obj;
                        [collision addItem:ball];
                    }
                    else if([obj isKindOfClass:[UIDynamicItemBehavior class]]){
                        UIDynamicItemBehavior* dynamicItem = (UIDynamicItemBehavior*)obj;
                        [dynamicItem addItem:ball];
                    }
                }];
            }
        }
    }

}

- (UIDynamicBehavior*) createGravityBehaviorForBall: (BallView*) ball
{
    UIGravityBehavior* gravity = [[UIGravityBehavior alloc] initWithItems:@[ball]];
    gravity.magnitude = 9.8;
    return gravity;
}

- (UIDynamicBehavior*) createCollisionBehavior: (BallView*) ball
{
    UICollisionBehavior* collision = [[UICollisionBehavior alloc] initWithItems:@[ball]];

    UIBezierPath* subpath = [UIBezierPath bezierPath];

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, self.view.bounds.size.height - kStageHeight);
    CGPathAddCurveToPoint(path, nil, 0, self.view.bounds.size.height - kStageHeight, self.view.bounds.size.width/2, self.view.bounds.size.height + kStageHeight, self.view.bounds.size.width, self.view.bounds.size.height - kStageHeight);
    CGPathAddLineToPoint(path, nil, self.view.bounds.size.width, 0);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathCloseSubpath(path);
    
    [subpath setCGPath:path];
    [collision addBoundaryWithIdentifier:@"bottomStage" forPath:subpath];
    
    collision.action = ^{
        NSLog(@"center: %f, %f", ball.center.x, ball.center.y);
    };
    collision.collisionDelegate = self;
    return collision;
}

- (UIDynamicBehavior*) createDynamicItemBehavior: (BallView*) ball
{
    UIDynamicItemBehavior* itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ball]];
    itemBehavior.resistance = 5.0;
    itemBehavior.elasticity = .6;
    itemBehavior.allowsRotation = YES;
    
    return itemBehavior;
}

#pragma mark -- UICollisionBehaviorDelegate]
- (void) collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
}

@end
