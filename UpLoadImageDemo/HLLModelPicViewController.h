//
//  HLLModelPicViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLLModelPicViewController : UIViewController

/**
 暴露属性给外界更改
 */
@property (nonatomic, assign) BOOL canTakePhoto;//是否可以拍照
@property (nonatomic, assign) BOOL canPickImage;//是否可以选择图片

//下面暂时不支持
@property (nonatomic, assign) BOOL canTakeVideo;//是否可以排视频
@property (nonatomic, assign) BOOL isSortAscend;//照片显示顺序
@property (nonatomic, assign) BOOL canPickVideo;//是否可以选择视频
@property (nonatomic, assign) BOOL canPickGif;//是否可以选择gif
@property (nonatomic, assign) BOOL canPickOriginal;//是否可以选择原图
@property (nonatomic, assign) BOOL shouldShowSheet;//是否已sheet的方式
@property (nonatomic, assign) NSInteger maxCount;//照片最大可选择张数，设置1即为单选模式
@property (nonatomic, assign) NSInteger columnNumber;//支持的列数
@property (nonatomic, assign) BOOL canCrop;//是否支持裁剪
@property (nonatomic, assign) BOOL needCircleCrop; //是否圆形裁剪
@property (nonatomic, assign) BOOL canPickMuiltlpleVideo;//是否可以选择多个视频
@property (nonatomic, assign) BOOL shouldShowSelectIndex;//是否显示选中数字

@end

NS_ASSUME_NONNULL_END
