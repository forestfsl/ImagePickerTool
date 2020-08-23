//
//  UIView+Helper.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "UIView+Helper.h"


@implementation UIView (Helper)

- (void)setAl_x:(CGFloat)al_x {
    CGRect frame = self.frame;
    frame.origin.x = al_x;
    self.frame = frame;
}

- (CGFloat)al_x {
    return self.frame.origin.x;
}

- (void)setAl_y:(CGFloat)al_y {
    CGRect frame = self.frame;
    frame.origin.y = al_y;
    self.frame = frame;
}

- (CGFloat)al_y {
    return self.frame.origin.y;
}

- (void)setAl_centerX:(CGFloat)al_centerX {
    CGPoint center = self.center;
    center.x = al_centerX;
    self.center = center;
}

- (CGFloat)al_centerX {
    return self.center.x;
}

- (void)setAl_centerY:(CGFloat)al_centerY {
    CGPoint center = self.center;
    center.y = al_centerY;
    self.center = center;
}

- (CGFloat)al_centerY {
    return self.center.y;
}

- (void)setAl_width:(CGFloat)al_width {
    CGRect frame = self.frame;
    frame.size.width = al_width;
    self.frame = frame;
}

- (CGFloat)al_width {
    return self.frame.size.width;
}

- (void)setAl_height:(CGFloat)al_height {
    CGRect frame = self.frame;
    frame.size.height = al_height;
    self.frame = frame;
}

- (CGFloat)al_height {
    return self.frame.size.height;
}

- (void)setAl_size:(CGSize)al_size {
    CGRect frame = self.frame;
    frame.size = al_size;
    self.frame = frame;
}

- (CGSize)al_size {
    return self.frame.size;
}

- (void)setAl_origin:(CGPoint)al_origin {
    CGRect frame = self.frame;
    frame.origin = al_origin;
    self.frame = frame;
}

- (CGPoint)al_origin {
    return self.frame.origin;
}

- (CGFloat)al_maxX {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)al_maxY {
    return self.frame.origin.y + self.frame.size.height;
}


+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(HLLscillatoryAnimationType)type{
    NSNumber *animationScale1 = type == HLLscillatoryAnimationToBigger ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == HLLscillatoryAnimationToBigger ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

@end
