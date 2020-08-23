//
//  HLLBeautifyBottomView.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/21.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLBeautifyBottomView.h"
#import "HLLConfig.h"
#import "UIView+Helper.h"
#import "UIImage+Helper.h"

@interface HLLBeautifyBottomView()<HLLBeautifyBottomButtonDelegate>
///底部按钮数组
@property (nonatomic, strong) NSMutableArray *buttonArray;
///当前选中的类型
@property (nonatomic, assign) BeautifyButtonType selectedType;
@end


@implementation HLLBeautifyBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonArray = [NSMutableArray arrayWithCapacity:0];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    self.backgroundColor = UIColor.blackColor;
    NSArray *images = @[@"icon_btn_crop",@"icon_btn_reset",
                           @"icon_btn_preStep",@"icon_btn_nextStep",
                           @"icon_btn_roate_left",@"icon_btn_roate_right",
                           @"icon_btn_stretch",@"icon_btn_ajust",@"icon_btn_frame"
                           ];
    NSArray *titles = @[@"裁剪",@"重置",@"上一步",@"下一步",@"左旋转",@"右旋转",@"拉伸",@"调节",@"画框"];
    
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        HLLBeautifyBottomButton *button = nil;
        if (idx < 4) {
            //第一行0 1 2 3
            CGRect frame = CGRectMake(idx * (kScreenWidth/5), 30 * KUIScale, kScreenWidth/5, 117 * KUIScale);
            button = [[HLLBeautifyBottomButton alloc]initWithFrame:frame title:title imageName:images[idx] type:idx];
            
        }else{
            //第二行3 4 5 6 7
             CGRect frame = CGRectMake((idx-4) * (kScreenWidth/5), 177 * KUIScale, kScreenWidth/5, 117 * KUIScale);
            button = [[HLLBeautifyBottomButton alloc]initWithFrame:frame title:title imageName:images[idx] type:idx];
        }
        button.tag = idx;
        button.delegate = self;
        [self addSubview:button];
        [self.buttonArray addObject:button];
    }];
}

- (void)didSelectItem:(NSInteger)type{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClick:)]) {
         [self.delegate buttonClick:type];
    }
   
    if (type == self.selectedType && type != 0) {
        return;
    }else{
        [self.buttonArray enumerateObjectsUsingBlock:^(HLLBeautifyBottomButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == type) {
                button.selectBgView.hidden = false;
            }else{
                button.selectBgView.hidden = true;
            }
        }];
    }
    self.selectedType = type;
}
@end


@interface HLLBeautifyBottomButton ()

@property (nonatomic, strong) UIView *iconTypeView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;

@end


@implementation HLLBeautifyBottomButton


- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title imageName:(NSString *)imageName type:(NSInteger)type{
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        _imageName = imageName;
        _type = type;
        [self initSubViews];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItem:)]) {
        [self.delegate didSelectItem:self.type];
    }
}


- (void)initSubViews {
    self.selectBgView = [[UIView alloc]initWithFrame:CGRectMake((self.al_width-78 *KUIScale)/2, 0, 78 * KUIScale, 78 *KUIScale)];
    self.selectBgView.layer.contents = (__bridge _Nonnull id)[UIImage hll_imageNamedFromBundle:@"icon_btn_bg_gray"].CGImage;
    [self addSubview:self.selectBgView];
    self.selectBgView.hidden = true;
    
    self.iconTypeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 32 * KUIScale, 40 * KUIScale)];
    self.iconTypeView.layer.contents = (__bridge _Nonnull id)[UIImage hll_imageNamedFromBundle:_imageName].CGImage;
    self.iconTypeView.center = self.selectBgView.center;
    [self addSubview:self.iconTypeView];
    
    self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.al_height - 30, self.al_width, 30)];
    self.textLabel.font = [UIFont systemFontOfSize:15];
    self.textLabel.text = self.title;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.textLabel];
}




@end
