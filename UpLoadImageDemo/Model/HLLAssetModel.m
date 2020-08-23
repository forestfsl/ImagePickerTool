//
//  HLLAssetModel.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLAssetModel.h"
#import "HLLImageManager.h"

@implementation HLLAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(HLLAssetModelMediaType)type{
    HLLAssetModel *model = [[HLLAssetModel alloc]init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(HLLAssetModelMediaType)type timeLength:(NSString *)timeLength{
    HLLAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end


@implementation HLLAlbumModel

- (void)checkSelectedModels{
    //初始化
    self.selectedCount = 0;
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:_selectedModels.count];
    for (HLLAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model];
    }
    
    for (HLLAssetModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount++;
        }
    }
}



- (NSString *)name{
    if (_name.length > 0) {
        return _name;
    }
    return @"";
}



- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets{
    _result = result;
    if (needFetchAssets) {
        [[HLLImageManager manager] fetchAssetsFromFetchResult:result completion:^(NSArray<HLLAssetModel *> *models) {
            self->_models = models;
            if (self->_selectedModels) {
                [self checkSelectedModels];
            }
        }];
    }
}

- (void)refreshFetchResult{
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:self.options];
    [self setResult:fetchResult];
}

@end
