//
//  HLLMediaItemCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLMediaItemCell.h"
#import "UIView+Helper.h"
#import "NSBundle+Helper.h"
#import "UIImage+Helper.h"
#import <Photos/Photos.h>


@implementation HLLMediaItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubView];
    }
    return self;
}

- (void)setupSubView{
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    [self addSubview:self.imageV];
    [self addSubview:self.videoImageV];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.gifL];
    [self addSubview:self.failureBtn];
    [self addSubview:self.retryUploadBtn];
    [self addSubview:self.progressView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageV.frame = self.bounds;
    self.gifL.frame = CGRectMake(self.al_width - 25, self.al_height - 14, 25, 14);
    self.deleteBtn.frame = CGRectMake(self.al_width - 36, 0, 36, 36);
    CGFloat width = self.al_width / 3.0;
    self.failureBtn.frame = CGRectMake(self.al_width - 36, 0, 36, 36);
    self.retryUploadBtn.frame = CGRectMake((self.al_width - 100) / 2, (self.al_height - 40) / 2, 100, 40);
    _videoImageV.frame = CGRectMake(width, width, width, width);
}

- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    //视频是显示还是隐藏
    _videoImageV.hidden = asset.mediaType != PHAssetMediaTypeVideo;
    _gifL.hidden = ![[asset valueForKey:@"filename"] containsString:@"GIF"];
}

-(void)setRow:(NSInteger)row{
    _row = row;
    _deleteBtn.tag = row;//记录删除标志
}


- (void)setIsUploadSuccess:(BOOL)isUploadSuccess{
    _isUploadSuccess = isUploadSuccess;
    if (isUploadSuccess) {//如果上传成功
        self.failureBtn.hidden = YES;
        self.retryUploadBtn.hidden = YES;
        self.progressView.hidden = YES;
        
    }else{
        self.failureBtn.hidden = NO;
        self.retryUploadBtn.hidden = NO;
        self.deleteBtn.hidden = YES;
        self.progressView.hidden = YES;
    }
}


#pragma mark - mark getter

- (UIView *)snapshotView{
    UIView *snapshotView = [[UIView alloc]init];
    
    UIView *cellSnapshotView = nil;
    
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        cellSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
    } else {
        CGSize size = CGSizeMake(self.bounds.size.width + 20, self.bounds.size.height + 20);
        UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cellSnapshotView = [[UIImageView alloc]initWithImage:cellSnapshotImage];
    }
    
    snapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    cellSnapshotView.frame = CGRectMake(0, 0, cellSnapshotView.frame.size.width, cellSnapshotView.frame.size.height);
    
    [snapshotView addSubview:cellSnapshotView];
    return snapshotView;
}

- (UIImageView *)imageV {
    if (!_imageV) {
        _imageV = [[UIImageView alloc]init];
        _imageV.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageV;
}


- (UIImageView *)videoImageV{
    if (!_videoImageV) {
        _videoImageV = [[UIImageView alloc]init];
        _videoImageV.image = [UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlay"];
        _videoImageV.contentMode = UIViewContentModeScaleAspectFill;
        _videoImageV.hidden = YES;//默认先隐藏
    }
    return _videoImageV;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        _deleteBtn.alpha = 0.6;
    }
    return _deleteBtn;
}

- (UILabel *)gifL{
    if (!_gifL) {
        _gifL = [[UILabel alloc]init];
        _gifL.text = @"GIF";
        _gifL.textColor = [UIColor whiteColor];
        _gifL.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _gifL.textAlignment = NSTextAlignmentCenter;
        _gifL.font = [UIFont systemFontOfSize:10];
    }
    return _gifL;
}


- (UIButton *)failureBtn{
    if (!_failureBtn) {
        _failureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_failureBtn setImage:[UIImage imageNamed:@"AlbumAddBtn"] forState:UIControlStateNormal];
//        _failureBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        [_failureBtn addTarget:self action:@selector(retryUploadMedia) forControlEvents:UIControlEventTouchUpInside];
        _failureBtn.hidden = YES;
    }
    return _failureBtn;
}

- (UIButton *)retryUploadBtn{
    if (!_retryUploadBtn) {
        _retryUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryUploadBtn addTarget:self action:@selector(retryUploadMedia) forControlEvents:UIControlEventTouchUpInside];
        [_retryUploadBtn setTitle:@"重新上传" forState:UIControlStateNormal];
        [_retryUploadBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_retryUploadBtn setBackgroundColor:[UIColor grayColor]];
        _retryUploadBtn.layer.cornerRadius = 10;
        _retryUploadBtn.layer.masksToBounds = YES;
//        _retryUploadBtn.hidden = YES;
    }
    return _retryUploadBtn;
}

- (HLLRoundProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[HLLRoundProgressView alloc]initWithFrame:CGRectMake((self.al_width - 40) / 2, (self.al_height - 40) / 2, 40, 40)];
        _progressView.backgroundColor = [UIColor yellowColor];
        [_progressView setProgressColor:[UIColor blueColor]];
        _progressView.lineDashPattern = @[@(8),@(5)];
//        _progressView.progressFont = [UIFont systemFontOfSize:70];
        _progressView.hidden = YES;
    }
    return _progressView;
}


//失败重传
- (void)retryUploadMedia{
    if (self.dataUpLoadBlock) {
        self.dataUpLoadBlock(self.asset);
    }
    
}

@end
