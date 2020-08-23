//
//  HLLCommonTools.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HLLTemplatePickerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLLCommonTools : NSObject

+ (BOOL)hll_isIPhoneX;
+ (CGFloat)hll_statusBarHeight;
+ (NSDictionary *)hll_getInfoDictionary;
+ (void)configBarBtnItem:(UIBarButtonItem *)item imagePickerVC:(HLLTemplatePickerViewController *)imagePickerVC;
+ (BOOL)hll_isRightToLeftLayout;
+ (BOOL)isICloudSyncError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
