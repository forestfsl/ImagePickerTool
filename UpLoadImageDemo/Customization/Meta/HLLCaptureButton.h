//
//  HLLCaptureButton.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HLLCaptureButtonMode) {
    HLLCaptureButtonModePhoto = 0, // default
    HLLCaptureButtonModeVideo = 1
};

NS_ASSUME_NONNULL_BEGIN

@interface HLLCaptureButton : UIButton

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(HLLCaptureButtonMode)captureButtonMode;

@property (nonatomic) HLLCaptureButtonMode captureButtonMode;

@end

NS_ASSUME_NONNULL_END
