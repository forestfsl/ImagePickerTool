//
//  HLLPhotoPreViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//



/**
 预览控制器
 --------------------——
 |<                  √|
 |--------------------|
 |                    |
 |                    |
 |                    |
 |                    |
 |--------------------|
 |原图             完 成|
 |____________________|
 */

#import <UIKit/UIKit.h>



@interface HLLPhotoPreViewController : UIViewController

//所有图片模型数组
@property (nonatomic, strong) NSMutableArray *models;
//所有图片数组
@property (nonatomic, strong) NSMutableArray *photos;
//当前点击的图片索引
@property (nonatomic, assign) NSInteger currentIndex;
//是否支持返回原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
//是否裁剪图片
@property (nonatomic, assign) BOOL isCropImage;

//返回最新选择的图片数组
@property (nonatomic, copy) void (^backButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode)(UIImage *cropedImage,id asset);
@property (nonatomic, copy) void(^doneButtonClickBlockWithPreviewType)(NSArray<UIImage *> *phtoos,NSArray *assets,BOOL isSelecrOriginalPhoto);

@end


