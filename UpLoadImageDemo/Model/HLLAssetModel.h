//
//  HLLAssetModel.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSInteger{
    HLLAssetModelMediaTypePhoto = 0,
    HLLAssetModelMediaTypeLivePhoto,
    HLLAssetModelMediaTypePhotoGif,
    HLLAssetModelMediaTypeVideo,
    HLLAssetModelMediaTypeAudio
    
} HLLAssetModelMediaType;



@class PHAsset;

@interface HLLAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) HLLAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;
@property (nonatomic, assign) BOOL iCloudFailed;

///用一个PHAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(HLLAssetModelMediaType)type;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(HLLAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;

@interface HLLAlbumModel : NSObject

//相册名字
@property (nonatomic, copy) NSString *name;
//相册图片
@property (nonatomic, assign) NSInteger count;
//获取结果
@property (nonatomic, strong) PHFetchResult *result;
@property (nonatomic, strong) PHAssetCollection *collection;
@property (nonatomic, strong) PHFetchOptions *options;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSInteger selectedCount;
@property (nonatomic, assign) BOOL isCameraRool;

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets;
- (void)refreshFetchResult;

@end

