//
//  HLLFlashControl.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HLLFlashControl;

@protocol HLLFlashControlDelegate <NSObject>

@optional
- (void)flashControlWillExpand;
- (void)flashControlDidExpand;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLLFlashControl : UIControl

@property (nonatomic) NSInteger selectedMode;
@property (weak, nonatomic) id<HLLFlashControlDelegate> delegate;

@end




NS_ASSUME_NONNULL_END
