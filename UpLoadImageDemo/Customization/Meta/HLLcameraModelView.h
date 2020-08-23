//
//  HLLcameraModelView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HLLCameraMode) {
    THCameraModePhoto = 0, // default
    THCameraModeVideo = 1
};

NS_ASSUME_NONNULL_BEGIN

@interface HLLcameraModelView : UIControl

@property (nonatomic) HLLCameraMode cameraMode;

@end

NS_ASSUME_NONNULL_END
