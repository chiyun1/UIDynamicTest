//
//  NewtonView.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "NewtonView.h"
#import "BallView.h"

@interface NewtonView ()
@property (nonatomic, assign) NSInteger ballCount;
@property (nonatomic, strong) NSArray* ballArray;
@property (nonatomic, strong) NSArray* anchorArray;
@property (nonatomic, strong) UIDynamicAnimator* animator;
@property (nonatomic, strong) UIPushBehavior* userDragBehavior;
@end

@implementation NewtonView

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
    self.backgroundColor = [UIColor whiteColor];
    self.ballCount = 5;
    [self createBallsAndAnchors];
    [self applyDynamicBehaviors];
}

- (void) dealloc
{
    [self.ballArray enumerateObjectsUsingBlock:^(BallView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeObserver:self forKeyPath:@"center"];
    }];
}

- (void) createBallsAndAnchors
{
    NSMutableArray* balls = [NSMutableArray array];
    NSMutableArray* anchors = [NSMutableArray array];
    
    CGFloat ballSize = CGRectGetWidth(self.bounds) / (3.0 * (self.ballCount - 1));
    
    for (NSInteger k = 0; k != self.ballCount; k++) {
        
        BallView* ball = [[BallView alloc] initWithFrame:CGRectMake(0, 0, ballSize-1, ballSize-1)];
        
        CGFloat x = CGRectGetWidth(self.bounds)/3.0+k*ballSize;
        CGFloat y = CGRectGetHeight(self.bounds)/1.5;
        ball.center = CGPointMake(x, y);
        
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ballPanHandle:)];
        [ball addGestureRecognizer:pan];
        
        [ball addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        
        [self addSubview:ball];
        [balls addObject:ball];
        
        UIView* anchorBox = [self createAnchorBox:ball];
        [self addSubview:anchorBox];
        [anchors addObject:anchorBox];
    }
    
    self.ballArray = balls;
    self.anchorArray = anchors;
}


- (UIView*) createAnchorBox:(BallView*) ball
{
    CGPoint cennter = ball.center;
    CGFloat lineHeight = CGRectGetHeight(self.bounds) / 4.0;
    cennter.y -= lineHeight;
    
    UIView* boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    boxView.backgroundColor = [UIColor blueColor];
    boxView.center = cennter;
    return boxView;
}

- (void) ballPanHandle: (UIPanGestureRecognizer*) gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.userDragBehavior) {
            [self.animator removeBehavior:self.userDragBehavior];
        }
        
        self.userDragBehavior = [[UIPushBehavior alloc] initWithItems:@[gesture.view] mode:UIPushBehaviorModeContinuous];
        [self.animator addBehavior:self.userDragBehavior];
    }
    
    self.userDragBehavior.pushDirection = CGVectorMake([gesture translationInView:self].x / 10.f, 0);
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        
        [self.animator removeBehavior:self.userDragBehavior];
        self.userDragBehavior = nil;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    //[[UIColor blackColor] setStroke];
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextBeginPath(context);
    
    for (NSInteger k = 0; k != self.ballArray.count; k++) {
        
        BallView* ball = [self.ballArray objectAtIndex:k];
        UIView* anchor = [self.anchorArray objectAtIndex:k];
        

        CGContextMoveToPoint(context, anchor.center.x, anchor.center.y);
        CGContextAddLineToPoint(context, ball.center.x, ball.center.y);
    }
    
    CGContextStrokePath(context);
}

- (void) applyDynamicBehaviors
{
    UIDynamicBehavior* behavior = [[UIDynamicBehavior alloc] init];
    
    [self applyAttatchmentBehaviorForBalls:behavior];
    [behavior addChildBehavior: [self createGravityBehaviorForBalls:self.ballArray]];
    [behavior addChildBehavior: [self createCollisionBehaviorForBalls:self.ballArray]];
    [behavior addChildBehavior: [self createItemBehavior]];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    [self.animator addBehavior:behavior];
}


- (void) applyAttatchmentBehaviorForBalls: (UIDynamicBehavior* ) behavior
{
    for (NSInteger k = 0; k != self.ballArray.count; k++) {
        BallView* ball = [self.ballArray objectAtIndex:k];
        UIView* anchor = [self.anchorArray objectAtIndex:k];
        
        [behavior addChildBehavior:[self createAttatchBehaviorForBallBearing:ball toAnchor:anchor]];
    }
}


- (UIDynamicBehavior*) createAttatchBehaviorForBallBearing:(id<UIDynamicItem>) ball toAnchor: (id<UIDynamicItem>) anchor
{
    UIAttachmentBehavior* attachment = [[UIAttachmentBehavior alloc] initWithItem:ball attachedToAnchor:anchor.center];
    return attachment;
}

- (UIDynamicBehavior*) createGravityBehaviorForBalls:(NSArray*) balls
{
    UIGravityBehavior* gravity = [[UIGravityBehavior alloc] initWithItems:balls];
    gravity.magnitude = 10;
    return gravity;
}

- (UIDynamicBehavior*) createCollisionBehaviorForBalls:(NSArray*) balls
{
    UICollisionBehavior* collision = [[UICollisionBehavior alloc] initWithItems:balls];
    return collision;
}

- (UIDynamicItemBehavior*) createItemBehavior
{
    UIDynamicItemBehavior* itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.ballArray];
    itemBehavior.elasticity = 1.0;
    itemBehavior.allowsRotation = NO;
    itemBehavior.resistance = 1.f;
    return itemBehavior;
}

@end
