//
//  UIImage+Helper.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Helper)

+ (UIImage *)hll_imageNamedFromBundle:(NSString *)name;

+ (UIImage *)hll_animatedGIFWithData:(NSData *)data;

- (UIImage *)hll_imageByRotateRight90;
- (UIImage *)hll_imageByRotateLeft90;

- (UIImage *)hll_imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

- (UIImage *)imageAddBorderBy:(UIImage *)borderImage;
@end

NS_ASSUME_NONNULL_END
