//
//  MMOpenCVHelper.h
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>


@interface MMOpenCVHelper : NSObject
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

+ (cv::Mat)cvMatFromAdjustedUIImage:(UIImage *)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromAdjustedUIImage:(UIImage *)image;
/**
 调节图片对比度和亮度
 
 @param image 原图像
 @param alpha 对比度
 @param beta 亮度
 @return 转换结果
 */
+ (UIImage *)transform:(UIImage *)image
                 alpha:(double)alpha
                  beta:(double)beta;

@end
