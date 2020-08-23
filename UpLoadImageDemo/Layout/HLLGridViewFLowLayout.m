//
//  HLLGridViewFLowLayout.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLGridViewFLowLayout.h"
#import "HLLMediaItemCell.h"
#import "UIView+Helper.h"


#define stringify   __STRING

static CGFloat const PRESS_TO_MOVE_MIN_DURATION = 0.1;
static CGFloat const MIN_PRESS_TO_BEGIN_EDITING_DURATION = 0.6;

//CoreGraphic 底层内联函数
CG_INLINE CGPoint CGPointOffset(CGPoint point, CGFloat dx, CGFloat dy)
{
    return CGPointMake(point.x + dx, point.y + dy);
}


@interface HLLGridViewFLowLayout()<UIGestureRecognizerDelegate>

//声明自定义代理,readonly 不允许更改
@property (nonatomic, strong, readonly) id<HLLGridViewDataSource> dataSource;
@property (nonatomic, strong, readonly) id<HLLGridViewDelegateFlowLayout> delegate;

@end


@implementation HLLGridViewFLowLayout
{
    UILongPressGestureRecognizer * _longPressGestureRecognizer;//拖拉
    UIPanGestureRecognizer * _panGestureRecognizer;//点击大图
    //支持拖拽
    NSIndexPath * _movingItemIndexPath;
    UIView *_beingMovedPromptView;
    CGPoint _sourceItemCollectionViewCellCenter;

    
    CADisplayLink * _displayLink;
    CFTimeInterval _remainSecondsToBeginEditing;
}


- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    //监听collectionView值
     [self addObserver:self forKeyPath:@stringify(collectionView) options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@stringify(collectionView)]) {
           if (self.collectionView) {
               [self addGestureRecognizers];
           }
           else {
               [self removeGestureRecognizers];
           }
       }
}

- (void)addGestureRecognizers{
    self.collectionView.userInteractionEnabled = YES;
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognizerTriggerd:)];
    _longPressGestureRecognizer.cancelsTouchesInView = NO;
    _longPressGestureRecognizer.minimumPressDuration = PRESS_TO_MOVE_MIN_DURATION;
    _longPressGestureRecognizer.delegate = self;
    
    for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
        }
    }
    
    //添加手势
    [self.collectionView addGestureRecognizer:_longPressGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerTriggerd:)];
    _panGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notificaiton
{
    _panGestureRecognizer.enabled = NO;
    _panGestureRecognizer.enabled = YES;
}


#pragma mark 移除所有监听手势
- (void)removeGestureRecognizers{
    if (_longPressGestureRecognizer) {
        if (_longPressGestureRecognizer.view) {
            [_longPressGestureRecognizer.view removeGestureRecognizer:_longPressGestureRecognizer];
        }
        _longPressGestureRecognizer = nil;
    }
    
    if (_panGestureRecognizer) {
        if (_panGestureRecognizer.view) {
            [_panGestureRecognizer.view removeGestureRecognizer:_panGestureRecognizer];
        }
        _panGestureRecognizer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}


- (void)setPanGestureRecognizerEnable:(BOOL)panGestureRecognizerEnable{
    _panGestureRecognizer.enabled = panGestureRecognizerEnable;
}

- (BOOL)panGestureRecognizerEnable{
    return _panGestureRecognizer.enabled;
}

#pragma mark 手势的点击方法响应
- (void)longPressGestureRecognizerTriggerd:(UILongPressGestureRecognizer *)longPress{
    switch (longPress.state) {
           case UIGestureRecognizerStatePossible:
               break;
           case UIGestureRecognizerStateBegan:
           {
               if (_displayLink == nil) {
                   _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTriggered:)];
                   _displayLink.frameInterval = 6;
                   [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                   
                   _remainSecondsToBeginEditing = MIN_PRESS_TO_BEGIN_EDITING_DURATION;
               }

               _movingItemIndexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
               if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)] && [self.dataSource collectionView:self.collectionView canMoveItemAtIndexPath:_movingItemIndexPath] == NO) {
                   _movingItemIndexPath = nil;
                   return;
               }
               
               if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                   [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:_movingItemIndexPath];
               }
               
               UICollectionViewCell *sourceCollectionViewCell = [self.collectionView cellForItemAtIndexPath:_movingItemIndexPath];
               HLLMediaItemCell *sourceCell = (HLLMediaItemCell *)sourceCollectionViewCell;
               
               _beingMovedPromptView = [[UIView alloc]initWithFrame:CGRectOffset(sourceCollectionViewCell.frame, -10, -10)];
               _beingMovedPromptView.al_width += 20;
               _beingMovedPromptView.al_height += 20;
               
//               highlightedSnapshotView 可有可无
               sourceCollectionViewCell.highlighted = YES;
               UIView * highlightedSnapshotView = [sourceCell snapshotView];
               highlightedSnapshotView.frame = _beingMovedPromptView.bounds;
               highlightedSnapshotView.alpha = 1;

               sourceCollectionViewCell.highlighted = NO;
               UIView * snapshotView = [sourceCell snapshotView];
               snapshotView.frame = _beingMovedPromptView.bounds;
               snapshotView.alpha = 0;
               
               [_beingMovedPromptView addSubview:snapshotView];
               [_beingMovedPromptView addSubview:highlightedSnapshotView];
               [self.collectionView addSubview:_beingMovedPromptView];

                _sourceItemCollectionViewCellCenter = sourceCollectionViewCell.center;
               
               typeof(self) __weak weakSelf = self;
               [UIView animateWithDuration:0
                                     delay:0
                                   options:UIViewAnimationOptionBeginFromCurrentState
                                animations:^{

                                    typeof(self) __strong strongSelf = weakSelf;
                                    if (strongSelf) {
                                        highlightedSnapshotView.alpha = 0;
                                        snapshotView.alpha = 1;
                                    }
                                }
                                completion:^(BOOL finished) {
                                    
                                    typeof(self) __strong strongSelf = weakSelf;
                                    if (strongSelf) {
                                        [highlightedSnapshotView removeFromSuperview];
                                        
                                        if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                                            [strongSelf.delegate collectionView:strongSelf.collectionView layout:strongSelf didBeginDraggingItemAtIndexPath:self->_movingItemIndexPath];
                                        }
                                    }
                                }];
                
               [self invalidateLayout];
           }
               break;
           case UIGestureRecognizerStateChanged:
               break;
           case UIGestureRecognizerStateEnded:
           case UIGestureRecognizerStateCancelled:
           {
               [_displayLink invalidate];
               _displayLink = nil;
               
               NSIndexPath * movingItemIndexPath = _movingItemIndexPath;
               
               if (movingItemIndexPath) {
                   if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                       [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:movingItemIndexPath];
                   }
                   
                   _movingItemIndexPath = nil;
                   _sourceItemCollectionViewCellCenter = CGPointZero;
                   
                   UICollectionViewLayoutAttributes * movingItemCollectionViewLayoutAttributes = [self layoutAttributesForItemAtIndexPath:movingItemIndexPath];
                   
                   _longPressGestureRecognizer.enabled = NO;
                   
                   typeof(self) __weak weakSelf = self;
                   [UIView animateWithDuration:0.2
                                         delay:0
                                       options:UIViewAnimationOptionBeginFromCurrentState
                                    animations:^{
                                        typeof(self) __strong strongSelf = weakSelf;
                                        if (strongSelf) {
                                            self->_beingMovedPromptView.center = movingItemCollectionViewLayoutAttributes.center;
                                        }
                                    }
                                    completion:^(BOOL finished) {

                                        self->_longPressGestureRecognizer.enabled = YES;
                                        
                                        typeof(self) __strong strongSelf = weakSelf;
                                        if (strongSelf) {
                                            [self->_beingMovedPromptView removeFromSuperview];
                                            self->_beingMovedPromptView = nil;
                                            [strongSelf invalidateLayout];
                                            
                                            if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
                                                [strongSelf.delegate collectionView:strongSelf.collectionView layout:strongSelf didEndDraggingItemAtIndexPath:movingItemIndexPath];
                                            }
                                        }
                                    }];
               }
           }
               break;
           case UIGestureRecognizerStateFailed:
               break;
           default:
               break;
       }
}

- (void)panGestureRecognizerTriggerd:(UIPanGestureRecognizer *)pan{
    switch (pan.state) {
           case UIGestureRecognizerStatePossible:
               break;
           case UIGestureRecognizerStateBegan:
           case UIGestureRecognizerStateChanged:
           {
               CGPoint panTranslation = [pan translationInView:self.collectionView];
               _beingMovedPromptView.center = CGPointOffset(_sourceItemCollectionViewCellCenter, panTranslation.x, panTranslation.y);
               
               NSIndexPath * sourceIndexPath = _movingItemIndexPath;
               NSIndexPath * destinationIndexPath = [self.collectionView indexPathForItemAtPoint:_beingMovedPromptView.center];
               
               if ((destinationIndexPath == nil) || [destinationIndexPath isEqual:sourceIndexPath]) {
                   return;
               }
               
               if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)] && [self.dataSource collectionView:self.collectionView itemAtIndexPath:sourceIndexPath canMoveToIndexPath:destinationIndexPath] == NO) {
                   return;
               }
               
               if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
                   [self.dataSource collectionView:self.collectionView itemAtIndexPath:sourceIndexPath willMoveToIndexPath:destinationIndexPath];
               }
               
               _movingItemIndexPath = destinationIndexPath;
               
               typeof(self) __weak weakSelf = self;
               [self.collectionView performBatchUpdates:^{
                   typeof(self) __strong strongSelf = weakSelf;
                   if (strongSelf) {
                       if (sourceIndexPath && destinationIndexPath) {
                           [strongSelf.collectionView deleteItemsAtIndexPaths:@[sourceIndexPath]];
                           [strongSelf.collectionView insertItemsAtIndexPaths:@[destinationIndexPath]];
                       }
                   }
               } completion:^(BOOL finished) {
                   typeof(self) __strong strongSelf = weakSelf;
                   if ([strongSelf.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
                       [strongSelf.dataSource collectionView:strongSelf.collectionView itemAtIndexPath:sourceIndexPath didMoveToIndexPath:destinationIndexPath];
                   }
               }];
           }
               break;
           case UIGestureRecognizerStateEnded:
               break;
           case UIGestureRecognizerStateCancelled:
               break;
           case UIGestureRecognizerStateFailed:
               break;
           default:
               break;
       }
}


- (id<HLLGridViewDataSource>)dataSource{
    return (id<HLLGridViewDataSource>)self.collectionView.dataSource;
}

- (id<HLLGridViewDelegateFlowLayout>)delegate{
    return (id<HLLGridViewDelegateFlowLayout>)self.collectionView.delegate;
}




#pragma mark - 重写UICollectionViewLayout methods
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
   NSArray * layoutAttributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes * layoutAttributes in layoutAttributesForElementsInRect) {
        
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
             //是为了响应拖拽过程中snapView在滚动的时候，origin cell应该要隐藏
            layoutAttributes.hidden = [layoutAttributes.indexPath isEqual:_movingItemIndexPath];
        }
    }
    return layoutAttributesForElementsInRect;

}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes * layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        //是为了响应拖拽过程中snapView在滚动的时候，origin cell应该要隐藏
        layoutAttributes.hidden = [layoutAttributes.indexPath isEqual:_movingItemIndexPath];
    }
    return layoutAttributes;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_panGestureRecognizer isEqual:gestureRecognizer]) {
        return _movingItemIndexPath != nil;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //  only _longPressGestureRecognizer and _panGestureRecognizer can recognize simultaneously
    if ([_longPressGestureRecognizer isEqual:gestureRecognizer]) {
        return [_panGestureRecognizer isEqual:otherGestureRecognizer];
    }
    if ([_panGestureRecognizer isEqual:gestureRecognizer]) {
        return [_longPressGestureRecognizer isEqual:otherGestureRecognizer];
    }
    return NO;
}

#pragma mark - displayLink

- (void)displayLinkTriggered:(CADisplayLink *)displayLink
{
    if (_remainSecondsToBeginEditing <= 0) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    _remainSecondsToBeginEditing = _remainSecondsToBeginEditing - 0.1;
}


- (void)dealloc{
    //停止定时器
    [_displayLink invalidate];
    [self removeObserver:self forKeyPath:@stringify(collectionView)];
}

@end
