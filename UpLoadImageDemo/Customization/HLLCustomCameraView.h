//
//  HLLCustomCameraView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HLLCustomCameraViewDelegate <NSObject>

@optional

//点击返回按钮
- (void)didClikBackAction;

//点击拍照
- (void)didClickTakePhoto;

//点击进入相册
- (void)didClickPhotoLibrary;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLLCustomCameraView : UIView

@property (nonatomic, weak) id<HLLCustomCameraViewDelegate> delegate;

@property (nonatomic, assign) UIDeviceOrientation currentOrientation;

@end

NS_ASSUME_NONNULL_END
