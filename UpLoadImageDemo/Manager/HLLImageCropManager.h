//
//  HLLImageCropManager.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface HLLImageCropManager : NSObject

///裁剪框背景的处理
+ (void)overlayClippingwWithViewV:(UIView *)view cropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop;

///获得裁剪后的图片
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView;

///获取图形图片
+ (UIImage *)circularClipImage:(UIImage *)image;

@end


