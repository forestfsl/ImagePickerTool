//
//  HLLAssetCell.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

/**
 图片cell
 */


#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    HLLAssetCellTypePhoto = 0,
    HLLAssetCellTypeLivePhoto,
    HLLAssetCellTypePhotoGif,
    HLLAssetCellTypeVideo,
    HLLAssetCellTypeAudio,
} HLLAssetCellType;



@class HLLAssetModel;

@interface HLLAssetCell : UICollectionViewCell

//暴露属性给外界配置

//选择图片按钮右上角
@property (nonatomic, strong) UIButton *selectPhotoBtn;
//不能选择图片图层
@property (nonatomic, strong) UIButton *cannotSelectLayerButton;
@property (nonatomic, strong) HLLAssetModel *model;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) void(^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) HLLAssetCellType type;
//是否允许选择gif
@property (nonatomic, assign) BOOL allowPickingGif;
//是否允许选择视频
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;
//是否显示选中按钮
@property (nonatomic, assign) BOOL showSelectBtn;
//是否允许预览
@property (nonatomic, assign) BOOL allowPreview;

@property (nonatomic, copy) void (^assetCellDidSetModelBlock)(HLLAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);
@property (nonatomic, copy) void (^assetCellDidLayoutSubviewsBlock)(HLLAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);


@end


