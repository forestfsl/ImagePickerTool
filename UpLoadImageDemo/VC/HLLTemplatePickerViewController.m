//
//  HLLTemplatePickerViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLTemplatePickerViewController.h"
#import "HLLCommonTools.h"
#import "UIView+Helper.h"
#import "HLLAlbumCell.h"
#import "HLLPhotoPickerViewController.h"
#import "NSBundle+Helper.h"
#import "HLLPhotoPreViewController.h"
#import "UIImage+Helper.h"

@interface HLLTemplatePickerViewController ()
{
    
     NSTimer *_timer;
     UILabel *_tipLabel;
     UIButton *_settingBtn;
     BOOL _pushPhotoPickerVc;
     BOOL _didPushPhotoPickerVc;
     CGRect _cropRect;
     
     UIButton *_progressHUD;
     UIView *_HUDContainer;
     UIActivityIndicatorView *_HUDIndicatorView;
     UILabel *_HUDLabel;
     
     UIStatusBarStyle _originStatusBarStyle;
}

/// 默认4列, TZPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, assign) NSInteger HUDTimeoutCount; ///< 超时隐藏HUD计数


@end

@implementation HLLTemplatePickerViewController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithMaxImagesCount:10 delegate:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [HLLImageManager manager].shouldFixOrientation = NO;


    self.okBtnTitleColorNormal   = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    self.okBtnTitleColorDisabled = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImageCount delegate:(id<HLLTemplatePickerViewControllerDelegate>)delegate{
    return [self initWithMaxImagesCount:maxImageCount columnNumber:4 delegate:delegate pushPhotoPickerVC:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                          columnNumber:(NSInteger)columnNumber delegate:(id<HLLTemplatePickerViewControllerDelegate>)delegate{
     return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVC:YES];
    
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                          columnNumber:(NSInteger)columnNumber
                              delegate:(id<HLLTemplatePickerViewControllerDelegate>)delegate pushPhotoPickerVC:(BOOL)pushPhotoPickerVC{
    _pushPhotoPickerVc = pushPhotoPickerVC;
    HLLAlbumPickerController *albumPickerVC = [[HLLAlbumPickerController alloc]init];
    albumPickerVC.isFirstAppear = YES;
    albumPickerVC.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVC];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 10;
        self.pickerDelegate = delegate;
        self.selectedAssets = [NSMutableArray array];
        
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingMultipleVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.allowTakeVideo = NO;
        self.videoMaximunDuration = 10 * 60;
        self.sortAscendingBymodificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
         [self configDefaultSetting];
        if (![[HLLImageManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.al_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            _tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            NSDictionary *infoDict = [HLLCommonTools hll_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleExecutable"];
            NSString *tipText = [NSString stringWithFormat:@"允许 %@ 访问你的相册 设置 -> 隐藏 -> 相册",appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.al_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            _settingBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            [self.view addSubview:_settingBtn];
            
            if ([PHPhotoLibrary authorizationStatus] == 0) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
            }
        } else {
            [self pushPhotoPickerVc];
        }
    }
    
    return self;
}

- (void)observeAuthrizationStatusChange {
    [_timer invalidate];
    _timer = nil;
    if ([PHPhotoLibrary authorizationStatus] == 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
    }
    
    if ([[HLLImageManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];

        [self pushPhotoPickerVc];
        
        HLLAlbumPickerController *albumPickerVc = (HLLAlbumPickerController *)self.visibleViewController;
        if ([albumPickerVc isKindOfClass:[HLLAlbumPickerController class]]) {
            [albumPickerVc configTableView];
        }
    }
}


- (void)pushPhotoPickerVc {
    _didPushPhotoPickerVc = NO;
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        HLLPhotoPickerViewController *photoPickerVc = [[HLLPhotoPickerViewController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = self.columnNumber;
        [[HLLImageManager manager] fetchCameralRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage needFetchAssets:NO completion:^(HLLAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            self->_didPushPhotoPickerVc = YES;
        }];
        
    }
}


- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
    HLLPhotoPreViewController *previewVc = [[HLLPhotoPreViewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        [self configDefaultSetting];
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (!strongSelf) return;
                if (strongSelf.didFinishPickingPhotosHandle) {
                    strongSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
                }
            }];
        }];
    }
    return self;
}

- (instancetype)initCropTypeWithAsset:(PHAsset *)asset photo:(UIImage *)photo
                           completion:(void (^)(UIImage *cropImage,PHAsset *asset))completion{
    HLLPhotoPreViewController *previewVc = [[HLLPhotoPreViewController alloc] init];
       self = [super initWithRootViewController:previewVc];
       if (self) {
           self.maxImagesCount = 1;
           self.allowPickingImage = YES;
           self.allowCrop = YES;
           self.selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
           [self configDefaultSetting];
           
           previewVc.photos = [NSMutableArray arrayWithArray:@[photo]];
           previewVc.isCropImage = YES;
           previewVc.currentIndex = 0;
           __weak typeof(self) weakSelf = self;
           [previewVc setDoneButtonClickBlockCropMode:^(UIImage *cropImage, id asset) {
               __strong typeof(weakSelf) strongSelf = weakSelf;
               [strongSelf dismissViewControllerAnimated:YES completion:^{
                   if (completion) {
                       completion(cropImage,asset);
                   }
               }];
           }];
       }
       return self;
}


- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [super pushViewController:viewController animated:animated];
}

- (void)configDefaultSetting {
    self.autoSelectCurrentWhenDone = YES;
    self.timeout = 15;
    self.allowEdit = YES;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;
    // 2.2.26版本，不主动缩放图片，降低内存占用
    self.notScaleImage = YES;
    self.needFixComposition = NO;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.allowCameraLocation = YES;
    
    self.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    [self configDefaultBtnTitle];
    
    CGFloat cropViewWH = MIN(self.view.al_width, self.view.al_height) / 3 * 2;
    self.cropRect = CGRectMake((self.view.al_width - cropViewWH) / 2, (self.view.al_height - cropViewWH) / 2, cropViewWH, cropViewWH);
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture80";
    self.photoSelImageName = @"photo_sel_photoPickerVc";
    self.photoDefImageName = @"photo_def_photoPickerVc";
    self.photoNumberIconImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12]; // @"photo_number_icon";
    self.photoPreviewOriginDefImageName = @"preview_original_def";
    self.photoOriginDefImageName = @"photo_original_def";
    self.photoOriginSelImageName = @"photo_original_sel";
}


- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = @"完成";
    self.cancelBtnTitleStr = @"取消";
    self.previewBtnTitleStr = @"预览";
    self.fullImageBtnTitleStr = @"原图";
    self.settingBtnTitleStr = @"设置";
    self.processHintStr = @"处理中";
    self.editBtnTitleStr = @"编辑";
}

- (void)setAllowEdit:(BOOL)allowEdit{
    _allowEdit = allowEdit;
}

- (void)setAllowPreview:(BOOL)allowPreview{
    _allowPreview = allowPreview;
}
- (void)setNaviBgColor:(UIColor *)naviBgColor{
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor{
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
    
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont{
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance{
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.naviTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    }
    if (self.naviTitleFont) {
        textAttrs[NSFontAttributeName] = self.naviTitleFont;
    }
    self.navigationBar.titleTextAttributes = textAttrs;
}


- (void)setBarItemTextColor:(UIColor *)barItemTextColor{
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont{
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)configBarButtonItemAppearance{
    UIBarButtonItem *barItem;
       if (@available(iOS 9, *)) {
           barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HLLTemplatePickerViewController class]]];
       } else {
           barItem = [UIBarButtonItem appearanceWhenContainedIn:[HLLTemplatePickerViewController class], nil];
       }
       NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
       textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
       textAttrs[NSFontAttributeName] = self.barItemTextFont;
       [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}


- (void)setIsStatusBarDefault:(BOOL)isStatusBarDefault{
    _isStatusBarDefault = isStatusBarDefault;
       
       if (isStatusBarDefault) {
           self.statusBarStyle = UIStatusBarStyleDefault;
       } else {
           self.statusBarStyle = UIStatusBarStyleLightContent;
       }
}

- (void)setTakePictureImageName:(NSString *)takePictureImageName{
    _takePictureImageName = takePictureImageName;
    _takePictureImage = [UIImage hll_imageNamedFromBundle:takePictureImageName];
}

- (void)setPhotoSelImageName:(NSString *)photoSelImageName{
    _photoSelImageName = photoSelImageName;
    _photoSelImage = [UIImage hll_imageNamedFromBundle:photoSelImageName];
    
}

- (void)setPhotoDefImageName:(NSString *)photoDefImageName{
    _photoDefImageName = photoDefImageName;
    _photoDefImage = [UIImage hll_imageNamedFromBundle:photoDefImageName];
}

- (void)setPhotoNumberIconImageName:(NSString *)photoNumberIconImageName{
    _photoNumberIconImageName = photoNumberIconImageName;
    _photoNumberIconImage = [UIImage hll_imageNamedFromBundle:photoNumberIconImageName];
}

- (void)setPhotoPreviewOriginDefImageName:(NSString *)photoPreviewOriginDefImageName{
    _photoPreviewOriginDefImageName = photoPreviewOriginDefImageName;
    _photoPreviewOriginDefImage = [UIImage hll_imageNamedFromBundle:photoPreviewOriginDefImageName];
}

- (void)setPhotoOriginDefImageName:(NSString *)photoOriginDefImageName{
    _photoOriginDefImageName = photoOriginDefImageName;
    _photoOriginDefImage = [UIImage hll_imageNamedFromBundle:photoOriginDefImageName];
}


- (void)setPhotoOriginSelImageName:(NSString *)photoOriginSelImageName{
    _photoOriginSelImageName = photoOriginSelImageName;
    _photoOriginSelImage = [UIImage hll_imageNamedFromBundle:photoOriginSelImageName];
}


- (void)setIconThemeColor:(UIColor *)iconThemeColor{
    _iconThemeColor = iconThemeColor;
       [self configDefaultImageName];
}

- (void)setShowSelectedIndex:(BOOL)showSelectedIndex{
    _showSelectedIndex = showSelectedIndex;
    if (showSelectedIndex) {
        self.photoSelImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    }
    [HLLImagePickerConfig sharedInstance].showSelectedIndex = showSelectedIndex;
}

- (void)setShowPhotoCannotSelectLayer:(BOOL)showPhotoCannotSelectLayer{
    _showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
    [HLLImagePickerConfig sharedInstance].showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
}

- (void)setNotScaleImage:(BOOL)notScaleImage{
    _notScaleImage = notScaleImage;
    [HLLImagePickerConfig sharedInstance].notScaleImage = notScaleImage;
}

- (void)setNeedFixComposition:(BOOL)needFixComposition{
    _needFixComposition = needFixComposition;
    [HLLImagePickerConfig sharedInstance].needFixComosition = needFixComposition;
}



- (void)setMaxImagesCount:(NSInteger)maxImagesCount{
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn{
    _showSelectBtn = showSelectBtn;
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}


- (void)setAllowCrop:(BOOL)allowCrop{
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) {
        //允许裁剪的时候不能选择原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius{
    _circleCropRadius = circleCropRadius;
       self.cropRect = CGRectMake(self.view.al_width / 2 - circleCropRadius, self.view.al_height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _cropRectPortrait = cropRect;
    CGFloat widthHeight = cropRect.size.width;
    _cropRectLandscape = CGRectMake((self.view.al_height - widthHeight) / 2, cropRect.origin.x, widthHeight, widthHeight);
}

- (CGRect)cropRect {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    BOOL isFullScreen = self.view.al_height == screenHeight;
    if (isFullScreen) {
        return _cropRect;
    } else {
        CGRect newCropRect = _cropRect;
        newCropRect.origin.y -= ((screenHeight - self.view.al_height) / 2);
        return newCropRect;
    }
}

- (void)setTimeout:(NSInteger)timeout{
    _timeout = timeout;
       if (timeout < 5) {
           _timeout = 5;
       } else if (_timeout > 60) {
           _timeout = 60;
       }
}

- (void)setPickerDelegate:(id<HLLTemplatePickerViewControllerDelegate>)pickerDelegate{
    _pickerDelegate = pickerDelegate;
    [HLLImageManager manager].pickerDelegate = pickerDelegate;
}


- (void)setColumnNumber:(NSInteger)columnNumber{
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    HLLAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [HLLImageManager manager].columnNumber = _columnNumber;
}


- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable{
    minPhotoWidthSelectable = minPhotoWidthSelectable;
    [HLLImageManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable{
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
       [HLLImageManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenCanNotSelect:(BOOL)hideWhenCanNotSelect{
    _hideWhenCanNotSelect = hideWhenCanNotSelect;
    [HLLImageManager manager].hideWhenCanNotSelect = hideWhenCanNotSelect;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth{
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
       if (photoPreviewMaxWidth > 800) {
           _photoPreviewMaxWidth = 800;
       } else if (photoPreviewMaxWidth < 500) {
           _photoPreviewMaxWidth = 500;
       }
       [HLLImageManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setPhotoWidth:(CGFloat)photoWidth{
    _photoWidth = photoWidth;
    [HLLImageManager manager].photoWidth = photoWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets{
    _selectedAssets = selectedAssets;
       _selectedModels = [NSMutableArray array];
       _selectedAssetIds = [NSMutableArray array];
       for (PHAsset *asset in selectedAssets) {
           HLLAssetModel *model = [HLLAssetModel modelWithAsset:asset type:[[HLLImageManager manager] fetchAssetType:asset]];
           model.isSelected = YES;
           [self addSelectedModel:model];
       }
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    _allowPickingImage = allowPickingImage;
    [HLLImagePickerConfig sharedInstance].allowPickingImage = allowPickingImage;
    if (!allowPickingImage) {
        _allowTakePicture = NO;
    }
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo{
    _allowPickingVideo = allowPickingVideo;
    [HLLImagePickerConfig sharedInstance].allowPickingVideo = allowPickingVideo;
    if (!allowPickingVideo) {
        _allowTakeVideo = NO;
    }
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage{
    _preferredLanguage = preferredLanguage;
    [HLLImagePickerConfig sharedInstance].preferredLanguage = preferredLanguage;
    [self configDefaultBtnTitle];
}

- (void)setLanguageBundle:(NSBundle *)languageBundle{
    _languageBundle = languageBundle;
    [HLLImagePickerConfig sharedInstance].languageBundle = languageBundle;
    [self configDefaultBtnTitle];
}

- (void)setSortAscendingBymodificationDate:(BOOL)sortAscendingBymodificationDate{
    _sortAscendingBymodificationDate = sortAscendingBymodificationDate;
    [HLLImageManager manager].sortAscendingByModificationDate = sortAscendingBymodificationDate;
}


- (void)addSelectedModel:(HLLAssetModel *)model{
    [_selectedModels addObject:model];
    [_selectedAssetIds addObject:model.asset.localIdentifier];
}
- (void)removeSelectedModel:(HLLAssetModel *)model{
    [_selectedModels removeObject:model];
    [_selectedAssetIds removeObject:model.asset.localIdentifier];
}

- (UIAlertController *)showAlertWithTitle:(NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
       return alertController;
}
- (void)hideAlertView:(UIAlertController *)alertView{
    [alertView dismissViewControllerAnimated:YES completion:nil];
    alertView = nil;

}
- (void)showProgressHUD{
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    UIWindow *applicationWindow;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    } else {
        applicationWindow = [[UIApplication sharedApplication] keyWindow];
    }
    [applicationWindow addSubview:_progressHUD];
    [self.view setNeedsLayout];
    
    self.HUDTimeoutCount++;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.HUDTimeoutCount--;
        if (strongSelf.HUDTimeoutCount <= 0) {
            strongSelf.HUDTimeoutCount = 0;
            [strongSelf hideProgressHUD];
        }
    });
}
- (void)hideProgressHUD{
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius {
    if (!color) {
        color = self.iconThemeColor;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![UIApplication sharedApplication].statusBarHidden) {
            if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
        }
    });
    if (size.width > size.height) {
        _cropRect = _cropRectLandscape;
    } else {
        _cropRect = _cropRectPortrait;
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat progressHUDY = CGRectGetMaxY(self.navigationBar.frame);
    _progressHUD.frame = CGRectMake(0, progressHUDY, self.view.al_width, self.view.al_height - progressHUDY);
    _HUDContainer.frame = CGRectMake((self.view.al_width - 120) / 2, (_progressHUD.al_height - 90 - progressHUDY) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0, 40, 120, 50);
}

- (void)cancelButtonClick{
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }else{
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod{
    if (self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(hll_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate hll_imagePickerControllerDidCancel:self];
    }
    if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
}





#pragma clang diagnostic pop


@end


@interface HLLAlbumPickerController()<UITableViewDataSource,UITableViewDelegate,PHPhotoLibraryChangeObserver>
{
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArray;

@end


@implementation HLLAlbumPickerController
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)viewDidLoad{
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.isFirstAppear = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithTitle:pickerVC.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:pickerVC action:@selector(cancelButtonClick)];
    [HLLCommonTools configBarBtnItem:cancelItem imagePickerVC:pickerVC];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    [pickerVC hideProgressHUD];
    if (pickerVC.allowPickingImage) {
        self.navigationItem.title = @"图片";
    }else if (pickerVC.allowPickingVideo){
        self.navigationItem.title = @"视频";
    }
    
    if (self.isFirstAppear && !pickerVC.navLeftBarButtonSettingBlock) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self configTableView];
}


- (void)configTableView{
    if (![[HLLImageManager manager] authorizationStatusAuthorized]) {
        return;
    }
    
    if (self.isFirstAppear) {
        HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
        [pickerVC hideProgressHUD];
    }
    
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[HLLImageManager manager] fetchAllAlbums:pickerVC.allowPickingVideo allowPickingImage:pickerVC.allowPickingImage needFetchAssets:self.isFirstAppear completion:^(NSArray<HLLAlbumModel *> *models) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_albumArray = [NSMutableArray arrayWithArray:models];
                for (HLLAlbumModel *albumModel in self->_albumArray) {
                    albumModel.selectedModels = pickerVC.selectedModels;
                }
                [pickerVC hideProgressHUD];
                if (self.isFirstAppear) {
                    self.isFirstAppear = NO;
                    [self configTableView];
                }
                if (!self->_tableView) {
                    self->_tableView = [[UITableView alloc]initWithFrame:CGRectZero];
                    self->_tableView.rowHeight = 70;
                    self->_tableView.backgroundColor = [UIColor whiteColor];
                    self->_tableView.tableFooterView = [[UIView alloc] init];
                    self->_tableView.dataSource = self;
                    self->_tableView.delegate = self;
                    [self->_tableView registerClass:[HLLAlbumCell class] forCellReuseIdentifier:NSStringFromClass([HLLAlbumCell class])];
                    [self.view addSubview:self->_tableView];
                    if (pickerVC.albumPickerPageUIConfigBlock) {
                        pickerVC.albumPickerPageUIConfigBlock(self->_tableView);
                    }
                }
            });
        }];
    });
}
- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
     NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (UIStatusBarStyle)preferredStatusBarStyle {
     HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC && [pickerVC isKindOfClass:[HLLTemplatePickerViewController class]]) {
        return pickerVC.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configTableView];
    });
}



- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat tableViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.al_height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    BOOL isFullScreen = self.view.al_height == [UIScreen mainScreen].bounds.size.height;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden && isFullScreen) {
            top += [HLLCommonTools hll_statusBarHeight];
        }
        tableViewHeight = self.view.al_height - top;
    }else{
        tableViewHeight = self.view.al_height;
    }
    
    _tableView.frame = CGRectMake(0, top, self.view.al_width, tableViewHeight);
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.albumPickerPageDidLayoutSubviewsBlock) {
        pickerVC.albumPickerPageDidLayoutSubviewsBlock(_tableView);
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _albumArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HLLAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HLLAlbumCell class]) forIndexPath:indexPath];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    cell.albumCellDidLayoutSubViewsBlock = pickerVC.albumCellDidLayoutSubviewsBlock;
    cell.albumCellDidSetModelBlock = pickerVC.albumCellDidSetModelBlock;
    cell.selectedCountBtn.backgroundColor = pickerVC.iconThemeColor;
    cell.model = _albumArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HLLPhotoPickerViewController *photoPickerVc = [[HLLPhotoPickerViewController alloc] init];
       photoPickerVc.columnNumber = self.columnNumber;
       HLLAlbumModel *model = _albumArray[indexPath.row];
       photoPickerVc.model = model;
       [self.navigationController pushViewController:photoPickerVc animated:YES];
       [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma clang diagnostic pop
@end



@implementation HLLImagePickerConfig

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static HLLImagePickerConfig *config = nil;
    dispatch_once(&onceToken, ^{
        if (config == nil) {
            config = [[HLLImagePickerConfig alloc] init];
            config.preferredLanguage = nil;
            config.gifPreviewMaxImagesCount = 50;
        }
    });
    return config;
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage{
    _preferredLanguage = preferredLanguage;
      
      if (!preferredLanguage || !preferredLanguage.length) {
          preferredLanguage = [NSLocale preferredLanguages].firstObject;
      }
      if ([preferredLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
          preferredLanguage = @"zh-Hans";
      } else if ([preferredLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
          preferredLanguage = @"zh-Hant";
      } else if ([preferredLanguage rangeOfString:@"vi"].location != NSNotFound) {
          preferredLanguage = @"vi";
      } else {
          preferredLanguage = @"en";
      }
      _languageBundle = [NSBundle bundleWithPath:[[NSBundle hll_fetchBundle] pathForResource:preferredLanguage ofType:@"lproj"]];
}

@end
