//
//  HLLCommonTools.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLCommonTools.h"

@implementation HLLCommonTools

+ (BOOL)hll_isIPhoneX{
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
           CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
           CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
           CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)));
}

+ (CGFloat)hll_statusBarHeight{
    return [self hll_isIPhoneX]  ? 44 : 20;
}

+ (NSDictionary *)hll_getInfoDictionary{
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return infoDict ? infoDict : @{};
}

+ (BOOL)hll_isRightToLeftLayout{
    if (@available(iOS 9.0, *)) {
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:UISemanticContentAttributeUnspecified] == UIUserInterfaceLayoutDirectionRightToLeft) {
            return YES;
        }
    } else {
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        if ([preferredLanguage hasPrefix:@"ar-"]) {
            return YES;
        }
    }
    return NO;
}

+ (void)configBarBtnItem:(UIBarButtonItem *)item imagePickerVC:(HLLTemplatePickerViewController *)imagePickerVC{
    item.tintColor = imagePickerVC.barItemTextColor;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = imagePickerVC.barItemTextColor;
    textAttrs[NSFontAttributeName] = imagePickerVC.barItemTextFont;
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

+ (BOOL)isICloudSyncError:(NSError *)error{
    if (!error) return NO;
    if ([error.domain isEqualToString:@"CKErrorDomain"] || [error.domain isEqualToString:@"CloudPhotoLibraryErrorDomain"]) {
        return YES;
    }
    return NO;
}

@end
