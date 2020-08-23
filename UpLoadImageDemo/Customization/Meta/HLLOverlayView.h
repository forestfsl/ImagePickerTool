//
//  HLLOverlayView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLLcameraModelView.h"
#import "HLLStatusView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLLOverlayView : UIView

@property (strong, nonatomic)  HLLcameraModelView *modeView;
@property (strong, nonatomic)  HLLStatusView *statusView;

@property (nonatomic) BOOL flashControlHidden;

@end

NS_ASSUME_NONNULL_END
