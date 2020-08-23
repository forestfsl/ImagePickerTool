//
//  HLLConfig.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#ifndef HLLConfig_h
#define HLLConfig_h

#define COLOR_RGB(rgbValue,a) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00)>>8))/255.0 blue: ((float)((rgbValue) & 0xFF))/255.0 alpha:(a)]

#define kScreenHeight      [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth       [[UIScreen mainScreen] bounds].size.width

// 导航栏高度
#define kNavHeight              44
// 底部菜单高度
#define kTabHeight              (k_iPhoneX ? 84 : 49)
// 顶部整体高度
#define kTopHeight              (UIApplication.sharedApplication.statusBarFrame.size.height + kNavHeight)
#define KWScale (UIScreen.mainScreen.bounds.size.width/375)

// 是否iPad
#define isPad [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad

#define HColor(_hex) ColorA(_hex,1.0)
#define ColorA(_hex,_alpha) [UIColor colorWithRed:(((_hex & 0xFF0000) >> 16))/255.0 green:(((_hex &0xFF00) >>8))/255.0 blue:((_hex &0xFF))/255.0 alpha:_alpha]
#define KUIScale (UIScreen.mainScreen.bounds.size.width/750)

#endif /* HLLConfig_h */
