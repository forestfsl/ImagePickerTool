//
//  HLLBeautifyBottomView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/21.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLLBeautifyBottomButtonDelegate <NSObject>

- (void)didSelectItem:(NSInteger)type;

@end

@interface HLLBeautifyBottomButton : UIView

@property (nonatomic, weak) id<HLLBeautifyBottomButtonDelegate> delegate;

///选中的背景
@property (nonatomic, strong) UIView *selectBgView;

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                     imageName:(NSString *)imageName
                         type:(NSInteger)type;

@end


typedef enum : NSUInteger {
    BeautifyButtonType_Crop=0,//剪裁
    BeautifyButtonType_Reset,//重置
    BeautifyButtonType_PreStep,//上一步
    BeautifyButtonType_NextStep,//下一步
    BeautifyButtonType_Roate_Left,//左旋转
    BeautifyButtonType_Roate_Right,//右旋转
    BeautifyButtonType_Stretch,//拉伸
    BeautifyButtonType_Ajust,//调节
    BeautifyButtonType_Frame//画框
} BeautifyButtonType;


@protocol HLLBeautifyBottomViewDelegate <NSObject>

- (void)buttonClick:(BeautifyButtonType)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLLBeautifyBottomView : UIView

@property (nonatomic, weak) id<HLLBeautifyBottomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
