//
//  HLLBeautifyImageAjustViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLBeautifyImageAjustViewController.h"
#import "MMOpenCVHelper.h"
#import "UIImageView+ContentFrame.h"
#import "HLLBeautifyNavView.h"
#import "HLLConfig.h"
#import "UIView+Helper.h"
#import "UIImage+Helper.h"


@interface HLLBeautifyImageAjustViewController ()
@property (nonatomic, strong) HLLBeautifyNavView *navView;
@property (nonatomic, strong) UIImageView *contentImageV;
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel  *lightNameLabel;//亮度
@property (nonatomic, strong) UILabel  *contrastNameLabel;//对比度

@property (nonatomic, strong) UISlider *lightSlider;
@property (nonatomic, strong) UISlider *contrastSlider;
@property (nonatomic, assign) CGFloat   lightValue;//亮度值
@property (nonatomic, assign) CGFloat   contrastValue;//对比度值

@property (nonatomic, assign) BOOL hasAjusted;//是否调节过s
@end

@implementation HLLBeautifyImageAjustViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initConfigDatas];
    [self initSubViews];
}



- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        _sourceImage = image;
    }
    return self;
}

- (void)initConfigDatas{
    _lightValue = 0;
    _contrastValue = 1;
}

- (void)initSubViews{
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.contentImageV];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.lightNameLabel];
    [self.view addSubview:self.contrastNameLabel];
    [self.view addSubview:self.lightSlider];
    [self.view addSubview:self.contrastSlider];
}

- (UIImageView *)contentImageV{
    if (!_contentImageV) {
        _contentImageV = [[UIImageView alloc] initWithImage:_sourceImage];
        _contentImageV.frame = CGRectMake(0, (self.view.al_height - kScreenWidth * 0.75)/2, kScreenWidth, kScreenWidth * 0.75);
        _contentImageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentImageV;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(28 * KUIScale, self.view.al_height - 270 * KUIScale - 84 * KUIScale, 84 * KUIScale, 84 * KUIScale);
        [_closeButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_close_white"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(self.view.al_width - 84 * KUIScale - 28 * KUIScale, self.view.al_height - 270 * KUIScale - 84 * KUIScale, 84 * KUIScale, 84 * KUIScale);
        [_saveButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_save"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (HLLBeautifyNavView *)navView{
    if (!_navView) {
        _navView = [[HLLBeautifyNavView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopHeight)];
        _navView.title = @"调节";
        _navView.needBack = false;
        _navView.needSure = false;
    }
    return _navView;
}

- (UILabel *)lightNameLabel{
    if (!_lightNameLabel) {
        _lightNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(28 * KUIScale, self.closeButton.al_maxY, 150 * KUIScale, 40)];
        _lightNameLabel.font = [UIFont systemFontOfSize:24 * KUIScale];
        _lightNameLabel.text = @"亮度";
        _lightNameLabel.textColor = UIColor.whiteColor;
    }
    return _lightNameLabel;
}

- (UILabel *)contrastNameLabel{
    if (!_contrastNameLabel) {
        _contrastNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.closeButton.al_x, self.lightNameLabel.al_maxY, 150 * KUIScale, 40)];
        _contrastNameLabel.font = [UIFont systemFontOfSize:24 * KUIScale];
        _contrastNameLabel.text = @"对比度 ";
        _contrastNameLabel.font = [UIFont systemFontOfSize:24 * KUIScale];
        _contrastNameLabel.textColor = UIColor.whiteColor;
    }
    return _contrastNameLabel;
}
//亮度
- (UISlider *)lightSlider{
    if (!_lightSlider) {
        _lightSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.al_width - 105 * KUIScale - 432 * KUIScale, self.closeButton.al_maxY, 432 * KUIScale, 50 * KUIScale)];
        _lightSlider.backgroundColor = UIColor.clearColor;
        _lightSlider.tintColor = HColor(0xFF5A00);
        _lightSlider.minimumValue = -100;
        _lightSlider.maximumValue = 100;
        _lightSlider.value = _lightValue;
        _lightSlider.tag = 1111;
        [_lightSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _lightSlider;
}
//对比度
- (UISlider *)contrastSlider{
    if (!_contrastSlider) {
        _contrastSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.al_width - 105 * KUIScale - 432 * KUIScale, self.contrastNameLabel.al_y, 432 * KUIScale, 50 * KUIScale)];
        _contrastSlider.backgroundColor = UIColor.clearColor;
        _contrastSlider.tintColor = HColor(0xFF5A00);
        _contrastSlider.minimumValue = 0.5;
        _contrastSlider.maximumValue = 1.5;
        _contrastSlider.value = _contrastValue;
        _contrastSlider.tag = 2222;
        [_contrastSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _contrastSlider;
}

//调节
- (void)sliderValueChange:(UISlider *)slider{
    _hasAjusted = true;
    
    NSInteger tag = slider.tag;
    CGFloat value = slider.value;
    switch (tag) {
        case 1111: // 亮度
            _lightValue = value;
            _lightNameLabel.text = [NSString stringWithFormat:@"亮度 %d",(int)value];
            break;
        case 2222: // 对比度
            _contrastValue = value;
            _contrastNameLabel.text = [NSString stringWithFormat:@"对比度 %d",(int)((value-1)*200)];
            break;
    }

    UIImage *resultImage = [MMOpenCVHelper transform:_sourceImage
                                               alpha:_contrastValue
                                                beta:_lightValue];
    
    _contentImageV.image = resultImage;
    
}

- (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size {
    // 创建一个bitmap的context
    UIGraphicsBeginImageContextWithOptions(size, YES, [[UIScreen mainScreen] scale]);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (void)backAction{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)saveAction{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:true completion:^{
        if (self.completeEditBlock) {
            self.completeEditBlock(weakSelf.contentImageV.image);
        }
    }];
}


@end
