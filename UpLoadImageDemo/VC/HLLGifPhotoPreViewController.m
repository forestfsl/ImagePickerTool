//
//  HLLGifPhotoPreViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/17.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLGifPhotoPreViewController.h"
#import "HLLTemplatePickerViewController.h"
#import "HLLAssetModel.h"
#import "UIView+Helper.h"
#import "HLLPhotoPreViewCell.h"
#import "HLLImageManager.h"
#import "HLLCommonTools.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface HLLGifPhotoPreViewController (){
    UIView *_toolBar;
    UIButton *_doneButton;
    UIProgressView *_progress;
    
    HLLPhotoPreviewView *_previewView;
    UIStatusBarStyle _originStatusBarStyle;
}

@property (assign, nonatomic) BOOL needShowStatusBar;

@end

@implementation HLLGifPhotoPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    self.view.backgroundColor = [UIColor blackColor];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC) {
        self.navigationItem.title = [NSString stringWithFormat:@"GIF%@",pickerVC.previewBtnTitleStr];
    }
    [self configPreviewView];
    [self configBottomToolBar];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
}



- (void)configPreviewView{
    _previewView = [[HLLPhotoPreviewView alloc]initWithFrame:CGRectZero];
    _previewView.model = self.model;
    __weak typeof(self) weakSelf = self;
    [_previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf singleTapAction];
    }];
    [self.view addSubview:_previewView];
}

- (void)configBottomToolBar{
    _toolBar = [[UIView alloc]initWithFrame:CGRectZero];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC) {
        [_doneButton setTitle:pickerVC.doneBtnTitleStr forState:UIControlStateNormal];
        [_doneButton setTitleColor:pickerVC.okBtnTitleColorNormal forState:UIControlStateNormal];
    }else{
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    }
     [_toolBar addSubview:_doneButton];
    
    UILabel *byteLabel = [[UILabel alloc] init];
    byteLabel.textColor = [UIColor whiteColor];
    byteLabel.font = [UIFont systemFontOfSize:13];
    byteLabel.frame = CGRectMake(10, 0, 100, 44);
    [[HLLImageManager manager] fetchPhotosBytesWithArray:@[_model] completion:^(NSString *totalBytes) {
        byteLabel.text = totalBytes;
    }];
    [_toolBar addSubview:byteLabel];
    
    [self.view addSubview:_toolBar];
    
    if (pickerVC.gifPreviewPageUIConfigBlock) {
        pickerVC.gifPreviewPageUIConfigBlock(_toolBar, _doneButton);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC && [pickerVC isKindOfClass:[HLLTemplatePickerViewController class]]) {
        return pickerVC.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _previewView.frame = self.view.bounds;
    _previewView.scrollView.frame = self.view.bounds;

    CGFloat toolBarHeight = [HLLCommonTools hll_isIPhoneX] ? 44 + (83 - 49) : 44;
    _toolBar.frame = CGRectMake(0, self.view.al_height - toolBarHeight, self.view.al_width, toolBarHeight);
    _doneButton.frame = CGRectMake(self.view.al_width - 44 - 12, 0, 44, 44);
    
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.gifPreviewPageDidLayoutSubviewsBlock) {
        pickerVC.gifPreviewPageDidLayoutSubviewsBlock(_toolBar, _doneButton);
    }
}


#pragma mark 点击事件响应

- (void)singleTapAction{
    _toolBar.hidden = !_toolBar.isHidden;
    [self.navigationController setNavigationBarHidden:_toolBar.isHidden];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (_toolBar.isHidden) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }else if (pickerVC.needShowStatusBar){
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
}




- (void)doneButtonClick{
    if (self.navigationController) {
        HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
        if (pickerVC.autoDismiss) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self callDelegateMethod];
            }];
        }else{
            [self callDelegateMethod];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }
}

- (void)callDelegateMethod {
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    UIImage *animatedImage = _previewView.imageView.image;
    if ([pickerVC.pickerDelegate respondsToSelector:@selector(hll_imagePickerController:didFinishPickingGifImage:sourceAssets:)]) {
        [pickerVC.pickerDelegate hll_imagePickerController:pickerVC didFinishPickingGifImage:animatedImage sourceAssets:_model.asset];
    }
    if (pickerVC.didFinishPickingGifImageHandle) {
        pickerVC.didFinishPickingGifImageHandle(animatedImage,_model.asset);
    }
}

#pragma clang diagnostic pop

@end
