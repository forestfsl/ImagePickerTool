//
//  HLLBeautifyImageBorderView.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLBeautifyImageBorderView.h"
#import "HLLConfig.h"
#import "UIView+Helper.h"
#import "UIImage+Helper.h"



@interface HLLBeautifyImageBorderView()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *commitButton;
@property (nonatomic, strong) NSMutableArray *borderImageArray;

@end


@implementation HLLBeautifyImageBorderView

- (void)dealloc{
    _borderImageArray = nil;
    _closeButton = nil;
    _commitButton = nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HColor(0xF4F4F4);
        self.userInteractionEnabled = YES;
               
        _borderImageArray = [NSMutableArray arrayWithCapacity:0];
        [self addSubview:self.closeButton];
        [self addSubview:self.commitButton];
               
        CGFloat height = 158 * KUIScale;
        CGFloat width = 158 * KUIScale;
        CGFloat magin = 38 * KUIScale;
               
        NSInteger borderCount = 20;
        // 滚动视图
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.closeButton.al_maxY, kScreenWidth, 245 * KUIScale)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.userInteractionEnabled = YES;
        scrollView.contentSize = CGSizeMake((width + magin) * (borderCount+1)+magin, 0);
        [self addSubview:scrollView];
        // 边框小图
        for (int i = 0; i <= borderCount; i ++) {
            @autoreleasepool {
                CGRect rect = CGRectMake(magin + (width + magin) * i, 36 * KUIScale, width, height);
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:rect];
                imageView.tag = 100 + i;
                imageView.userInteractionEnabled = YES;
                imageView.image = [UIImage hll_imageNamedFromBundle:[NSString stringWithFormat:@"icon_image_border_%d",i]];
                [scrollView addSubview:imageView];
                [_borderImageArray addObject:imageView];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapp:)];
                       [imageView addGestureRecognizer:tap];
                   }
               }
    }
    return self;
}



- (void)closeButtonClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancel)]) {
        [self.delegate cancel];
    }
    
}

- (void)commitButtonClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commit)]) {
        [self.delegate commit];
    }
    
}

- (void)tapp:(UITapGestureRecognizer *)tap{
    
    UIImageView *imageView = (UIImageView *)[tap view];
    NSInteger index = imageView.tag - 100;
    [self resetBorderImages:index];
    if ([self.delegate respondsToSelector:@selector(didSelectBorderAtIndex:)]) {
        [self.delegate didSelectBorderAtIndex:index];
    }
}

//重置
- (void)resetBorderImages:(NSInteger)selectedIndex{
    [_borderImageArray enumerateObjectsUsingBlock:^(UIImageView *borderView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx==selectedIndex) {
            //加边框
            borderView.layer.cornerRadius = 8;
            borderView.layer.borderColor = [UIColor colorWithRed:255 green:79 blue:1 alpha:1].CGColor;
            borderView.layer.borderWidth = 2;
            borderView.layer.masksToBounds = true;
        }else{
            borderView.layer.cornerRadius = 0;
            borderView.layer.borderWidth = 0;
            borderView.layer.borderColor = UIColor.clearColor.CGColor;
            borderView.layer.masksToBounds = false;
        }
    }];
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setFrame:CGRectMake(49 *KUIScale, 32 *KUIScale, 84 *KUIScale, 84 *KUIScale)];
        [_closeButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_close_black"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)commitButton{
    if (!_commitButton) {
        _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commitButton setFrame:CGRectMake(kScreenWidth-(49+84) *KUIScale, 32 *KUIScale, 84 *KUIScale, 84 *KUIScale)];
        [_commitButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_save_black"] forState:UIControlStateNormal];
        [_commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitButton;
}



@end
