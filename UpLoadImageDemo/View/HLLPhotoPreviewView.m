//
//  HLLPhotoPreviewView.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLPhotoPreviewView.h"
#import "UIImage+Helper.h"
#import "HLLProgressView.h"
#import "UIView+Helper.h"
#import "HLLAssetModel.h"
#import "HLLImageManager.h"
#import "HLLCommonTools.h"

@interface HLLPhotoPreviewView()<UIScrollViewDelegate>

@property (assign, nonatomic) BOOL isRequestingGIF;
@property (nonatomic, assign) CGRect imageContainerRect;

@end

@implementation HLLPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubView];
    }
    
    return self;
}

- (void)setupSubView{
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageContainerView];
    [self.imageContainerView addSubview:self.imageView];
    [self addSubview:self.iCloudErrorIcon];
    [self addSubview:self.iCloudErrorLabel];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
    [self addSubview:self.progressView];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(10, 0, self.al_width - 20, self.al_height);
    static CGFloat progressWH = 40;
    CGFloat progressX = (self.al_width - progressWH) / 2;
    CGFloat progressY = (self.al_height - progressWH) / 2;
    self.progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    [self recoverSubViews];
    self.iCloudErrorIcon.frame = CGRectMake(20, [HLLCommonTools hll_isIPhoneX] ? 88 + 10 : 64 + 10, 28, 28);
    self.iCloudErrorLabel.frame = CGRectMake(53, [HLLCommonTools hll_isIPhoneX] ? 88 + 10 : 64 + 10, self.al_width - 63, 28);
}

#pragma mark - UITapGestureRecognizer Event

- (void)singleTap:(UITapGestureRecognizer *)tap{
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}



///两次点击的时候放大图片
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }else{
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}


///需要实现以下UIScrollViewDelegate 代理方法方可实现缩放和扩大
#pragma mark - UIScrollViewDelegate

/// 返回缩放视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageContainerView;
}



- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self refreshImageContainerViewCenter];
}


/**
 https://www.jianshu.com/p/3dfb0e409eb1
 scrollView 这里需要响应双击或者其他轻击手势之类的触摸事件放大，所以这里需要使用到了setZoomScale:animated 和 zoomToRect:animated 方法
 - setZoomScale:animated:通过设置当前缩放比例为指定的值来缩放。该值必须是在minimumZoomScale和maximumZoomScale范围内。animated指定是否有动画
 - zoomToRect:animated:Zooms to a specific area of the content so that it is visible in the receiver.
 rect:A rectangle defining an area of the content view. The rectangle should be in the coordinate space of the view returned by viewForZoomingInScrollView:.
 定义内容视图区域的矩形。 矩形应该位于viewForZoomingInScrollView：返回的视图的坐标空间中
 animated:YES if the scrolling should be animated, NO if it should be immediate.
 animated参数决定了位置和缩放的变化是否会导致动画发生
 
 官方提供示例
  该方法返回的矩形适合传递给zoomToRect:animated:方法。

  @param scrollView UIScrollView实例
  @param scale 新的缩放比例（通常zoomScale通过添加或乘以缩放量而从现有的缩放比例派生而来)
  @param center 放大缩小的中心点
  @return zoomRect 是以内容视图为坐标系

 - (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
  
     CGRect zoomRect;
  
     // The zoom rect is in the content view's coordinates.
     // At a zoom scale of 1.0, it would be the size of the
     // imageScrollView's bounds.
     // As the zoom scale decreases, so more content is visible,
     // the size of the rect grows.
     zoomRect.size.height = scrollView.frame.size.height / scale;
     zoomRect.size.width  = scrollView.frame.size.width  / scale;
  
     // choose an origin so as to get the right center.
     zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
     zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
  
     return zoomRect;
 }

当用户完成缩放手势或通过代码完成缩放时，会触发scrollViewDidEndZooming:withView:atScale:代理事件
 */

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {

    [self refreshScrollViewContentSize];
}




#pragma mark - 私有方法
- (void)refreshImageContainerViewCenter{
//    if (self.scrollView.zoomScale >= 2.5) {
//        self.imageContainerView.frame = self.imageContainerRect;
//        CGFloat offsetX = (self.scrollView.al_width > self.scrollView.contentSize.width) ? ((self.scrollView.al_width - self.scrollView.contentSize.width) * 0.5) : 0.0;
//          CGFloat offsetY = (self.scrollView.al_height > self.scrollView.contentSize.height) ? ((self.scrollView.al_height - self.scrollView.contentSize.height) * 0.5) : 0.0;
//          self.imageContainerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
//    }else{
//            self.imageContainerView.frame = self.cropRect;
//    }
    self.imageContainerView.frame = self.imageContainerRect;
    CGFloat offsetX = (self.scrollView.al_width > self.scrollView.contentSize.width) ? ((self.scrollView.al_width - self.scrollView.contentSize.width) * 0.5) : 0.0;
      CGFloat offsetY = (self.scrollView.al_height > self.scrollView.contentSize.height) ? ((self.scrollView.al_height - self.scrollView.contentSize.height) * 0.5) : 0.0;
      self.imageContainerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);

}

- (void)refreshScrollViewContentSize{
    if (self.allowCrop) {
        //如果要让图片的任意部分都能在裁剪框内，需要对scrollView 做了如下处理
        //让contentSize增大
        CGFloat contentWidthAdd = self.scrollView.al_width - CGRectGetMaxX(self.cropRect);
        CGFloat contentHeightAdd = (MIN(_imageContainerView.al_height, self.al_height) - self.cropRect.size.height) / 2;
        CGFloat newSizeW = self.scrollView.contentSize.width + contentWidthAdd;
        CGFloat newSizeH = MAX(self.scrollView.contentSize.height, self.al_height) + contentHeightAdd;
        self.scrollView.contentSize = CGSizeMake(newSizeW, newSizeH);
        self.scrollView.alwaysBounceVertical = YES;
        //新增滑动区域
        if (contentHeightAdd > 0 || contentWidthAdd > 0) {
            self.scrollView.contentInset = UIEdgeInsetsMake(contentHeightAdd, self.cropRect.origin.x, 0, 0  );
        }else{
            self.scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
    
}



- (void)setModel:(HLLAssetModel *)model{
    _model = model;
    self.isRequestingGIF = NO;
    [self.scrollView setZoomScale:1.0 animated:NO];
    if (model.type == HLLAssetModelMediaTypePhotoGif) {
        //先显示缩略图
        [[HLLImageManager manager] fetchPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (photo) {
                self.imageView.image = photo;
                
            }
            [self resizeSubviews];
            if (self.isRequestingGIF) {
                return;
                
            }

            // 再显示gif动图
            self.isRequestingGIF = YES;
            [[HLLImageManager manager] fetchOriginalPhotoDataWithAsset:model.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                progress = progress > 0.02 ? progress : 0.02;
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL iCloudSyncFailed = [HLLCommonTools isICloudSyncError:error];
                    self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
                    self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
                    if (self.iCloudSyncFailedHandle) {
                        self.iCloudSyncFailedHandle(model.asset, iCloudSyncFailed);
                    }
                    
                    self.progressView.progress = progress;
                    if (progress >= 1) {
                        self.progressView.hidden = YES;
                    } else {
                        self.progressView.hidden = NO;
                    }
                });

            } completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    self.isRequestingGIF = NO;
                    self.progressView.hidden = YES;
                    if ([HLLImagePickerConfig sharedInstance].gifImagePlayBolck) {
                        [HLLImagePickerConfig sharedInstance].gifImagePlayBolck(self, self.imageView, data, info);
                    }else{
                        self.imageView.image = [UIImage hll_animatedGIFWithData:data];
                    }
                    [self resizeSubviews];
                }
            }];
        } progressHandler:nil networkAccessAllowed:NO];
    }else{
        self.asset = model.asset;
    }
}

- (void)setAsset:(PHAsset *)asset{
    if (_asset && self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    _asset = asset;
    self.imageRequestID = [[HLLImageManager manager] fetchPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        BOOL iCloudSyncFailed = !photo && [HLLCommonTools isICloudSyncError:info[PHImageErrorKey]];
        self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
        self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
        if (self.iCloudSyncFailedHandle) {
            self.iCloudSyncFailedHandle(asset, iCloudSyncFailed);
        }
        //破解死循环
        if (![asset isEqual:self->_asset]) {
            return ;
        }
        
        if (photo) {
            self.imageView.image = photo;
        }
        [self resizeSubviews];
        if (self.imageView.al_height && self.allowCrop) {
            CGFloat scale = MAX(self.cropRect.size.width / self.imageView.al_width, self.cropRect.size.height / self.imageView.al_height);
            if (self.scaleAspectFillCrop && scale > 1) {
                //如果设置图片缩放裁剪并且图片需要缩放
                CGFloat multiple = self.scrollView.maximumZoomScale / self.scrollView.minimumZoomScale;
                self.scrollView.minimumZoomScale = scale;
                self.scrollView.maximumZoomScale = scale * MAX(multiple, 2);
                [self.scrollView setZoomScale:scale animated:YES];
            }
        }
        self.progressView.hidden = YES;
        if (self.imageProgressUpdateBlock) {
            self.imageProgressUpdateBlock(1);
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (![asset isEqual:self->_asset]) {
            return ;
        }
        self->_progressView.hidden = NO;
        [self bringSubviewToFront:self->_progressView];
        progress = progress > 0.02 ? progress : 0.02;
        self->_progressView.progress = progress;
        if (self.imageProgressUpdateBlock && progress < 1) {
            self.imageProgressUpdateBlock(progress);
        }
        if (progress >= 1) {
            self->_progressView.hidden = YES;
            self.imageRequestID = 0;
        }
    } networkAccessAllowed:YES];
    [self configMaxinumZoomScale];
}

- (void)configMaxinumZoomScale{
    
    self.scrollView.maximumZoomScale = self.allowCrop ? 4.0 : 2.5;
    if ([self.asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)self.asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        if (aspectRatio > 1.5) {
            self.scrollView.maximumZoomScale *= aspectRatio / 1.5;
        }
    }
}

- (void)recoverSubViews{
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
  self.imageContainerView.al_origin = CGPointZero;
  self.imageContainerView.al_width = self.scrollView.al_width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.al_height / self.scrollView.al_width) {
      self.imageContainerView.al_height = floor(image.size.height / (image.size.width / self.scrollView.al_width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.al_width;
        if (height < 1 || isnan(height)) height = self.al_height;
        height = floor(height);
      self.imageContainerView.al_height = height;
      self.imageContainerView.al_centerY = self.al_height / 2;
    }
    if (_imageContainerView.al_height > self.al_height && _imageContainerView.al_height - self.al_height <= 1) {
      self.imageContainerView.al_height = self.al_height;
    }
    CGFloat contentSizeH = MAX(_imageContainerView.al_height, self.al_height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.al_width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.al_height <= self.al_height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    self.imageContainerRect = self.imageContainerView.frame;
    [self refreshScrollViewContentSize];
}

#pragma mark 懒加载
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
    }
    return _scrollView;
}

- (UIView *)imageContainerView{
    if (!_imageContainerView) {
      _imageContainerView = [[UIView alloc] init];
      _imageContainerView.clipsToBounds = YES;
      _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageContainerView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)iCloudErrorIcon{
    if (!_iCloudErrorIcon) {
        _iCloudErrorIcon = [[UIImageView alloc] init];
        _iCloudErrorIcon.image = [UIImage hll_imageNamedFromBundle:@"iCloudError"];
        _iCloudErrorIcon.hidden = YES;
    }
    return _iCloudErrorIcon;
}

- (UILabel *)iCloudErrorLabel{
    if (!_iCloudErrorLabel) {
        _iCloudErrorLabel = [[UILabel alloc]init];
        _iCloudErrorLabel = [[UILabel alloc] init];
        _iCloudErrorLabel.font = [UIFont systemFontOfSize:10];
        _iCloudErrorLabel.textColor = [UIColor whiteColor];
        _iCloudErrorLabel.text = @"iCloud 同步失败";
        _iCloudErrorLabel.hidden = YES;
    }
    return _iCloudErrorLabel;
}

- (HLLProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[HLLProgressView alloc]init];
        _progressView.hidden = YES;
    }
    return _progressView;
}


@end
