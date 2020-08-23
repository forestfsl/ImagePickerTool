//
//  HLLImageStretchController.h
//  HLLHomeWorkReview
//
//  Created by 61_Lee on 2019/6/19.
//  Copyright © 2019 61info. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+fixOrientation.h"
#import "UIImageView+ContentFrame.h"

@class HLLImageStretchController;
@protocol MMCropDelegate <NSObject>

- (void)didFinishCropping:(UIImage *)finalCropImage
                     from:(HLLImageStretchController *)cropObj;

@end

typedef void(^CompleteEditBlock)(UIImage *image);

@interface HLLImageStretchController : UIViewController
{
    CGFloat _rotateSlider;
    CGRect _initialRect,final_Rect;
}

@property (nonatomic, assign) NSInteger homeworkId;
@property (nonatomic,   copy) CompleteEditBlock completeEditBlock;

- (instancetype)initWithImage:(UIImage *)image;

//Detect Edges
- (void)detectEdges;
- (void)closeWithCompletion:(void (^)(void))completion ;
@end
