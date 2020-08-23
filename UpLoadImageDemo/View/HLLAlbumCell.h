//
//  HLLAlbumCell.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//


/**
 相册cell
 相册封面 文字说明
 */

#import <UIKit/UIKit.h>


@class HLLAlbumModel;
@interface HLLAlbumCell : UITableViewCell
@property (nonatomic, strong) HLLAlbumModel *model;
//在相册中选中的时候，回到相册显示界面显示在右边的数字
@property (nonatomic, strong) UIButton *selectedCountBtn;
@property (nonatomic, copy) void (^albumCellDidSetModelBlock)(HLLAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);
@property (nonatomic, copy) void (^albumCellDidLayoutSubViewsBlock)(HLLAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);


@end


