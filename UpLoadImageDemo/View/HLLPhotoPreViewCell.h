//
//  HLLPhotoPreViewCell.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLAssetPreviewCell.h"


@class HLLAssetModel,HLLProgressView,HLLPhotoPreviewView;

@interface HLLPhotoPreViewCell : HLAssetPreviewCell

@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
@property (nonatomic, strong) HLLPhotoPreviewView *previewView;
@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) BOOL scaleAspectFillCrop;

- (void)recoverSubviews;

@end


