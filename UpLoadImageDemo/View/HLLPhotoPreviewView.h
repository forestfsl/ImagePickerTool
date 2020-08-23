//
//  HLLPhotoPreviewView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//


//图片预览

#import <UIKit/UIKit.h>


@class HLLProgressView,HLLAssetModel;

@interface HLLPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
//滑动
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) HLLProgressView *progressView;
@property (nonatomic, strong) UIImageView *iCloudErrorIcon;
@property (nonatomic, strong) UILabel *iCloudErrorLabel;
@property (nonatomic, copy) void (^iCloudSyncFailedHandle)(id asset,BOOL isSyncFailed);

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) BOOL scaleAspectFillCrop;
@property (nonatomic, strong) HLLAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double pregress);
@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubViews;

@end


