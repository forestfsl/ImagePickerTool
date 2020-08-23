//
//  HLLBeautifyNavView.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/21.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLBeautifyNavView.h"
#import "UIImage+Helper.h"
#import "UIView+Helper.h"
#import "HLLConfig.h"

@interface HLLBeautifyNavView()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *sureBtn;

@end


@implementation HLLBeautifyNavView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor{
    self.titleLabel.textColor = titleColor;
}

- (void)backButtonClick{
    [self.delegate goBack];
}

- (void)commitButtomClick{
    [self.delegate sureAction];
}

- (void)initSubViews{
    self.backgroundColor = UIColor.blackColor;
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.sureBtn];
    
    self.backButton.frame = CGRectMake(0, (self.al_height - 44) / 2 + 10, 44, 44);
    self.titleLabel.frame = CGRectMake((self.al_width - 200) / 2, (self.al_height - 44) / 2 + 10, 200, 44);
    self.sureBtn.frame = CGRectMake(self.al_width - 60 - 18, (self.al_height - 28) / 2 + 10, 60, 28);
}

- (void)setNeedBack:(BOOL)needBack{
    self.backButton.hidden = !needBack;
}

- (void)setNeedSure:(BOOL)needSure{
    self.sureBtn.hidden = !needSure;
}


- (void)configSureBtnTitleColor:(UIColor *)titleColor{
    self.sureBtn.titleLabel.textColor = titleColor;
}


- (void)configSureBtnBgColor:(UIColor *)bgColor{
    self.sureBtn.backgroundColor = bgColor;
}

- (void)configSureBtnEnable:(BOOL)enable{
    self.sureBtn.enabled = enable;
}

- (void)configSureBtnHidden:(BOOL)hidden{
    self.sureBtn.hidden = hidden;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage hll_imageNamedFromBundle:@"navi_back"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = @"美化";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = UIColor.whiteColor;
    }
    return _titleLabel;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _sureBtn.backgroundColor = HColor(0xC8C8C8);//0xC8C8C8未完成   0xFF3A2F 已完成
        [_sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        _sureBtn.layer.cornerRadius =10;
        _sureBtn.enabled = NO;
        [_sureBtn addTarget:self action:@selector(commitButtomClick) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.enabled = false;
    }
    return _sureBtn;
}


@end
