//
//  HLLBeautifyImageFrameController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLBeautifyImageFrameController.h"
#import "HLLBeautifyNavView.h"
#import "HLLBeautifyImageBorderView.h"
#import "UIImage+Helper.h"
#import "HLLConfig.h"
#import "UIView+Helper.h"


@interface HLLBeautifyImageFrameController ()<HLLBeautifyImageBorderViewDelegate>

@property (nonatomic, strong) HLLBeautifyNavView *navView;
@property (nonatomic, strong) UIImage *sourceImage;//展示的图片

@property (nonatomic, strong) UIImageView *frameImageView;//相框
@property (nonatomic, strong) UIImageView *contentImageView;//展示的图片
@property (nonatomic, strong) HLLBeautifyImageBorderView *borderView;//底部相框选择
@property (nonatomic, strong) UIImage *frameImage;//画框
@property (nonatomic, assign) NSInteger selectedFrameCode;

@end

@implementation HLLBeautifyImageFrameController

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        _sourceImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
}

- (void)initSubViews{
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.frameImageView];
    [self.view addSubview:self.contentImageView];
    [self.view addSubview:self.borderView];
}



- (void)didSelectBorderAtIndex:(NSInteger)index{
    self.selectedFrameCode = index;
    if (index==0) {
        self.frameImageView.image = nil;
        self.frameImage = nil;
    }
    NSString *imageName = [NSString stringWithFormat:@"icon_image_border_%ld",(long)index];
    self.frameImage = [UIImage hll_imageNamedFromBundle:imageName];
    self.frameImageView.image = self.frameImage;
}


- (void)cancel{
     [self dismissViewControllerAnimated:true completion:nil];
}

- (void)commit{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:true completion:^{
        if (self.frameImage) {
            if (self.completeEditBlock) {
                self.completeEditBlock(weakSelf.selectedFrameCode);
            }
        }else{
            if (self.completeEditBlock) {
                self.completeEditBlock(weakSelf.selectedFrameCode);
            }
        }
    }];
}


- (HLLBeautifyNavView *)navView{
    if (!_navView) {
        _navView = [[HLLBeautifyNavView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopHeight)];
        _navView.title = @"美化";
        _navView.backgroundColor = UIColor.whiteColor;
        _navView.titleColor = UIColor.blackColor;
        _navView.needBack = false;
        _navView.needSure = false;
    }
    return _navView;
}
//画框
- (UIImageView *)frameImageView{
    if (!_frameImageView) {
        _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, kTopHeight+40, kScreenWidth-7.5*2, kScreenWidth-7.5*2)];
        _frameImageView.backgroundColor = UIColor.whiteColor;
    }
    return _frameImageView;
}
//原图
- (UIImageView *)contentImageView{
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frameImageView.al_x+65, self.frameImageView.al_y+65, kScreenWidth-15-131, kScreenWidth-15-131)];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        _contentImageView.backgroundColor = UIColor.whiteColor;
        _contentImageView.image = _sourceImage;
    }
    return _contentImageView;
}

- (HLLBeautifyImageBorderView *)borderView{
    if (!_borderView) {
        _borderView = [[HLLBeautifyImageBorderView alloc] initWithFrame:CGRectMake(0, kScreenHeight-170, kScreenWidth, 170)];
        _borderView.delegate = self;
    }
    return _borderView;
}


@end
