//
//  HLLAssetCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLAssetCell.h"
#import "HLLTemplatePickerViewController.h"
#import "HLLProgressView.h"
#import "UIView+Helper.h"
#import "HLLCommonTools.h"
#import "UIImage+Helper.h"

@interface HLLAssetCell ()

//照片
@property (nonatomic, strong) UIImageView *imageView;
//选中时候右上角的图形
@property (nonatomic, strong) UIImageView *selectImageView;
//显示选中数字
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIView *bottomView;
//视频显示时间
@property (nonatomic, strong) UILabel *timeLength;
//点击手势添加
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
//视频左下角的摄像机图片
@property (nonatomic, strong) UIImageView *videoImgView;
//icloud 加载图片时候显示
@property (nonatomic, strong) HLLProgressView *progressView;
@property (nonatomic, assign) int32_t bigImageRequestID;

@end

@implementation HLLAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"PHOTO_PICKER_RELOAD_NOTIFICATION" object:nil];
    return self;
}


- (void)setModel:(HLLAssetModel *)model{
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[HLLImageManager manager] fetchPhotoWithAsset:model.asset photoWidth:self.al_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
            [self setNeedsLayout];
        }else{
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            [self hideProgressView];
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoBtn.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoBtn.isSelected ? self.photoSelImage : self.photoDefImage;
    self.indexLabel.hidden = !self.selectPhotoBtn.isSelected;
    self.type = model.type;
    //宽度高度小于可选照片尺寸的图片不能选中
    if (![[HLLImageManager manager] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            _selectImageView.hidden = YES;
        }
    }
    //如果用户选中了该图片，提前获取大图
    if (model.isSelected) {
        [self requestBigImage];
    }else{
        [self cancelBigImageRequest];
    }
}

- (void)requestBigImage {
    
    if (_bigImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
    
    _bigImageRequestID = [[HLLImageManager manager] requestImageDataForAsset:_model.asset completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        BOOL iCloudSyncFailed = !imageData && [HLLCommonTools isICloudSyncError:info[PHImageErrorKey]];
        self.model.iCloudFailed = iCloudSyncFailed;
        if (iCloudSyncFailed && self.didSelectPhotoBlock) {
            self.didSelectPhotoBlock(YES);
            self.selectImageView.image = self.photoDefImage;
        }
        [self hideProgressView];
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (self.model.isSelected) {
            progress = progress > 0.02 ? progress : 0.02;
            self.progressView.progress = progress;
            self.progressView.hidden = NO;
            self.imageView.alpha = 0.4;
            if (progress >= 1) {
                [self hideProgressView];
            }
        }else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self cancelBigImageRequest];
        }
    }];
    if (_model.type == HLLAssetCellTypeVideo) {
        [[HLLImageManager manager] fetchVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            BOOL iCloudSyncFailed = !playerItem && [HLLCommonTools isICloudSyncError:info[PHImageErrorKey]];
            self.model.iCloudFailed = iCloudSyncFailed;
            if (iCloudSyncFailed && self.didSelectPhotoBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.didSelectPhotoBlock(YES);
                    self.selectImageView.image = self.photoDefImage;
                });
            }
        }];
    }
}

- (void)cancelBigImageRequest {
    if (_bigImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
    [self hideProgressView];
}

- (void)hideProgressView {
    if (_progressView) {
        self.progressView.hidden = YES;
        self.imageView.alpha = 1.0;
    }
}

- (void)reload:(NSNotification *)noti{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)noti.object;
    UIViewController *parentVC = nil;
    //通过响应链查找
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            parentVC = (UIViewController *)responder;
            break;//在做AI项目的时候，也有一个使用响应链寻找视图的过程，也是因为遍历到了，忘记break，导致后面一个隐藏的bug在iOS9机器上面显示，其他机器没有
        }
        responder = responder.nextResponder;
    } while (responder);
    
    if (parentVC.navigationController != pickerVC) {
        return;
    }
    if (self.model.isSelected && pickerVC.showSelectedIndex) {
        self.index = [pickerVC.selectedAssetIds indexOfObject:self.model.asset.localIdentifier] + 1;
    }
    self.indexLabel.hidden = !self.selectPhotoBtn.isSelected;
    if (pickerVC.selectedModels.count >= pickerVC.maxImagesCount && pickerVC.showPhotoCannotSelectLayer && !self.model.isSelected) {
        self.cannotSelectLayerButton.backgroundColor = pickerVC.cannotSelectLayerColor;
        self.cannotSelectLayerButton.hidden = NO;
    }else{
        self.cannotSelectLayerButton.hidden = YES;
    }
}


- (void)setIndex:(NSInteger)index {
    _index = index;
    self.indexLabel.text = [NSString stringWithFormat:@"%zd", index];
    [self.contentView bringSubviewToFront:self.indexLabel];
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    BOOL selectable = [[HLLImageManager manager] isPhotoSelectableWithAsset:self.model.asset];
    if (!self.selectPhotoBtn.hidden) {
        self.selectPhotoBtn.hidden = !showSelectBtn || !selectable;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn || !selectable;
    }
}

- (void)setType:(HLLAssetCellType)type {
    _type = type;
    if (type == HLLAssetCellTypePhoto || type == HLLAssetCellTypeLivePhoto || (type == HLLAssetCellTypePhotoGif && !self.allowPickingGif) || self.allowPickingMultipleVideo) {
        _selectImageView.hidden = NO;
        _selectPhotoBtn.hidden = NO;
        _bottomView.hidden = YES;
    } else { // Video of Gif
        _selectImageView.hidden = YES;
        _selectPhotoBtn.hidden = YES;
    }
    
    if (type == HLLAssetCellTypeVideo) {
        self.bottomView.hidden = NO;
        self.timeLength.text = _model.timeLength;
        self.videoImgView.hidden = NO;
        _timeLength.al_x = self.videoImgView.al_maxX;
        _timeLength.textAlignment = NSTextAlignmentRight;
    } else if (type == HLLAssetCellTypePhotoGif && self.allowPickingGif) {
        self.bottomView.hidden = NO;
        self.timeLength.text = @"GIF";
        self.videoImgView.hidden = YES;
        _timeLength.al_x = 5;
        _timeLength.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)setAllowPreview:(BOOL)allowPreview {
    _allowPreview = allowPreview;
    if (allowPreview) {
        _imageView.userInteractionEnabled = NO;
        _tapGesture.enabled = NO;
    } else {
        _imageView.userInteractionEnabled = YES;
        _tapGesture.enabled = YES;
    }
}

- (UIButton *)selectPhotoBtn{
    if (!_selectPhotoBtn) {
        _selectPhotoBtn = [[UIButton alloc]init];
        [_selectPhotoBtn addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectPhotoBtn];
    }
    return _selectPhotoBtn;
}

- (void)selectPhotoButtonClick:(UIButton *)sender{
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? self.photoSelImage : self.photoDefImage;
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:HLLscillatoryAnimationToBigger];
        // 用户选中了该图片，提前获取一下大图
        [self requestBigImage];
    }else{
        [self cancelBigImageRequest];
    }
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImageView)];
        [_imageView addGestureRecognizer:_tapGesture];
    }
    return _imageView;
}

/// 只在单选状态且allowPreview为NO时会有该事件
- (void)didTapImageView {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(NO);
    }
}


- (UIImageView *)selectImageView{
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.clipsToBounds = YES;
        _selectImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_selectImageView];
    }
    return _selectImageView;
}


- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        static NSInteger rgb = 0;
        bottomView.userInteractionEnabled = NO;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIButton *)cannotSelectLayerButton {
    if (_cannotSelectLayerButton == nil) {
        UIButton *cannotSelectLayerButton = [[UIButton alloc] init];
        [self.contentView addSubview:cannotSelectLayerButton];
        _cannotSelectLayerButton = cannotSelectLayerButton;
    }
    return _cannotSelectLayerButton;
}

- (UIImageView *)videoImgView {
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        [videoImgView setImage:[UIImage hll_imageNamedFromBundle:@"VideoSendIcon"]];
        [self.bottomView addSubview:videoImgView];
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

- (UILabel *)indexLabel {
    if (_indexLabel == nil) {
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.font = [UIFont systemFontOfSize:14];
        indexLabel.adjustsFontSizeToFitWidth = YES;
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:indexLabel];
        _indexLabel = indexLabel;
    }
    return _indexLabel;
}

- (HLLProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[HLLProgressView alloc] init];
        _progressView.hidden = YES;
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _cannotSelectLayerButton.frame = self.bounds;
    if (self.allowPreview) {
        _selectPhotoBtn.frame = CGRectMake(self.al_width - 44, 0, 44, 44);
    } else {
        _selectPhotoBtn.frame = self.bounds;
    }
    _selectImageView.frame = CGRectMake(self.al_width - 27, 3, 24, 24);
    if (_selectImageView.image.size.width <= 27) {
        _selectImageView.contentMode = UIViewContentModeCenter;
    } else {
        _selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    _indexLabel.frame = _selectImageView.frame;
    _imageView.frame = self.bounds;

    static CGFloat progressWH = 20;
    CGFloat progressXY = (self.al_width - progressWH) / 2;
    _progressView.frame = CGRectMake(progressXY, progressXY, progressWH, progressWH);

    _bottomView.frame = CGRectMake(0, self.al_height - 17, self.al_height, 17);
    _videoImgView.frame = CGRectMake(8, 0, 17, 17);
    _timeLength.frame = CGRectMake(self.videoImgView.al_maxX, 0, self.al_width - self.videoImgView.al_maxX - 5, 17);
    
    self.type = (NSInteger)self.model.type;
    self.showSelectBtn = self.showSelectBtn;
    
    [self.contentView bringSubviewToFront:_bottomView];
    [self.contentView bringSubviewToFront:_cannotSelectLayerButton];
    [self.contentView bringSubviewToFront:_selectPhotoBtn];
    [self.contentView bringSubviewToFront:_selectImageView];
    [self.contentView bringSubviewToFront:_indexLabel];
    
    if (self.assetCellDidLayoutSubviewsBlock) {
        self.assetCellDidLayoutSubviewsBlock(self, _imageView, _selectImageView, _indexLabel, _bottomView, _timeLength, _videoImgView);
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
