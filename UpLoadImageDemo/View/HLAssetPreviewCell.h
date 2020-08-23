//
//  HLAssetPreviewCell.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>


//作为父类使用

@class HLLAssetModel;
@interface HLAssetPreviewCell : UICollectionViewCell
@property (nonatomic, strong) HLLAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
- (void)configSubviews;
- (void)photoPreviewCollectionViewDidScroll;

@end

