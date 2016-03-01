//
//  DynamicTableFlowLayout.m
//  UIDynamicTest
//
//  Created by 马龙 on 16/3/1.
//  Copyright © 2016年 马龙. All rights reserved.
//

#import "DynamicTableFlowLayout.h"

@interface DynamicTableFlowLayout ()
@property (nonatomic, strong) UIDynamicAnimator* animator;
@end

@implementation DynamicTableFlowLayout

- (void) prepareLayout
{
    [super prepareLayout];
    
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        
        CGSize size = [self collectionViewContentSize];
        NSArray* items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, size.width, size.height)];
        
        [items enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAttachmentBehavior* spring = [[UIAttachmentBehavior alloc] initWithItem:obj attachedToAnchor:obj.center];
            
            spring.length = 1;
            spring.damping = .5;
            spring.frequency = .8;
            
            [_animator addBehavior:spring];
        }];
    }
}

-(BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView* scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    [_animator.behaviors enumerateObjectsUsingBlock:^(__kindof UIAttachmentBehavior * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewLayoutAttributes* attributes = (UICollectionViewLayoutAttributes*)[obj.items firstObject];
        
        CGPoint anchor = obj.anchorPoint;
        
        CGPoint center = attributes.center;
        CGPoint ptTouch = [scrollView.panGestureRecognizer locationInView:scrollView];
        
        CGFloat distance = ptTouch.y - anchor.y;
        CGFloat resistance = fabs(distance / 500);
        
        CGFloat offset = delta * resistance;
        offset = delta > 0 ? MIN(delta, offset) : MAX(delta, offset);
        
        center.y += offset;
        attributes.center = center;
        
        [_animator updateItemUsingCurrentState:attributes];
    
    }];
    
    return NO;
}


- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect // return an array layout attributes instances for all the views in the given rect
{
    return [_animator itemsInRect:rect];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_animator layoutAttributesForCellAtIndexPath:indexPath];
}


@end
