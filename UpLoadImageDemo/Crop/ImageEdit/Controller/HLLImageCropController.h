//
//  HLLBeautifyCropViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HLLImageCropControllerDelegate <NSObject>

/**
 剪裁图片后的回调

 @param image 剪裁后返回的图片
 @param cropRect 剪裁区域
 @param angle 角度
 */
- (void)didCropImage:(UIImage *)image
            withRect:(CGRect)cropRect
               angle:(NSInteger)angle;

@end

typedef void(^CompleteEditBlock)(UIImage *image);

@interface HLLImageCropController : UIViewController

@property (nonatomic, copy) CompleteEditBlock completeEditBlock;
@property (nonatomic, weak) id<HLLImageCropControllerDelegate> delegate;


- (instancetype)initWithImage:(UIImage *)image;

@end
