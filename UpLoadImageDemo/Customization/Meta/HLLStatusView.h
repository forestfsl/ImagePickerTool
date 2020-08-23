//
//  HLLStatusView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLLFlashControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLLStatusView : UIView<HLLFlashControlDelegate>

@property (strong, nonatomic) HLLFlashControl *flashControl;
@property (strong, nonatomic) UILabel *elapsedTimeLabel;

@end

NS_ASSUME_NONNULL_END
