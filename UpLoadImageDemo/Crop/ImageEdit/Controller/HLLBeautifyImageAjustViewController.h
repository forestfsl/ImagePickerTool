//
//  HLLBeautifyImageAjustViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteEditBlock)(UIImage *image);


@interface HLLBeautifyImageAjustViewController : UIViewController

@property (nonatomic, copy) CompleteEditBlock completeEditBlock;

- (instancetype)initWithImage:(UIImage *)image;

@end


