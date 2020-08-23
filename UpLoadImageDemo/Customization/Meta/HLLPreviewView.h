//
//  HLLPreviewView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol HLLPreviewViewDelegate <NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;//聚焦
- (void)tappedToExposeAtPoint:(CGPoint)point;//曝光
- (void)tappedToResetFocusAndExposure;//点击重置聚焦&曝光
@end

NS_ASSUME_NONNULL_BEGIN

@interface HLLPreviewView : UIView

//session用来关联AVCaptureVideoPreviewLayer 和 激活AVCaptureSession
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) id<HLLPreviewViewDelegate> delegate;

@property (nonatomic) BOOL tapToFocusEnabled; //是否聚焦
@property (nonatomic) BOOL tapToExposeEnabled; //是否曝光

@end

NS_ASSUME_NONNULL_END
