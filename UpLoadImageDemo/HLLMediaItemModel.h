//
//  HLLMediaItemModel.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/19.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HLLMediaItemModel : NSObject

@property (nonatomic, strong) UIImage *mediaImage;

@property (nonatomic, assign) BOOL isSuccess;

@property (nonatomic, strong) PHAsset* asset;

@end


