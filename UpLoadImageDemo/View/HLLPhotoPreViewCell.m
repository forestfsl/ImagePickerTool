//
//  HLLPhotoPreViewCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLPhotoPreViewCell.h"
#import "HLLPhotoPreviewView.h"
#import "HLLAssetModel.h"

@implementation HLLPhotoPreViewCell

- (void)configSubviews{
    self.previewView = [[HLLPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.previewView setSingleTapGestureBlock:^{
       __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.singleTapGestureBlock) {
            strongSelf.singleTapGestureBlock();
        }
    }];
    
    [self.previewView setImageProgressUpdateBlock:^(double progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.imageProgressUpdateBlock) {
            strongSelf.imageProgressUpdateBlock(progress);
        }
    }];
    [self addSubview:self.previewView];
}

- (void)setModel:(HLLAssetModel *)model{
    [super setModel:model];
    _previewView.model = model;
}

- (void)recoverSubviews{
    [_previewView recoverSubViews];
}

- (void)setAllowCrop:(BOOL)allowCrop{
    _allowCrop = allowCrop;
    _previewView.allowCrop = allowCrop;
}

- (void)setScaleAspectFillCrop:(BOOL)scaleAspectFillCrop{
    _scaleAspectFillCrop = scaleAspectFillCrop;
    _previewView.scaleAspectFillCrop = scaleAspectFillCrop;
}

- (void)setCropRect:(CGRect)cropRect{
    _cropRect = cropRect;
    _previewView.cropRect = cropRect;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

@end
