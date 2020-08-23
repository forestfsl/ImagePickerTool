//
//  HLLCameraView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLLOverlayView.h"
#import "HLLPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLLCameraView : UIView

@property (weak, nonatomic, readonly) HLLPreviewView *previewView;
@property (weak, nonatomic, readonly) HLLOverlayView *controlsView;

@end

NS_ASSUME_NONNULL_END
