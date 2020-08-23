//
//  UIView+Helper.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//




#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    HLLscillatoryAnimationToBigger,
    HLLscillatoryAnimationToSmaller,
} HLLscillatoryAnimationType;


NS_ASSUME_NONNULL_BEGIN

@interface UIView (Helper)

@property (nonatomic, assign) CGFloat al_x;
@property (nonatomic, assign) CGFloat al_y;
@property (nonatomic, assign) CGFloat al_width;
@property (nonatomic, assign) CGFloat al_height;
@property (nonatomic, assign) CGFloat al_centerX;
@property (nonatomic, assign) CGFloat al_centerY;
@property (nonatomic, assign) CGSize  al_size;
@property (nonatomic, assign) CGPoint al_origin;
@property (nonatomic, assign, readonly) CGFloat al_maxX;
@property (nonatomic, assign, readonly) CGFloat al_maxY;

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(HLLscillatoryAnimationType)type;

@end

NS_ASSUME_NONNULL_END
