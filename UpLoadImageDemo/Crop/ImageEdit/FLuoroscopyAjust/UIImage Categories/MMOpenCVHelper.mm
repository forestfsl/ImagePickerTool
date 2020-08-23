//
//  MMOpenCVHelper.m
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//

#import "MMOpenCVHelper.h"
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

@implementation MMOpenCVHelper
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
//    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
//
//    CGColorSpaceRef colorSpace;
//
//    if (cvMat.elemSize() == 1) {
//        colorSpace = CGColorSpaceCreateDeviceGray();
//    } else {
//        colorSpace = CGColorSpaceCreateDeviceRGB();
//    }
//
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
//
//    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
//                                        cvMat.rows,                                     // Height
//                                        8,                                              // Bits per component
//                                        8 * cvMat.elemSize(),                           // Bits per pixel
//                                        cvMat.step[0],                                  // Bytes per row
//                                        colorSpace,                                     // Colorspace
//                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
//                                        provider,                                       // CGDataProviderRef
//                                        NULL,                                           // Decode
//                                        false,                                          // Should interpolate
//                                        kCGRenderingIntentDefault);                     // Intent
//
//    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(colorSpace);
    
    
    return MatToUIImage(cvMat);
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
//    CGFloat cols,rows;
//    if  (image.imageOrientation == UIImageOrientationLeft
//         || image.imageOrientation == UIImageOrientationRight) {
//        cols = image.size.height;
//        rows = image.size.width;
//    }
//    else{
//        cols = image.size.width;
//        rows = image.size.height;
//
//    }
//
//
//    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
//
//    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
//                                                    cols,                       // Width of bitmap
//                                                    rows,                       // Height of bitmap
//                                                    8,                          // Bits per component
//                                                    cvMat.step[0],              // Bytes per row
//                                                    colorSpace,                 // Colorspace
//                                                    kCGImageAlphaNoneSkipLast |
//                                                    kCGBitmapByteOrderDefault);
//
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//    CGContextRelease(contextRef);
//
//
    cv::Mat cvMatTest;
//    cv::transpose(cvMat, cvMatTest);
//
//    if  (image.imageOrientation == UIImageOrientationLeft
//         || image.imageOrientation == UIImageOrientationRight) {
//
//    }
//    else{
//        return cvMat;
//
//    }
//    cvMat.release();
//
//    cv::flip(cvMatTest, cvMatTest, 1);
    
    UIImageToMat(image, cvMatTest);

    return cvMatTest;
}

+ (cv::Mat)cvMatFromAdjustedUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    cv::Mat cvMat = [self cvMatFromUIImage:image];
    cv::Mat grayMat;
    if ( cvMat.channels() == 1 ) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv :: Mat( cvMat.rows,cvMat.cols, CV_8UC1 );
        cv::cvtColor( cvMat, grayMat, CV_BGR2GRAY );
    }
    return grayMat;
}

+ (cv::Mat)cvMatGrayFromAdjustedUIImage:(UIImage *)image
{
    cv::Mat cvMat = [self cvMatFromAdjustedUIImage:image];
    cv::Mat grayMat;
    if ( cvMat.channels() == 1 ) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv :: Mat( cvMat.rows,cvMat.cols, CV_8UC1 );
        cv::cvtColor( cvMat, grayMat, CV_BGR2GRAY );
    }
    return grayMat;
}


/**
 调节图片对比度和亮度

 @param image 原图像
 @param alpha 对比度
 @param beta 亮度
 @return 转换结果
 */
+ (UIImage *)transform:(UIImage *)image
                 alpha:(double)alpha
                  beta:(double)beta {
    
    cv::Mat src = [self cvMatFromUIImage:image];
    cv::Mat dst = cv::Mat(src.size(), src.type());
    
//    int rows = src.rows;
//    int cols = src.cols;
//    cv::Mat m;
//    src.convertTo(m, CV_32F);
//    uchar *p, *pt;
//    for (int row = 0; row < rows; row++) {
//        for (int col = 0; col < cols; col++) {
//            if(src.channels() == 1) {//单通道
//                float v = m.at<cv::Vec3f>(row, col)[0];
//                dst.at<uchar>(row, col) = cv::saturate_cast<uchar>(v*alpha + beta);
//            } else if (src.channels() == 3) { //3通道
//                for (int i=0; i< src.channels(); i++) {
//                    float v = m.at<cv::Vec3f>(row, col)[i];
//                    dst.at<cv::Vec3b>(row, col)[i] = cv::saturate_cast<uchar>(v*alpha + beta);
//                }
//            }  else if (src.channels() == 4) { //4通道
//                pt = src.ptr(row, col);
//                p = dst.ptr(row, col);
//                for (int i=0; i< src.channels(); i++) {
//                    p[i] = cv::saturate_cast<uchar>(alpha * pt[i] + beta);
//                }
//            }
//        }
//    }
    //极大提升转换效率相对于for循环
    src.convertTo(dst, -1,alpha,beta);
    
    UIImage *result = [self UIImageFromCVMat:dst];
    return result;
}
@end
