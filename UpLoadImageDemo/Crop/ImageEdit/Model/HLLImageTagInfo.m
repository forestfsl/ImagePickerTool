//
//  HLLBeautifyCropViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//


#import "HLLImageTagInfo.h"
#import <UIKit/UIKit.h>

@implementation HLLImageTagInfo

HLLImageTagPositionProportion HLLImageTagPositionProportionMake(CGFloat x, CGFloat y)
{
    HLLImageTagPositionProportion p;
    p.x = x;
    p.y = y;
    
    return p;
}


+ (instancetype)tagInfo{
    
    return [[self alloc] init];
}

@end
