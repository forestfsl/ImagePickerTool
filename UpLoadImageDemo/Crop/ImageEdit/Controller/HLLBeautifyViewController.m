//
//  HLLBeautifyViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/21.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLBeautifyViewController.h"
#import "HLLBeautifyNavView.h"
#import "HLLCommonTools.h"
#import "UIView+Helper.h"
#import "HLLBeautifyBottomView.h"
#import "HLLConfig.h"
#import "UIImage+Helper.h"
#import "HLLImageCropController.h"
#import "HLLImageStretchController.h"
#import "HLLBeautifyImageAjustViewController.h"
#import "HLLBeautifyImageFrameController.h"

@interface HLLBeautifyViewController ()<HLLBeautifyNavViewDelegate,HLLBeautifyBottomViewDelegate>
{
     HLLBeautifyNavView *_beautifyNavView;
    HLLBeautifyBottomView *_beautifyBottomView;
}

///表明当前第几步，从0开始表示第一步(上一步，下一步)
@property (nonatomic, assign) NSInteger stepIndex;

@property (nonatomic, strong) UIImage *tempImage;

@property (nonatomic, strong) UIImageView *contentImageView;

///操作过程中所有的临时图片数组
@property (nonatomic, strong) NSMutableArray<UIImage *> *imageArray;

@end

@implementation HLLBeautifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self configCustomNaviBar];
    [self configBottomBar];
    [self configContentImageView];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)configContentImageView{
    [self.view addSubview:self.contentImageView];
}

- (void)configBottomBar{
    _beautifyBottomView = [[HLLBeautifyBottomView alloc]initWithFrame:CGRectMake(0, kScreenHeight-340 * KUIScale, kScreenWidth, 340 * KUIScale)];
    _beautifyBottomView.delegate = self;
    [self.view addSubview:_beautifyBottomView];
}

- (void)configCustomNaviBar{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    BOOL isFullScrren = self.view.al_height == [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = isFullScrren ? [HLLCommonTools hll_statusBarHeight] : 0;
    CGFloat naviBarHeight = statusBarHeight + pickerVC.navigationBar.al_height;
    
 
    
    _beautifyNavView = [[HLLBeautifyNavView alloc]initWithFrame:CGRectMake(0, 0, self.view.al_width, naviBarHeight)];
    _beautifyNavView.backgroundColor = [UIColor blackColor];
    _beautifyNavView.delegate = self;
  
    [self.view addSubview:_beautifyNavView];
}


- (void)setSourceImage:(UIImage *)sourceImage{
    _sourceImage = sourceImage;
    _tempImage = sourceImage;
    [self initConfigData];
}

- (instancetype)initWithSourceImage:(UIImage *)sourceImage{
    self = [super init];
    if (self) {
        _sourceImage = sourceImage;
        _tempImage = sourceImage;
        [self initConfigData];
    }
    return self;
}


- (void)initConfigData{
    self.imageArray = [NSMutableArray array];
    if (self.sourceImage) {
        [self.imageArray addObject:self.sourceImage];
    }
    
}


- (UIImageView *)contentImageView{
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - kScreenWidth * 0.75) / 2, kScreenWidth, kScreenWidth * 0.75)];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        _contentImageView.image = self.sourceImage;
    }
    return _contentImageView;
}

- (void)setHasBeautified:(BOOL)hasBeautified{
    if (hasBeautified) {
        [_beautifyNavView configSureBtnBgColor:HColor(0xFF3A2F)];
    }else{
         [_beautifyNavView configSureBtnBgColor:HColor(0xC8C8C8)];
       
    }
    [_beautifyNavView configSureBtnEnable:hasBeautified];
    [_beautifyNavView configSureBtnHidden:!hasBeautified];
}



#pragma mark HLLBeautifyNavViewDelegate

///点击了返回
- (void)goBack{
    [self.navigationController popViewControllerAnimated:NO];
}

///点击了确认按钮
- (void)sureAction{
    if (self.completeBlock) {
        self.completeBlock(self.contentImageView.image);
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)reset{
    if (!(self.imageArray.count > 0)) {
        return;
    }
   UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否重置所有操作"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"重置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.stepIndex = 0;
        self.hasBeautified = NO;
        if (self.imageArray.count > 0) {
            [self.imageArray removeAllObjects];
        }
        self.photoFrameCode = 0;
        if (self.sourceImage) {
            self.contentImageView.image = self.sourceImage;
            self.tempImage = self.sourceImage;
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:resetAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)preStep{
    if (self.stepIndex - 1 < self.imageArray.count) {
        //当前步数大于0
        self.stepIndex--;
        self.tempImage = self.imageArray[self.stepIndex];
        self.contentImageView.image = self.tempImage;
        self.hasBeautified = true;
    }
}

- (void)nextStep{
    if (self.stepIndex + 1 < self.imageArray.count) {
        self.stepIndex++;
        self.tempImage = self.imageArray[self.stepIndex];
        self.contentImageView.image = self.tempImage;
        self.hasBeautified = true;
    }
}

- (void)cropImage{
    HLLImageCropController *cropVC = [[HLLImageCropController alloc]initWithImage:self.sourceImage];
    cropVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:cropVC animated:YES completion:nil];
    __weak typeof(self) weakSelf = self;
    cropVC.completeEditBlock = ^(UIImage *image) {
        if (image) {
            weakSelf.tempImage = image;
            weakSelf.contentImageView.image = image;
            [weakSelf.imageArray addObject:image];
            weakSelf.stepIndex++;
            weakSelf.hasBeautified = true;
        }
    };
}

- (void)roteLeft{
    self.tempImage= [self.tempImage hll_imageByRotateLeft90];
    self.contentImageView.image = self.tempImage;
    [self.imageArray addObject:self.tempImage];
    self.hasBeautified = true;
    self.stepIndex++;
}

- (void)roteRight{
    self.tempImage = [self.tempImage hll_imageByRotateRight90];
    self.contentImageView.image = self.tempImage;
       [self.imageArray addObject:self.tempImage];
       self.hasBeautified = true;
       self.stepIndex++;
}

- (void)stretch{
    HLLImageStretchController *strechVC = [[HLLImageStretchController alloc]initWithImage:self.tempImage];
   
    strechVC.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    [self presentViewController:strechVC animated:true completion:nil];
    _beautifyNavView.needBack = false;
    _beautifyNavView.needSure = false;
    strechVC.completeEditBlock = ^(UIImage *image) {
        if (image) {

             weakSelf.tempImage = [weakSelf generateFrameImageWith:image];
            weakSelf.contentImageView.image = weakSelf.tempImage;
            [weakSelf.imageArray addObject:weakSelf.tempImage];
            weakSelf.stepIndex++;
            weakSelf.hasBeautified = true;
        };
    };
}


- (void)adjust{
    HLLBeautifyImageAjustViewController *adjustVC = [[HLLBeautifyImageAjustViewController alloc]initWithImage:self.tempImage];
   
    
    adjustVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:adjustVC animated:YES completion:nil];
    _beautifyNavView.needBack = false;
    _beautifyNavView.needSure = false;
    __weak typeof(self) weakSelf = self;
    adjustVC.completeEditBlock = ^(UIImage *image) {
        if (image) {
            weakSelf.tempImage = image;
            weakSelf.contentImageView.image = image;
            [weakSelf.imageArray addObject:image];
            weakSelf.stepIndex++;
            weakSelf.hasBeautified = true;
        }
    };
}

- (void)frameImage{
    HLLBeautifyImageFrameController *frameVC = [[HLLBeautifyImageFrameController alloc]initWithImage:self.tempImage];
    _beautifyNavView.needBack = false;
    _beautifyNavView.needSure = false;
    frameVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:frameVC animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    frameVC.completeEditBlock = ^(NSInteger frameCode) {
        weakSelf.photoFrameCode = frameCode;
        weakSelf.tempImage = [weakSelf generateFrameImageWith:weakSelf.tempImage];
        weakSelf.contentImageView.image = weakSelf.tempImage;
        [weakSelf.imageArray addObject:weakSelf.tempImage];
        weakSelf.stepIndex++;
        weakSelf.hasBeautified = true;
    };
}

//根据相框和原始图片生成加了相框之后的图片
- (UIImage *)generateFrameImageWith:(UIImage *)sourceImage{
    if (self.photoFrameCode==0) {
        return sourceImage;
    }
    NSString *imageName = [NSString stringWithFormat:@"icon_image_border_%ld",(long)self.photoFrameCode];
    UIImage *frame = [UIImage hll_imageNamedFromBundle:imageName];
    return [[sourceImage hll_imageByResizeToSize:CGSizeMake(360*(kScreenWidth/375), 360*(kScreenWidth/375))
                                 contentMode:UIViewContentModeScaleAspectFit]
                            imageAddBorderBy:frame];
}


- (void)buttonClick:(BeautifyButtonType)type {
    switch (type) {
        case BeautifyButtonType_Reset://重置
        {
            [self reset];
        }
            break;
        case BeautifyButtonType_PreStep:
        {
            [self preStep];
        }
            break;
        case BeautifyButtonType_NextStep:
        {
            [self nextStep];
        }
            break;
        case BeautifyButtonType_Crop:
        {
            [self cropImage];
        }
            break;
        case BeautifyButtonType_Roate_Left:
        {
            [self roteLeft];
        }
            break;
        case BeautifyButtonType_Roate_Right:
        {
            [self roteRight];
        }
            break;
        case BeautifyButtonType_Stretch:
        {
            [self stretch];
        }
            break;
        case BeautifyButtonType_Ajust:
        {
            [self adjust];
        }
            break;
        case BeautifyButtonType_Frame:
        {
            [self frameImage];
        }
            break;
        default:
            break;
    }
}



@end
