//
//  HLLCustomViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/19.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLCustomViewController.h"
#import <ImageIO/CGImageProperties.h>
#import "HLLModifyCamera.h"
#import <CoreMotion/CoreMotion.h>
#import "HLLConfig.h"
#import "UIImage+Helper.h"
#import "HLLCustomCameraView.h"
#import "HLLTemplatePickerViewController.h"
#import "UIView+Helper.h"
#import "HLLPhotoPickerViewController.h"



@interface HLLCustomViewController ()<HLLCustomCameraViewDelegate>
//TODO
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *videoCaptureDevice;
@property (strong, nonatomic) AVCaptureDevice *audioCaptureDevice;

@property (nonatomic, strong) HLLModifyCamera *simpleCamera;

//当前手机方向
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic ,strong) CMMotionManager * cmotionManager;
@property (nonatomic, strong) HLLCustomCameraView *cameraView;

@end

@implementation HLLCustomViewController

- (instancetype)initCustomVCWithTarget:(UIViewController *)targetVC{
    HLLCustomViewController *customVC = [[HLLCustomViewController alloc]init];
    customVC.target = targetVC;
    return customVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.maxCount = 10;
    [self startMonionManager];
    [self.simpleCamera start];//初始化相机
    
    _cameraView = [[HLLCustomCameraView alloc]initWithFrame:CGRectZero];
    _cameraView.backgroundColor = [UIColor clearColor];
    _cameraView.delegate = self;
    [self.view addSubview:_cameraView];
    
}

- (void)viewWillLayoutSubviews {
    
    NSLog(@"%s", __FUNCTION__);
    
    [super viewWillLayoutSubviews];
    
    _cameraView.frame = self.view.bounds;
}


- (void)startMonionManager{
    if (_cmotionManager == nil) {
           _cmotionManager = [[CMMotionManager alloc] init];
       }
       _cmotionManager.deviceMotionUpdateInterval = 1/15.0;
       if (_cmotionManager.deviceMotionAvailable) {
           NSLog(@"Device Motion Available");
           __weak typeof(self) weakSelf = self;
           [_cmotionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
               [weakSelf performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
               
           }];
       }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
//    double z = deviceMotion.gravity.z;
    
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            self.currentOrientation   = UIDeviceOrientationPortraitUpsideDown;
        }
        else{
            self.currentOrientation=    UIDeviceOrientationPortrait;
        }
    }
    else
    {
        if (x >= 0){
            self.currentOrientation=  UIDeviceOrientationLandscapeRight;
        }
        else{
            self.currentOrientation=  UIDeviceOrientationLandscapeLeft;
        }
    }
}


- (void)setCurrentOrientation:(UIDeviceOrientation)currentOrientation{
    self.cameraView.currentOrientation = currentOrientation;
}

#pragma mark HLLCustomCameraViewDelegate

- (void)didClickPhotoLibrary{
     HLLTemplatePickerViewController *pickerVC = [[HLLTemplatePickerViewController alloc]initWithMaxImagesCount:self.maxCount columnNumber:self.columnNumber delegate:self.target pushPhotoPickerVC:YES];
        pickerVC.allowTakePicture = YES;
        pickerVC.allowTakeVideo = NO;
        [pickerVC setUIImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
            imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        }];
        //设置是否选中当前预览图片
        pickerVC.autoSelectCurrentWhenDone = NO;

        
        pickerVC.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
        pickerVC.showPhotoCannotSelectLayer = YES;
        pickerVC.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];

        
        //设置是否可以选择视频/图片/原图
        pickerVC.allowTakeVideo = NO;
        pickerVC.allowPickingImage = YES;
        pickerVC.allowPickingOriginalPhoto = NO;
        pickerVC.allowPickingGif = NO;
        pickerVC.allowPickingMultipleVideo = NO;
        
        //照片是否需要按照升序排序
        pickerVC.sortAscendingBymodificationDate = YES;
        
        pickerVC.showSelectBtn = YES;
        pickerVC.allowCrop = NO;
        pickerVC.needCircleCrop = NO;
        
        //设置竖屏裁剪尺寸
        NSInteger left = 30;
        NSInteger widthHeight = self.view.al_width - 2 * left;
        NSInteger top = (self.view.al_height - widthHeight) / 2;
        pickerVC.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
        pickerVC.scaleAspectFillCrop = YES;
    
        
        //设置statusBarsStyle
        pickerVC.isStatusBarDefault = NO;
        pickerVC.statusBarStyle = UIStatusBarStyleLightContent;
        
        //设置图片序号
        pickerVC.showSelectedIndex = YES;
        
        // 你可以通过block或者代理，来得到用户选择的照片.
        [pickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [self dismissViewControllerAnimated:YES completion:nil];

        }];
        
        pickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:pickerVC animated:YES completion:nil];
}


- (void)didClikBackAction{
    [self.simpleCamera stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didClickTakePhoto{
    __weak typeof(self) weakSelf = self;
    // 去拍照
    [self.simpleCamera capture:^(HLLModifyCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        NSLog(@"拍照结束");
        if(!error) {
            //保存进入到图片
            if (image) {
                [[HLLImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
//                    HLLPhotoPickerViewController *photoPickerVc = [[HLLPhotoPickerViewController alloc] init];
//                    photoPickerVc.isFirstAppear = YES;
//                    photoPickerVc.columnNumber = self.columnNumber;
//                    [[HLLImageManager manager] fetchCameralRollAlbum:NO allowPickingImage:YES needFetchAssets:NO completion:^(HLLAlbumModel *model) {
//                        photoPickerVc.model = model;
//                        [strongSelf presentViewController:photoPickerVc animated:YES completion:^{
//                            [strongSelf dismissViewControllerAnimated:YES completion:nil];
//                        }];
//                    }];
//                   [strongSelf dismissViewControllerAnimated:YES completion:nil];

                    [strongSelf didClickPhotoLibrary];
                }];
            }
            
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}


- (HLLModifyCamera *)simpleCamera{
    if (!_simpleCamera) {
        //AVCaptureSessionPresetHigh 自动识别屏幕分辨率
        self.simpleCamera = [[HLLModifyCamera alloc] initWithQuality:AVCaptureSessionPresetHigh position:HLLCameraPositionRear videoEnabled:NO];
        self.simpleCamera.view.frame = self.view.frame;
        [self.simpleCamera attachToViewController:self withFrame:self.view.bounds];
        self.simpleCamera.fixOrientationAfterCapture = YES;
        
        CALayer *layer = [self getFocusLayer];
        [self.simpleCamera.view.layer addSublayer:layer];
        [self.simpleCamera alterFocusBox:layer animation:[self getFocusAnimation]];
    }
    return _simpleCamera;
}
    
- (CALayer *)getFocusLayer{
    CALayer *focusBox = [[CALayer alloc] init];
    focusBox.cornerRadius = 5.0f;
    focusBox.bounds = CGRectMake(0.0f, 0.0f, 70, 70);
    focusBox.borderWidth = 3.0f;
    focusBox.borderColor = [[UIColor greenColor] CGColor];
    focusBox.opacity = 0.0f;
    return focusBox;
}

- (CAAnimation *)getFocusAnimation{
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 0.75;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    return focusBoxAnimation;
}

-(void)dealloc{
    NSLog(@"stopDeviceMotionUpdates");
   
    [self cameraStopDeviceMotionUpdates];
}
-(void)cameraStopDeviceMotionUpdates{
     [_cmotionManager stopDeviceMotionUpdates];
}

@end
