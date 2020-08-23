//
//  HLLBeautifyViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/21.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^ BeautifyCompleteBlock)(UIImage *image);

NS_ASSUME_NONNULL_BEGIN

@interface HLLBeautifyViewController : UIViewController
///是否已经美化过了
@property (nonatomic, assign) BOOL hasBeautified;
///原图片
@property (nonatomic, strong) NSURL *sourceImageUrl;
@property (nonatomic, strong) UIImage *sourceImage;
///没加相框图片
@property (nonatomic, strong) NSURL *noFrameSourceImageUrl;
///加了相框的图片
@property (nonatomic, strong) NSURL *frameSourceImageUrl;

@property (nonatomic, copy) BeautifyCompleteBlock completeBlock;

@property (nonatomic, assign) NSInteger photoFrameCode;//相框代码0表示未加相框,1、2..对应相框的下标

- (instancetype)initWithSourceImage:(UIImage *)sourceImage;

@end

NS_ASSUME_NONNULL_END


