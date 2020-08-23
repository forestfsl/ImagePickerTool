//
//  HLLMediaItemCell.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLLRoundProgressView.h"


typedef void(^MediaDataUpload)(id _Nullable asset);

NS_ASSUME_NONNULL_BEGIN

@interface HLLMediaItemCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageV;//图片
@property (nonatomic, strong) UIImageView *videoImageV;//视屏
@property (nonatomic, strong) UIButton *deleteBtn;//删除按钮
@property (nonatomic, strong) UILabel *gifL;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) id asset;
@property (nonatomic, strong) UIButton *failureBtn;//失败图标
@property (nonatomic, strong) UIButton *retryUploadBtn;
@property (nonatomic, copy) MediaDataUpload dataUpLoadBlock;
@property (nonatomic, strong) HLLRoundProgressView *progressView;
@property (nonatomic, assign) BOOL isUploadSuccess;

- (UIView *)snapshotView;

@end

NS_ASSUME_NONNULL_END
