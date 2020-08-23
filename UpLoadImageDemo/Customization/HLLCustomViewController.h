//
//  HLLCustomViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/19.
//  Copyright © 2020 com.forest. All rights reserved.
//


/**
 支持简单的可定制照相机
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface HLLCustomViewController : UIViewController

@property (nonatomic, assign) CGFloat maxCount;
@property (nonatomic, assign) CGFloat columnNumber;
@property (nonatomic, strong) id target;

- (instancetype)initCustomVCWithTarget:(UIViewController *)targetVC;

@end

NS_ASSUME_NONNULL_END
