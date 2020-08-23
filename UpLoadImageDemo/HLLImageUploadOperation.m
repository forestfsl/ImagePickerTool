//
//  HLLImageUploadOperation.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/18.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLImageUploadOperation.h"
#import "HLLImageManager.h"

@implementation HLLImageUploadOperation


- (void)start{
     NSLog(@"TZImageUploadOperation start");
        self.executing = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
    #pragma mark - 获取&上传大图
            /*
            [[HLLImageManager manager] fetchPhotoWithAsset:self.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!isDegraded) {
                        if (self.completedBlock) {
                            self.completedBlock(photo, info, isDegraded);
                        }
                        // 在这里上传图片(代码略)，图片上传完毕后调用[self done]
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self done];
                        });
                    }
                });
            } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.progressBlock) {
                        self.progressBlock(progress, error, stop, info);
                    }
                });
            } networkAccessAllowed:YES];
             */
            
#pragma mark - 获取&上传原图
            [[HLLImageManager manager] fetchOriginalPhotoWithAsset:self.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.progressBlock) {
                        self.progressBlock(progress, error, stop, info);
                    }
                });
            } newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!isDegraded) {
                        if (self.completedBlock) {
                            self.completedBlock(photo, info, isDegraded);
                        }
                        // 在这里上传图片(代码略)，图片上传完毕后调用[self done]
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self done];
                        });
                    }
                });
            }];
        });
}

- (void)done {
    [super done];
    // NSLog(@"TZImageUploadOperation done");
}

@end
