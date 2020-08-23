//
//  HLLBeautifyCropViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLImageCropController.h"
#import "HLLCropViewController-Header.h"
#import "HLLBeautifyNavView.h"
#import "UIView+Helper.h"
#import "HLLConfig.h"
#import "UIImage+Helper.h"
@interface HLLImageCropController ()

@property (nonatomic, strong) HLLBeautifyNavView *navView;
@property (nonatomic, strong) HLLCropView *cropView;
@property (nonatomic, strong) UIImage *sourceImage;//展示的图片
@property (nonatomic, strong) UIButton *closeButton;//取消按钮
@property (nonatomic, strong) UIButton *saveButton;//保存按钮

//页面进入和离开时的时间
@property (nonatomic, assign) CFAbsoluteTime StartTime;
@property (nonatomic, assign) CFAbsoluteTime EndTime;
@property (nonatomic, assign) NSInteger stayTime;//停留时间(以秒为单位)
@end

@implementation HLLImageCropController

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _sourceImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];
  
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.StartTime = CFAbsoluteTimeGetCurrent();
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.EndTime = CFAbsoluteTimeGetCurrent();
    self.stayTime = (self.EndTime - self.StartTime);//停留时间(以秒为单位)

}



#pragma mark - delegate

- (void)initSubViews{
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.navView];
    if (_sourceImage) {
        self.cropView = [[HLLCropView alloc] initWithImage:_sourceImage];
        self.cropView.frame = CGRectMake(0, (kScreenHeight - kScreenWidth)/2, kScreenWidth, kScreenWidth);
        [self.view addSubview:self.cropView];
    }
    
    
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.saveButton];
    
    
    
   
}

#pragma mark - button click

- (void)backAction{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)saveAction{
    [self dismissViewControllerAnimated:true completion:^{
        if (self.completeEditBlock) {
            UIImage *image = [self.cropView.image croppedImageWithFrame:self.cropView.imageCropFrame angle:self.cropView.angle circularClip:false];
            self.completeEditBlock(image);
        }
    }];
    
}

- (HLLBeautifyNavView *)navView{
    if (!_navView) {
        _navView = [[HLLBeautifyNavView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopHeight)];
        _navView.title = @"裁剪";
        _navView.needSure = false;
        _navView.needBack = false;
    }
    return _navView;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(28 * KWScale, kScreenHeight - 229 * KUIScale, 84 * KUIScale, 84 * KUIScale);
        [_closeButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_close_white"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(kScreenWidth - 84 * KUIScale - 28 * KUIScale, kScreenHeight - 229 * KUIScale, 84 * KUIScale, 84 * KUIScale);
        [_saveButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_save"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

@end
