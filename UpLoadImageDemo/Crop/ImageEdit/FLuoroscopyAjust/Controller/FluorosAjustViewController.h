//
//  CropViewController.h
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIImage+fixOrientation.h"
#import "UIImageView+ContentFrame.h"

@class FluorosAjustViewController;
@protocol MMCropDelegate <NSObject>

- (void)didFinishCropping:(UIImage *)finalCropImage from:(FluorosAjustViewController *)cropObj;

@end

@interface FluorosAjustViewController : UIViewController{
    CGFloat _rotateSlider;
    CGRect _initialRect,final_Rect;
}

@property (strong, nonatomic) UIImageView *sourceImageView;
@property (strong, nonatomic) UIButton *dismissBut;
@property (strong, nonatomic) UIButton *cropBut;
@property (strong, nonatomic) UIButton *rightRotateBut;
@property (strong, nonatomic) UIButton *leftRotateBut;
@property (weak,   nonatomic) id<MMCropDelegate> cropdelegate;


@property (strong, nonatomic) UIImage *adjustedImage,*cropgrayImage,*cropImage;

//- (IBAction)cropAction:(id)sender;
//- (IBAction)dismissAction:(id)sender;
//- (IBAction)rightRotateAction:(id)sender;
//- (IBAction)leftRotateAction:(id)sender;

//Detect Edges
- (void)detectEdges;
- (void)closeWithCompletion:(void (^)(void))completion ;
@end
