//
//  HLLBeautifyNavView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/21.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HLLBeautifyNavViewDelegate <NSObject>

- (void)goBack;

- (void)sureAction;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLLBeautifyNavView : UIView

@property (nonatomic, weak) id<HLLBeautifyNavViewDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, assign) BOOL needBack;
@property (nonatomic, assign) BOOL needSure;

- (void)configSureBtnTitleColor:(UIColor *)titleColor;

- (void)configSureBtnBgColor:(UIColor *)bgColor;

- (void)configSureBtnEnable:(BOOL)enable;

- (void)configSureBtnHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
