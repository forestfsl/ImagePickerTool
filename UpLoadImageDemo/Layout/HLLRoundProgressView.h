//
//  HLLRoundProgressView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/19.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLLRoundProgressView : UIView


/**进度条颜色*/
@property (strong, nonatomic) UIColor *progressColor;
/**dash pattern*/
@property (strong, nonatomic) NSArray *lineDashPattern;
/**进度Label字体*/
@property (strong, nonatomic) UIFont  *progressFont;

- (void)updateProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
