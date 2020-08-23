//
//  HLLGifPreviewCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLGifPreviewCell.h"
#import "HLLPhotoPreviewView.h"
#import "HLLAssetModel.h"

@implementation HLLGifPreviewCell

- (void)configSubviews {
    [self configPreviewView];
}

- (void)configPreviewView {
    self.previewView = [[HLLPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf signleTapAction];
    }];
    [self addSubview:self.previewView];
}

- (void)setModel:(HLLAssetModel *)model {
    [super setModel:model];
    self.previewView.model = self.model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

#pragma mark - Click Event

- (void)signleTapAction {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

@end
