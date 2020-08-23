//
//  HLLImageManager.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLImageManager.h"
#import "HLLAssetModel.h"
#import "HLLTemplatePickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>



@interface HLLImageManager()
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@end


@implementation HLLImageManager

CGSize AssetGridThumbnailSize;
CGFloat HLLScreenWidth;
CGFloat HLLScreenScale;

//单例属性
//全局定义是为了可以自己销毁
static HLLImageManager *manager;
static dispatch_once_t onceToken;

+ (instancetype)manager{
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager configData];
    });
    return manager;
}

+ (void)deallocManager{
    onceToken = 0;
    manager = nil;
}


- (void)configData{
    HLLScreenWidth = [UIScreen mainScreen].bounds.size.width;
    HLLScreenScale = 2.0;
    if (HLLScreenWidth > 700) {
        HLLScreenScale = 1.5;
    }
}

- (void)setPhotoWidth:(CGFloat)photoWidth{
    _photoWidth = photoWidth;
    HLLScreenWidth = photoWidth / 2;
}

- (void)setColumnNumber:(NSInteger)columnNumber{
    [self configData];
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (HLLScreenWidth - 2 * margin - 4) / columnNumber - margin;
    AssetGridThumbnailSize = CGSizeMake(itemWH * HLLScreenScale, itemWH * HLLScreenScale);
}


- (BOOL)authorizationStatusAuthorized{
    if (self.isPreviewNetworkImage) {
        return YES;
    }
    NSInteger status = [PHPhotoLibrary authorizationStatus];
    if (status == 0) {
        [self requestAuthorizationWithCompletion:nil];
    }
    return  status == 3;
}
- (void)requestAuthorizationWithCompletion:(void (^)(void))completion{
    void (^callCompletionBlock)(void) = ^(){
           dispatch_async(dispatch_get_main_queue(), ^{
               if (completion) {
                   completion();
               }
           });
       };
       
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
               callCompletionBlock();
           }];
       });
}

#pragma mark - 私有方法
- (HLLAlbumModel *)modelWithResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection isCameraRoll:(BOOL)isCameraRoll needFetchAssets:(BOOL)needFetchAssets options:(PHFetchOptions *)options{
    HLLAlbumModel *model = [[HLLAlbumModel alloc]init];
    [model setResult:result needFetchAssets:needFetchAssets];
    model.name = collection.localizedTitle;
    model.options = options;
    model.collection = collection;
    model.isCameraRool = isCameraRoll;
    model.count = result.count;
    return model;
}


///类型转换
- (HLLAssetModelMediaType)fetchAssetType:(PHAsset *)asset {
    HLLAssetModelMediaType type = HLLAssetModelMediaTypePhoto;
    PHAsset *phAsset = (PHAsset *)asset;
    if (phAsset.mediaType == PHAssetMediaTypeVideo)      type = HLLAssetModelMediaTypeVideo;
    else if (phAsset.mediaType == PHAssetMediaTypeAudio) type = HLLAssetModelMediaTypeAudio;
    else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        if (@available(iOS 9.1, *)) {
          
        }
        // Gif
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = HLLAssetModelMediaTypePhotoGif;
        }
    }
    return type;
}

- (HLLAssetModel *)assetModelWithAsset:(PHAsset *)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage{
    BOOL canSelect = YES;
    if ([self.pickerDelegate respondsToSelector:@selector(isAssetCanSelect:)]) {
        canSelect = [self.pickerDelegate isAssetCanSelect:asset];
    }
    if (!canSelect) return nil;
    
    HLLAssetModel *model;
    HLLAssetModelMediaType type = [self fetchAssetType:asset];
    if (!allowPickingVideo && type == HLLAssetModelMediaTypeVideo) return nil;
    if (!allowPickingImage && type == HLLAssetModelMediaTypePhoto) return nil;
    if (!allowPickingImage && type == HLLAssetModelMediaTypePhotoGif) return nil;
    
    PHAsset *phAsset = (PHAsset *)asset;
    if (self.hideWhenCanNotSelect) {
        if (![self isPhotoSelectableWithAsset:phAsset]) {
            return nil;
        }
    }
    
    NSString *timeLength = type == HLLAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
    timeLength = [self fetchNewTimeFromDurationSecond:timeLength.integerValue];
    model = [HLLAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    return model;
}

///获取相册
- (void)fetchCameralRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(HLLAlbumModel *model))completion{
    __block HLLAlbumModel *model;
    
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeImage];
    if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
    PHAssetMediaTypeVideo];
    if (!self.sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        //过滤空相册，不过滤也行
        if (collection.estimatedAssetCount <= 0) continue;
        if ([self isCameraRollAlbum:collection]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            //转成自定义模型
            model = [self modelWithResult:fetchResult collection:collection isCameraRoll:YES needFetchAssets:needFetchAssets options:option];
            if (completion) completion(model);
            break;
        }
    }
}

///获取相册数组
- (void)fetchAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(NSArray<HLLAlbumModel*> *models))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                PHAssetMediaTypeVideo];
    if (!self.sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
       PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
       PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
       PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
       PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
       NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount <= 0 && ![self isCameraRollAlbum:collection]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1 && ![self isCameraRollAlbum:collection]) continue;
            
            if ([self.pickerDelegate respondsToSelector:@selector(isAlbumCanSelect:result:)]) {
                if (![self.pickerDelegate isAlbumCanSelect:collection.localizedTitle result:fetchResult]) {
                    continue;
                }
            }
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
            if ([self isCameraRollAlbum:collection]) {
                [albumArr insertObject:[self modelWithResult:fetchResult collection:collection isCameraRoll:YES needFetchAssets:needFetchAssets options:option] atIndex:0];
            } else {
                [albumArr addObject:[self modelWithResult:fetchResult collection:collection isCameraRoll:NO needFetchAssets:needFetchAssets options:option]];
            }
        }
    }
    if (completion) {
        completion(albumArr);
    }
}


/// 获取Assets
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)result completion:(void (^)(NSArray<HLLAssetModel *> *models))completion{
    HLLImagePickerConfig *config = [HLLImagePickerConfig sharedInstance];
    return [self fetchAssetsFromFetchResult:result allowPickingVideo:config.allowPickingVideo allowPickingImage:config.allowPickingImage completion:completion];
}

///获取Assets数组
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HLLAlbumModel *> *models))completion{
    NSMutableArray *photoArr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        HLLAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) completion(photoArr);
}

//获取单个asset
- (void)fetchAssetsFromFetchResult:(PHFetchResult *)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HLLAssetModel *model))completion{
    PHAsset *asset;
    @try {
        asset = result[index];
    } @catch (NSException *exception) {
        if (completion) completion(nil);
        return;
    } @finally {
        //暂时不处理
    }
    HLLAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
    if (completion) completion(model);
}

///获得封面
- (PHImageRequestID)fetchPostImagewithAlbumModel:(HLLAlbumModel *)model completion:(void(^)(UIImage *postImage))completion{
    id asset = [model.result lastObject];
    if (!self.sortAscendingByModificationDate) {
        asset = [model.result firstObject];
    }
    if (!asset) {
        return -1;
    }
    return [[HLLImageManager manager] fetchPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) completion(photo);
    }];
}

//获得照片本身
- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion{
    CGFloat fullScreenWidth = HLLScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self fetchPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion{
     return [self fetchPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed{
    CGFloat fullScreenWidth = HLLScreenWidth;
    if (_photoPreviewMaxWidth > 0 && fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self fetchPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}

- (PHImageRequestID)fetchPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed{
    CGSize imageSize;
    if (photoWidth < HLLScreenWidth && photoWidth < _photoPreviewMaxWidth) {
        imageSize = AssetGridThumbnailSize;
    }else{
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * HLLScreenScale;
        
        if (aspectRatio > 1.8) {
            pixelWidth = pixelWidth * aspectRatio;
        }
        if (aspectRatio < 0.2) {
            pixelWidth = pixelWidth * 0.5;
        }
        
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    int32_t imgageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        bool cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        
        //从iCloud 下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
            options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress,error,stop,info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                if (![HLLImagePickerConfig sharedInstance].notScaleImage) {
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                }
                if (!resultImage && result) {
                    resultImage = result;
                }
                resultImage = [self fixOrientation:resultImage];
                if (completion) completion(resultImage,info,NO);
            }];
        }
    }];
    return imgageRequestID;
    
}

- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress,error, stop,info);
            }
        });
    };
    //    options.networkAccessAllowed = YES;就是这个YES 允许了下载ICloud上面的图片.
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    //requestImageForAsset 这里不使用这个方法(直接遍历出UIImage对象的时候会造成图片渲染,而requestImageDataForAsset这个方法不会)担心内存暴涨
    int32_t imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) completion(imageData, dataUTI, orientation,info);
    }];
    return imageRequestID;
}

///获取原图
//如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
- (PHImageRequestID)fetchOriginalPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion{
    return [self fetchOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo, info);
        }
    }];
}

- (PHImageRequestID)fetchOriginalPhotoWithAsset:(PHAsset *)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion{
    return [self fetchOriginalPhotoWithAsset:asset progressHandler:nil newCompletion:completion];
}

- (PHImageRequestID)fetchOriginalPhotoWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler newCompletion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    if (progressHandler) {
        [option setProgressHandler:progressHandler];
    }
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && result) {
            result = [self fixOrientation:result];
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) completion(result, info, isDegraded);
        }
    }];
}

- (PHImageRequestID)fetchOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion{
    return [self fetchOriginalPhotoDataWithAsset:asset progressHandler:nil completion:completion];
}

- (PHImageRequestID)fetchOriginalPhotoDataWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
        option.version = PHImageRequestOptionsVersionOriginal;
    }
    
    [option setProgressHandler:progressHandler];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    return [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && imageData) {
            if (completion) {
                completion (imageData,info,NO);
            }
        }
    }];
}

//保存图片
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(PHAsset *asset, NSError *error))completion{
    [self savePhotoWithImage:image location:nil completion:completion];
}

- (void)savePhotoWithImage:(UIImage *)image location:(CLLocation *)location completion:(void (^)(PHAsset *asset,NSError *error))completion{
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.location = location;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset,nil);
            }else if (error){
                NSLog(@"保存照片的时候出现了错误%@",error.localizedDescription);
                if (completion) completion(nil,error);
            }
        });
    }];
}

- (void)savePhotoWithImage:(UIImage *)image meta:(NSDictionary *)meta location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"image-%@.jpg", [formater stringFromDate:[NSDate date]]];
    NSURL *tmpURL = [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)tmpURL, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)meta);
    CGImageDestinationFinalize(destination);
    CFRelease(source);
    CFRelease(destination);
    
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:tmpURL];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                NSLog(@"保存照片出错:%@",error.localizedDescription);
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}

//保存视频
- (void)saveVideoWithUrl:(NSURL *)url completion:(void (^)(PHAsset *asset, NSError *error))completion{
    [self saveVideoWithUrl:url location:nil completion:completion];
}

- (void)saveVideoWithUrl:(NSURL *)url location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion{
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                NSLog(@"保存视频出错:%@",error.localizedDescription);
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}

//获取视频
- (void)fetchVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion{
    [self fetchVideoWithAsset:asset progressHandler:nil completion:completion];
}

- (void)fetchVideoWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *, NSDictionary *))completion{
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (completion) completion(playerItem,info);
    }];
}

//导出视频
- (void)fetchVideoOutputPathWithAsset:(PHAsset *)asset success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure{
    [self fetchVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:success failure:failure];
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    //解压
    if ([presets containsObject:presetName]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:presetName];
        NSDateFormatter *formater = [[NSDateFormatter alloc]init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/video-%@.mp4", [formater stringFromDate:[NSDate date]]];
        session.shouldOptimizeForNetworkUse = true;
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            if (failure) {
                failure(@"该视频类型暂不支持导出", nil);
            }
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
            if (videoAsset.URL && videoAsset.URL.lastPathComponent) {
                outputPath = [outputPath stringByReplacingOccurrencesOfString:@".mp4" withString:[NSString stringWithFormat:@"-%@", videoAsset.URL.lastPathComponent]];
            }
        }
        // NSLog(@"video outputPath = %@",outputPath);
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if ([HLLImagePickerConfig sharedInstance].needFixComosition) {
            AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
            if (videoComposition.renderSize.width) {
                // 修正视频转向
                session.videoComposition = videoComposition;
            }
        }
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (session.status) {
                    case AVAssetExportSessionStatusUnknown: {
                        NSLog(@"AVAssetExportSessionStatusUnknown");
                    }  break;
                    case AVAssetExportSessionStatusWaiting: {
                        NSLog(@"AVAssetExportSessionStatusWaiting");
                    }  break;
                    case AVAssetExportSessionStatusExporting: {
                        NSLog(@"AVAssetExportSessionStatusExporting");
                    }  break;
                    case AVAssetExportSessionStatusCompleted: {
                        NSLog(@"AVAssetExportSessionStatusCompleted");
                        if (success) {
                            success(outputPath);
                        }
                    }  break;
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"AVAssetExportSessionStatusFailed");
                        if (failure) {
                            failure(@"视频导出失败", session.error);
                        }
                    }  break;
                    case AVAssetExportSessionStatusCancelled: {
                        NSLog(@"AVAssetExportSessionStatusCancelled");
                        if (failure) {
                            failure(@"导出任务已被取消", nil);
                        }
                    }  break;
                    default: break;
                }
            });
        }];
    }else{
        if (failure) {
            NSString *errorMessage = [NSString stringWithFormat:@"当前设备不支持该预设:%@", presetName];
            failure(errorMessage, nil);
        }
    }
}

/// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

/// 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

- (void)fetchVideoOutputPathWithAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        AVURLAsset *videoAsset = (AVURLAsset *)asset;
        [self startExportVideoWithVideoAsset:videoAsset presetName:presetName success:success failure:failure];
    }];
}


//计算容量
- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}
//获取一组照片的大小
- (void)fetchPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion{
    if (!photos || !photos.count) {
        if (completion) completion(@"0B");
        return;
    }
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        HLLAssetModel *model = photos[i];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.networkAccessAllowed = YES;
        if (model.type == HLLAssetModelMediaTypePhotoGif) {
            options.version = PHImageRequestOptionsVersionOriginal;
        }
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (model.type != HLLAssetModelMediaTypeVideo) dataLength += imageData.length;
            assetCount++;
            //遍历完毕之后下面的语句才会执行
            if (assetCount >= photos.count) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }];
    }
}


- (BOOL)isCameraRollAlbum:(PHAssetCollection *)metadata{
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
    } else {
        return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    }
}

/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(PHAsset *)asset{
    CGSize photoSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage{
    if (!self.shouldFixOrientation) return aImage;
       
       if (aImage.imageOrientation == UIImageOrientationUp)
           return aImage;
       

       CGAffineTransform transform = CGAffineTransformIdentity;
       
       switch (aImage.imageOrientation) {
           case UIImageOrientationDown:
           case UIImageOrientationDownMirrored:
               transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
               transform = CGAffineTransformRotate(transform, M_PI);
               break;
               
           case UIImageOrientationLeft:
           case UIImageOrientationLeftMirrored:
               transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
               transform = CGAffineTransformRotate(transform, M_PI_2);
               break;
               
           case UIImageOrientationRight:
           case UIImageOrientationRightMirrored:
               transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
               transform = CGAffineTransformRotate(transform, -M_PI_2);
               break;
           default:
               break;
       }
       
       switch (aImage.imageOrientation) {
           case UIImageOrientationUpMirrored:
           case UIImageOrientationDownMirrored:
               transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
               transform = CGAffineTransformScale(transform, -1, 1);
               break;
               
           case UIImageOrientationLeftMirrored:
           case UIImageOrientationRightMirrored:
               transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
               transform = CGAffineTransformScale(transform, -1, 1);
               break;
           default:
               break;
       }
       
       // Now we draw the underlying CGImage into a new context, applying the transform
       // calculated above.
       CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                CGImageGetColorSpace(aImage.CGImage),
                                                CGImageGetBitmapInfo(aImage.CGImage));
       CGContextConcatCTM(ctx, transform);
       switch (aImage.imageOrientation) {
           case UIImageOrientationLeft:
           case UIImageOrientationLeftMirrored:
           case UIImageOrientationRight:
           case UIImageOrientationRightMirrored:
               // Grr...
               CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
               break;
               
           default:
               CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
               break;
       }
       
       // And now we just create a new UIImage from the drawing context
       CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
       UIImage *img = [UIImage imageWithCGImage:cgimg];
       CGContextRelease(ctx);
       CGImageRelease(cgimg);
       return img;
}


///缩放图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size{
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

///asset是否是视频
- (BOOL)isVideo:(PHAsset *)asset{
     return asset.mediaType == PHAssetMediaTypeVideo;
}


- (NSString *)fetchNewTimeFromDurationSecond:(NSInteger)duration{
    NSString *newTime;
       if (duration < 10) {
           newTime = [NSString stringWithFormat:@"0:0%zd",duration];
       } else if (duration < 60) {
           newTime = [NSString stringWithFormat:@"0:%zd",duration];
       } else {
           NSInteger min = duration / 60;
           NSInteger sec = duration - (min * 60);
           if (sec < 10) {
               newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
           } else {
               newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
           }
       }
       return newTime;
}

- (HLLAssetModel *)createModelWithAsset:(PHAsset *)asset{
    HLLAssetModelMediaType type = [[HLLImageManager manager] fetchAssetType:asset];
    NSString *timeLength = @"";
    if(type == HLLAssetModelMediaTypeVideo) {
        timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
    }
    timeLength = [[HLLImageManager manager] fetchNewTimeFromDurationSecond:timeLength.integerValue];
    HLLAssetModel *model = [HLLAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    return model;
    
}

#pragma clang diagnostic pop

@end
