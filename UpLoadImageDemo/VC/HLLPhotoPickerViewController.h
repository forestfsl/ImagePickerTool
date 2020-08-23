//
//  HLLPhotoPickerViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/17.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLLAlbumModel;

@interface HLLPhotoPickerViewController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) HLLAlbumModel *model;

@end

@interface HLLCollectionView : UICollectionView

@end


