//
//  HLLImageManager.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//
/**
 管理资源中心
 */

#import <Foundation/Foundation.h>
#import "HLLTemplatePickerViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "HLLAssetModel.h"


@class HLLAlbumModel,HLLAssetModel;

@protocol HLLTemplatePickerViewControllerDelegate;

@interface HLLImageManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (instancetype)manager;

+ (void)deallocManager;

@property (nonatomic, weak) id<HLLTemplatePickerViewControllerDelegate> pickerDelegate;

@property (nonatomic, assign) BOOL shouldFixOrientation;

@property (nonatomic, assign) BOOL isPreviewNetworkImage;

@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

@property (nonatomic, assign) CGFloat photoWidth;

//列数
@property (nonatomic, assign) NSInteger columnNumber;

@property(nonatomic, assign) BOOL sortAscendingByModificationDate;

@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

- (BOOL)authorizationStatusAuthorized;
- (void)requestAuthorizationWithCompletion:(void (^)(void))completion;

///获取相册
- (void)fetchCameralRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(HLLAlbumModel *model))completion;

///获取相册数组
- (void)fetchAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(NSArray<HLLAlbumModel*> *models))completion;


/// 获取Assets
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)result completion:(void (^)(NSArray<HLLAssetModel *> *models))completion;

///获取Assets数组
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HLLAlbumModel *> *models))completion;

- (void)fetchAssetsFromFetchResult:(PHFetchResult *)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HLLAssetModel *model))completion;

///获得照片
- (PHImageRequestID)fetchPostImagewithAlbumModel:(HLLAlbumModel *)model completion:(void(^)(UIImage *postImage))completion;

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

///获取原图
//如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
- (PHImageRequestID)fetchOriginalPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;

- (PHImageRequestID)fetchOriginalPhotoWithAsset:(PHAsset *)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (PHImageRequestID)fetchOriginalPhotoWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler newCompletion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

- (PHImageRequestID)fetchOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion;

- (PHImageRequestID)fetchOriginalPhotoDataWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion;

//保存图片
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(PHAsset *asset, NSError *error))completion;

- (void)savePhotoWithImage:(UIImage *)image location:(CLLocation *)location completion:(void (^)(PHAsset *asset,NSError *error))completion;

- (void)savePhotoWithImage:(UIImage *)image meta:(NSDictionary *)meta location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion;

//保存视频
- (void)saveVideoWithUrl:(NSURL *)url completion:(void (^)(PHAsset *asset, NSError *error))completion;

- (void)saveVideoWithUrl:(NSURL *)url location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion;

//获取视频
- (void)fetchVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

- (void)fetchVideoWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *, NSDictionary *))completion;

//导出视频
- (void)fetchVideoOutputPathWithAsset:(PHAsset *)asset success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)fetchVideoOutputPathWithAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure;

//获取一组照片的大小
- (void)fetchPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;


- (BOOL)isCameraRollAlbum:(PHAssetCollection *)metadata;

/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(PHAsset *)asset;

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage;

///获取资源类型
- (HLLAssetModelMediaType)fetchAssetType:(PHAsset *)asset;

///缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

///判断asset是否是视频
- (BOOL)isVideo:(PHAsset *)asset;


- (NSString *)fetchNewTimeFromDurationSecond:(NSInteger)duration;

- (HLLAssetModel *)createModelWithAsset:(PHAsset *)asset;



@end

