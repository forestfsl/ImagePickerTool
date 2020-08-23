//
//  HLLBeautifyImageFrameController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteAddFrameBlock)(NSInteger frameCode);

@interface HLLBeautifyImageFrameController : UIViewController

@property (nonatomic, copy) CompleteAddFrameBlock completeEditBlock;

- (instancetype)initWithImage:(UIImage *)image;

@end


