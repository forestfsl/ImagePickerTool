//
//  HLLCustomCameraView.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLCustomCameraView.h"
#import "HLLConfig.h"
#import "UIImage+Helper.h"
#import "UIView+Helper.h"

static const float kMargin_top = 40;
static const float kMargin_left = 40;
static const float KMargin_bottom = 150;

#define kCenterButtonWidth 80.0
#define kLeftButtonWidth 70.0

@interface HLLCustomCameraView()
//中间拍照按钮
@property (nonatomic, strong) UIButton *takeBtn;
//返回按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIImageView *closeImageV;
@property (nonatomic, strong) UILabel *closeL;
//相册按钮
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIImageView *photoImageV;
@property (nonatomic, strong) UILabel *photoL;
//切换设备方向时候相应的提示语
@property (nonatomic, strong) UILabel *leftTipL;
@property (nonatomic, strong) UILabel *rightTipL;
@property (nonatomic, strong) UILabel *bottomTipL;
@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *downView;
@property (nonatomic, strong) UIImageView *leftView_image;
@property (nonatomic, strong) UIImage *leftCornerImage;
@property (nonatomic, strong) UIImageView *rightView_image;
@property (nonatomic, strong) UIImage *rightCornerImage;
@property (nonatomic, strong) UIImageView *downViewLeft_image;
@property (nonatomic, strong) UIImage *belowLeftCornerImage;
@property (nonatomic, strong) UIImageView *downViewRight_image;
@property (nonatomic, strong) UIImage *belowRightCornerImage;

@end


@implementation HLLCustomCameraView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configOverlayView];
    }
    
    return self;
}

- (void)layoutSubviews {
   
    self.upView.frame = CGRectMake(0, 0, self.bounds.size.height, kMargin_top);
    self.leftView.frame = CGRectMake(0, kMargin_top, kMargin_left, self.bounds.size.height-kMargin_top-KMargin_bottom);
    self.rightView.frame = CGRectMake(self.bounds.size.width - kMargin_left, kMargin_top , kMargin_left, self.bounds.size.height-kMargin_top-KMargin_bottom);
    self.downView.frame = CGRectMake(0, self.bounds.size.height - KMargin_bottom, self.bounds.size.width, KMargin_bottom);
    self.leftView_image.frame = CGRectMake(kMargin_left, kMargin_top, self.leftCornerImage.size.width, self.leftCornerImage.size.height);
    self.rightView_image.frame = CGRectMake(self.bounds.size.width-kMargin_left - self.rightCornerImage.size.width, kMargin_top, self.rightCornerImage.size.width, self.rightCornerImage.size.height);
    self.downViewLeft_image.frame = CGRectMake(kMargin_left, self.bounds.size.height - KMargin_bottom - self.belowLeftCornerImage.size.height, self.belowLeftCornerImage.size.width, self.belowLeftCornerImage.size.height);
    self.downViewRight_image.frame = CGRectMake(self.bounds.size.width-kMargin_left - self.belowRightCornerImage.size.width, self.bounds.size.height - KMargin_bottom - self.belowRightCornerImage.size.height, self.belowRightCornerImage.size.width, self.belowRightCornerImage.size.height);
    
    self.rightTipL.frame = CGRectMake(self.bounds.size.width - kMargin_left - 25, kMargin_top, 25,self.leftView.bounds.size.height);

   self.bottomTipL.frame = CGRectMake(kMargin_left, self.bounds.size.height - KMargin_bottom - 30, self.bounds.size.width - kMargin_left *  2.0, 25);
    
    self.leftTipL.frame  = CGRectMake(kMargin_left, kMargin_top, 25,self.leftView.bounds.size.height);
    
     self.takeBtn.frame = CGRectMake((self.bounds.size.width - kCenterButtonWidth)/2, self.bounds.size.height - 40 - kCenterButtonWidth, kCenterButtonWidth, kCenterButtonWidth);
    self.photoBtn.frame = CGRectMake(kMargin_left, self.bounds.size.height - 40 - kCenterButtonWidth, kLeftButtonWidth, kLeftButtonWidth);
    self.photoImageV.frame = CGRectMake((self.photoBtn.frame.size.width - kLeftButtonWidth*0.55*22/26.0) / 2, (self.photoBtn.bounds.size.height - kLeftButtonWidth*0.55*22/26.0 - kLeftButtonWidth*0.22 - 6)/2, kLeftButtonWidth*0.55, kLeftButtonWidth*0.55*22/26.0);
    self.photoL.frame = CGRectMake(0, self.photoImageV.al_maxY + 6, kCenterButtonWidth, kLeftButtonWidth*0.22);
    
    self.closeBtn.frame = CGRectMake(self.bounds.size.width - kMargin_left - kCenterButtonWidth, self.takeBtn.frame.origin.y, kCenterButtonWidth, kCenterButtonWidth);
    self.closeL.frame = CGRectMake((self.closeBtn.bounds.size.width - kCenterButtonWidth*0.5 - 9 - 5) / 2 , (self.closeBtn.bounds.size.height - 16)/2, kCenterButtonWidth*0.5, 16);
    self.closeImageV.frame = CGRectMake(self.closeL.al_maxX + 5 , (self.closeBtn.bounds.size.height - 16)/2, 9, 16);
    
   
}




//配置照相机界面上面的视图控件
- (void)configOverlayView{
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectZero];//80
    upView.backgroundColor = COLOR_RGB(0x000000, 0.3);
    self.upView = upView;
    [self addSubview:upView];
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectZero];
    leftView.backgroundColor = COLOR_RGB(0x000000, 0.3);
    self.leftView = leftView;
    [self addSubview:leftView];

    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectZero];
    rightView.backgroundColor = COLOR_RGB(0x000000, 0.3);
    self.rightView = rightView;
    [self addSubview:rightView];

    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectZero];
    downView.backgroundColor = COLOR_RGB(0x000000, 0.3);
    self.downView = downView;
    [self addSubview:downView];


    //四个边角
    UIImage *leftCornerImage = [UIImage hll_imageNamedFromBundle:@"line_above_left"];
    //左上
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectZero];
    leftView_image.image = leftCornerImage;
    self.leftCornerImage = leftCornerImage;
    self.leftView_image = leftView_image;
    [self addSubview:leftView_image];

    //右上
   UIImage *rightCornerImage = [UIImage hll_imageNamedFromBundle:@"line_above_right"];
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectZero];
    rightView_image.image = rightCornerImage;
    self.rightView_image = rightView_image;
    self.rightCornerImage = rightCornerImage;
    [self addSubview:rightView_image];

    //左下
    UIImage *belowLeftCornerImage = [UIImage hll_imageNamedFromBundle:@"line_below_left"];
    UIImageView *downViewLeft_image = [[UIImageView alloc] initWithFrame:CGRectZero];
    downViewLeft_image.image = belowLeftCornerImage;
    self.downViewLeft_image = downViewLeft_image;
    self.belowLeftCornerImage = belowLeftCornerImage;
    [self addSubview:downViewLeft_image];

    //右下
    UIImage *belowRightCornerImage = [UIImage hll_imageNamedFromBundle:@"line_below_right"];
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectZero];
    downViewRight_image.image = belowRightCornerImage;
    self.downViewRight_image = downViewRight_image;
    self.belowRightCornerImage = belowRightCornerImage;
    [self addSubview:downViewRight_image];


    //说明label
    UILabel *labIntroudctionBottom = [[UILabel alloc] init];
    labIntroudctionBottom.backgroundColor = [UIColor clearColor];
    labIntroudctionBottom.textAlignment = NSTextAlignmentCenter;
    labIntroudctionBottom.font = [UIFont boldSystemFontOfSize:isPad?15:13];
    labIntroudctionBottom.textColor = [UIColor whiteColor];
    labIntroudctionBottom.text = @"请把画作边缘对其框架线";
    [self addSubview:labIntroudctionBottom];

    //说明label
    UILabel *labIntroudctionLeft = [[UILabel alloc] init];
    labIntroudctionLeft.backgroundColor = [UIColor clearColor];
    labIntroudctionLeft.textAlignment = NSTextAlignmentCenter;
    labIntroudctionLeft.font = [UIFont boldSystemFontOfSize:isPad?15:13];
    labIntroudctionLeft.textColor = [UIColor whiteColor];
    labIntroudctionLeft.text = @"请把画作边缘对其框架线";
    [self addSubview:labIntroudctionLeft];
    CGAffineTransform transformLeft =CGAffineTransformMakeRotation(M_PI/2);
    [labIntroudctionLeft setTransform:transformLeft];


    //说明label
    UILabel *labIntroudctionRight = [[UILabel alloc] init];
    labIntroudctionRight.backgroundColor = [UIColor clearColor];
    labIntroudctionRight.textAlignment = NSTextAlignmentCenter;
    labIntroudctionRight.font = [UIFont boldSystemFontOfSize:isPad?15:13];
    labIntroudctionRight.textColor = [UIColor whiteColor];
    labIntroudctionRight.text = @"请把画作边缘对其框架线";
    [self addSubview:labIntroudctionRight];
    CGAffineTransform transformRight =CGAffineTransformMakeRotation(-M_PI/2);
    [labIntroudctionRight setTransform:transformRight];
    labIntroudctionBottom.hidden = YES;
    labIntroudctionRight.hidden = YES;
    labIntroudctionLeft.hidden = YES;

    self.leftTipL = labIntroudctionLeft;
    self.rightTipL = labIntroudctionRight;
    self.bottomTipL = labIntroudctionBottom;

    [self addSubview:self.takeBtn];
    [self addSubview:self.closeBtn];
    [self addSubview:self.photoBtn];
}

- (void)setCurrentOrientation:(UIDeviceOrientation)currentOrientation{
    if (currentOrientation == _currentOrientation) {
           return;
       }
       switch (currentOrientation) {
           case UIDeviceOrientationPortraitUpsideDown:
           case UIDeviceOrientationPortrait:
           {
               self.rightTipL.hidden = YES;
               self.leftTipL.hidden = YES;
               self.bottomTipL.hidden = NO;
               [UIView animateWithDuration:0.2 animations:^{
                   self.closeBtn.transform = CGAffineTransformIdentity;
                   self.photoBtn.transform = CGAffineTransformIdentity;
               }];
           }
               break;
           case UIDeviceOrientationLandscapeRight:
           {
               self.rightTipL.hidden = NO;
               self.leftTipL.hidden = YES;
               self.bottomTipL.hidden = YES;
               CGAffineTransform transform =CGAffineTransformMakeRotation(-M_PI/2);
               [UIView animateWithDuration:0.2 animations:^{
                   [self.photoBtn setTransform:transform];
                   [self.closeBtn setTransform:transform];
               }];
           }
               break;
           case UIDeviceOrientationLandscapeLeft:
           {
               self.rightTipL.hidden = YES;
               self.leftTipL.hidden = NO;
               self.bottomTipL.hidden = YES;
               CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI/2);
               [UIView animateWithDuration:0.2 animations:^{
                   [self.photoBtn setTransform:transform];
                   [self.closeBtn setTransform:transform];
               }];
              
           }
               break;
               
           default:
               break;
       }
       _currentOrientation = currentOrientation;
}


#pragma mark 点击事件响应
- (void)closButtonPressed:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClikBackAction)]) {
        [self.delegate didClikBackAction];
    }
}

- (void)takeButtonPressed:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickTakePhoto)]) {
        [self.delegate didClickTakePhoto];
    }
}

- (void)requestAlbumAuthorization:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPhotoLibrary)]) {
        [self.delegate didClickPhotoLibrary];
    }
}



- (UIButton *)takeBtn{
    if (!_takeBtn) {
        _takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _takeBtn.layer.cornerRadius = kCenterButtonWidth/2;
        
        [_takeBtn setBackgroundImage:[UIImage hll_imageNamedFromBundle:@"btn_photograph_default"] forState:UIControlStateNormal];
        
        [_takeBtn addTarget:self action:@selector(takeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _takeBtn.contentEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    }
    return _takeBtn;
}


- (UIButton *)photoBtn{
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoBtn addTarget:self action:@selector(requestAlbumAuthorization:) forControlEvents:UIControlEventTouchUpInside];
       
        UIImageView * photoImageV = [[UIImageView alloc] initWithImage:[UIImage hll_imageNamedFromBundle:@"icon_album_default"]];
        self.photoImageV = photoImageV;
        [_photoBtn addSubview:photoImageV];
        
        UILabel *photoL = [[UILabel alloc] init];
        photoL.text = @"相册上传";
        photoL.textAlignment = NSTextAlignmentCenter;
        photoL.textColor = [UIColor whiteColor];
        photoL.font = [UIFont systemFontOfSize:15];
        self.photoImageV = photoImageV;
        self.photoL = photoL;
        [_photoBtn addSubview:photoL];
        
    }
    return _photoBtn;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn addTarget:self action:@selector(closButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * closeImageV = [[UIImageView alloc] initWithImage:[UIImage hll_imageNamedFromBundle:@"icon_back_default"]];
        self.closeImageV = closeImageV;
        [_closeBtn addSubview:closeImageV];
        
        UILabel * closeL = [[UILabel alloc] init];
        closeL.text = @"返回";
        closeL.textColor = [UIColor whiteColor];
        closeL.textAlignment = NSTextAlignmentRight;
        closeL.font = [UIFont systemFontOfSize:17];
        self.closeL = closeL;
        [_closeBtn addSubview:closeL];
    }
    return _closeBtn;
}


@end
