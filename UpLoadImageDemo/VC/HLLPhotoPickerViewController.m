//
//  HLLPhotoPickerViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/17.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLPhotoPickerViewController.h"
#import "HLLTemplatePickerViewController.h"
#import "HLLPhotoPreViewController.h"
#import "HLLAssetCell.h"
#import "HLLAssetModel.h"
#import "UIView+Helper.h"
#import "HLLImageManager.h"
#import "HLLVideoPlayerViewController.h"
#import "HLLGifPhotoPreViewController.h"
#import "HLLLocationManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "HLLImageRequestOperation.h"
#import "HLLCommonTools.h"
#import "HLLAssetCameraCell.h"

@interface HLLPhotoPickerViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, PHPhotoLibraryChangeObserver> {
    NSMutableArray *_models;
    UIView *_bottomToolBar;
    UIButton *_previewButton;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    UIView *_divideLine;
    
    BOOL _shouldScrollToBottom;
    BOOL _showTakePhotoBtn;
    
    CGFloat _offsetItemCount;
    
}

@property (nonatomic, assign) CGRect previousPreheatRect;

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) HLLCollectionView *collectionView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIImagePickerController *imagePickerVC;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

static CGSize AssetGridThumbnailSize;
static CGFloat itemMargin = 5;

@implementation HLLPhotoPickerViewController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (UIImagePickerController *)imagePickerVC{
    if (_imagePickerVC == nil) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
        _imagePickerVC.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVC.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVC.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HLLTemplatePickerViewController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[HLLTemplatePickerViewController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.isFirstAppear = YES;
    //作为配置
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    _isSelectOriginalPhoto = pickerVC.isSelectOriginalPhoto;
    _shouldScrollToBottom = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithTitle:pickerVC.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:pickerVC action:@selector(cancelButtonClick)];
    [HLLCommonTools configBarBtnItem:cancelItem imagePickerVC:pickerVC];
    self.navigationItem.rightBarButtonItem = cancelItem;
    if (pickerVC.navLeftBarButtonSettingBlock) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 44, 44);
        [leftButton addTarget:self action:@selector(navLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
        pickerVC.navLeftBarButtonSettingBlock(leftButton);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }else if (pickerVC.childViewControllers.count){
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
        [HLLCommonTools configBarBtnItem:backItem imagePickerVC:pickerVC];
        [pickerVC.childViewControllers firstObject].navigationItem.backBarButtonItem = backItem;
    }
    _showTakePhotoBtn = _model.isCameraRool && ((pickerVC.allowTakePicture && pickerVC.allowPickingImage) || (pickerVC.allowTakeVideo && pickerVC.allowPickingVideo));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
       
       self.operationQueue = [[NSOperationQueue alloc] init];
       self.operationQueue.maxConcurrentOperationCount = 3;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = 2.0;
    if ([UIScreen mainScreen].bounds.size.width > 600) {
        scale = 1.0;
    }
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    if (!_models) {
        [self fetchAssetModels];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    HLLTemplatePickerViewController *pickerPC = (HLLTemplatePickerViewController *)self.navigationController;
    pickerPC.isSelectOriginalPhoto = _isSelectOriginalPhoto;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isFirstAppear = NO;
    // [self updateCachedAssets];
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC && [pickerVC isKindOfClass:[HLLTemplatePickerViewController class]]) {
        return pickerVC.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.al_height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    BOOL isFullScreen = self.view.al_height == [UIScreen mainScreen].bounds.size.height;
    CGFloat toolBarHeight = [HLLCommonTools hll_isIPhoneX] ? 50 + (83 - 49) : 50;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden && isFullScreen) top += [HLLCommonTools hll_statusBarHeight];
        collectionViewHeight = pickerVC.showSelectBtn ? self.view.al_height - toolBarHeight - top : self.view.al_height - top;;
    } else {
        collectionViewHeight = pickerVC.showSelectBtn ? self.view.al_height - toolBarHeight : self.view.al_height;
    }
    _collectionView.frame = CGRectMake(0, top, self.view.al_width, collectionViewHeight);
    _noDataLabel.frame = _collectionView.bounds;
    CGFloat itemWH = (self.view.al_width - (self.columnNumber + 1) * itemMargin) / self.columnNumber;
    _layout.itemSize = CGSizeMake(itemWH, itemWH);
    _layout.minimumInteritemSpacing = itemMargin;
    _layout.minimumLineSpacing = itemMargin;
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetY = _offsetItemCount * (_layout.itemSize.height + _layout.minimumLineSpacing);
        [_collectionView setContentOffset:CGPointMake(0, offsetY)];
    }
    
    CGFloat toolBarTop = 0;
    if (!self.navigationController.navigationBar.isHidden) {
        toolBarTop = self.view.al_height - toolBarHeight;
    } else {
        CGFloat navigationHeight = naviBarHeight + [HLLCommonTools hll_statusBarHeight];
        toolBarTop = self.view.al_height - toolBarHeight - navigationHeight;
    }
    _bottomToolBar.frame = CGRectMake(0, toolBarTop, self.view.al_width, toolBarHeight);
    
    CGFloat previewWidth = [pickerVC.previewBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;
    if (!pickerVC.allowPreview) {
        previewWidth = 0.0;
    }
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    _previewButton.al_width = !pickerVC.showSelectBtn ? 0 : previewWidth;
    if (pickerVC.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [pickerVC.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), 0, fullImageWidth + 56, 50);
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
    }
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.al_width - _doneButton.al_width - 12, 0, _doneButton.al_width, 50);
    _numberImageView.frame = CGRectMake(_doneButton.al_x - 24 - 5, 13, 24, 24);
    _numberLabel.frame = _numberImageView.frame;
    _divideLine.frame = CGRectMake(0, 0, self.view.al_width, 1);
    
    [HLLImageManager manager].columnNumber = [HLLImageManager manager].columnNumber;
    [HLLImageManager manager].photoWidth = pickerVC.photoWidth;
    [self.collectionView reloadData];
    
    if (pickerVC.photoPickerPageDidLayoutSubviewsBlock) {
        pickerVC.photoPickerPageDidLayoutSubviewsBlock(_collectionView, _bottomToolBar, _previewButton, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel, _divideLine);
    }
}




- (void)fetchAssetModels{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (_isFirstAppear && !_model.models.count) {
        [pickerVC showProgressHUD];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!pickerVC.sortAscendingBymodificationDate && self->_isFirstAppear && self->_model.isCameraRool) {
            [[HLLImageManager manager] fetchCameralRollAlbum:pickerVC.allowPickingVideo allowPickingImage:pickerVC.allowPickingImage needFetchAssets:YES completion:^(HLLAlbumModel *model) {
                self->_model = model;
                self->_models = [NSMutableArray arrayWithArray:self->_model.models];
                [self initSubviews];
            }];
        }else if (self->_showTakePhotoBtn || self->_isFirstAppear || !self.model.models){
            [[HLLImageManager manager] fetchAssetsFromFetchResult:self->_model.result completion:^(NSArray<HLLAssetModel *> *models) {
                self->_models = [NSMutableArray arrayWithArray:models];
                [self initSubviews];
            }];
        }else{
            self->_models = [NSMutableArray arrayWithArray:self->_model.models];
            [self initSubviews];
        }
    });
}



- (void)initSubviews{
    dispatch_async(dispatch_get_main_queue(), ^{
        HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
        [pickerVC hideProgressHUD];
        
        
        [self checkSelectedModels];
        [self configCollectionView];
        //TODO
        self->_collectionView.hidden = YES;
        [self configBottomToolBar];
        [self scrollCollectionViewToBottom];
        
    });
}



- (void)configCollectionView{
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[HLLCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
            _collectionView.delegate = self;
            _collectionView.alwaysBounceHorizontal = NO;
            _collectionView.contentInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
            [self.view addSubview:_collectionView];
            [_collectionView registerClass:[HLLAssetCell class] forCellWithReuseIdentifier:NSStringFromClass([HLLAssetCell class])];
            [_collectionView registerClass:[HLLAssetCameraCell class] forCellWithReuseIdentifier:NSStringFromClass([HLLAssetCameraCell class])];
        }
        
        if (_showTakePhotoBtn) {
            _collectionView.contentSize = CGSizeMake(self.view.al_width, ((_model.count + self.columnNumber) / self.columnNumber) * self.view.al_width);
        } else {
            _collectionView.contentSize = CGSizeMake(self.view.al_width, ((_model.count + self.columnNumber - 1) / self.columnNumber) * self.view.al_width);
            if (_models.count == 0) {
                _noDataLabel = [UILabel new];
                _noDataLabel.textAlignment = NSTextAlignmentCenter;
                _noDataLabel.text = @"没有图片或者视频";
                CGFloat rgb = 153 / 256.0;
                _noDataLabel.textColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
                _noDataLabel.font = [UIFont boldSystemFontOfSize:20];
                [_collectionView addSubview:_noDataLabel];
            } else if (_noDataLabel) {
                [_noDataLabel removeFromSuperview];
                _noDataLabel = nil;
            }
        }
}

- (void)configBottomToolBar{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (!pickerVC.showSelectBtn) return;
    
    _bottomToolBar = [[UIView alloc]initWithFrame:CGRectZero];
    CGFloat rgb = 253 / 255.0;
    _bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:pickerVC.previewBtnTitleStr forState:UIControlStateNormal];
    [_previewButton setTitle:pickerVC.previewBtnTitleStr forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = pickerVC.selectedModels.count;
    
    if (pickerVC.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, [HLLCommonTools hll_isRightToLeftLayout] ? 10 : -10, 0, 0);
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitle:pickerVC.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:pickerVC.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:pickerVC.photoOriginDefImage forState:UIControlStateNormal];
        [_originalPhotoButton setImage:pickerVC.photoOriginSelImage forState:UIControlStateSelected];
        _originalPhotoButton.imageView.clipsToBounds = YES;
        _originalPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _originalPhotoButton.selected = _isSelectOriginalPhoto;
        _originalPhotoButton.enabled = pickerVC.selectedModels.count > 0;
               
        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
        _originalPhotoLabel.textColor = [UIColor blackColor];
        if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:pickerVC.doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitle:pickerVC.doneBtnTitleStr forState:UIControlStateDisabled];
    [_doneButton setTitleColor:pickerVC.okBtnTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:pickerVC.okBtnTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.enabled = pickerVC.selectedModels.count || pickerVC.alwaysEnableDoneBtn;
    
    _numberImageView = [[UIImageView alloc] initWithImage:pickerVC.photoNumberIconImage];
    _numberImageView.hidden = pickerVC.selectedModels.count <= 0;
    _numberImageView.clipsToBounds = YES;
    _numberImageView.contentMode = UIViewContentModeScaleAspectFit;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.adjustsFontSizeToFitWidth = YES;
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",pickerVC.selectedModels.count];
    _numberLabel.hidden = pickerVC.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    _divideLine = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    _divideLine.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    
    [_bottomToolBar addSubview:_divideLine];
    [_bottomToolBar addSubview:_previewButton];
    [_bottomToolBar addSubview:_doneButton];
    [_bottomToolBar addSubview:_numberImageView];
    [_bottomToolBar addSubview:_numberLabel];
    [_bottomToolBar addSubview:_originalPhotoButton];
    [self.view addSubview:_bottomToolBar];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
    
    if (pickerVC.photoPickerPageUIConfigBlock) {
        pickerVC.photoPickerPageUIConfigBlock(_collectionView, _bottomToolBar, _previewButton, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel, _divideLine);
    }
}

- (void)checkSelectedModels{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    NSArray *selectedModels = pickerVC.selectedModels;
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:selectedModels.count];
    for (HLLAssetModel *model in selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (HLLAssetModel *model in _models) {
        model.isSelected = NO;
        if ([selectedAssets containsObject:model.asset]) {
            model.isSelected = YES;
        }
    }
}

- (void)scrollCollectionViewToBottom{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (_shouldScrollToBottom && _models.count > 0) {
        NSInteger item = 0;
        if (pickerVC.sortAscendingBymodificationDate) {
            item = _models.count - 1;
            if (_showTakePhotoBtn) {
                item += 1;
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            self->_shouldScrollToBottom = NO;
            self->_collectionView.hidden = NO;
        });
    }else{
        _collectionView.hidden = NO;
    }
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.y / (_layout.itemSize.height + _layout.minimumLineSpacing);
}

#pragma mark 事件响应

- (void)originalPhotoButtonClick{
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)navLeftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)previewButtonClick {
    HLLPhotoPreViewController *photoPreviewVc = [[HLLPhotoPreViewController alloc] init];
    [self pushPhotoPrevireViewController:photoPreviewVc needCheckSelectedModels:YES];
}


- (void)pushPhotoPrevireViewController:(HLLPhotoPreViewController *)photoPreviewVc {
    [self pushPhotoPrevireViewController:photoPreviewVc needCheckSelectedModels:NO];
}

- (void)pushPhotoPrevireViewController:(HLLPhotoPreViewController *)photoPreviewVc needCheckSelectedModels:(BOOL)needCheckSelectedModels{
    __weak typeof(self) weakSelf = self;
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    [photoPreviewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        if (needCheckSelectedModels) {
            [strongSelf checkSelectedModels];
        }
        [strongSelf.collectionView reloadData];
        [strongSelf refreshBottomToolBarStatus];
    }];
    [photoPreviewVc setDoneButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf doneButtonClick];
    }];
    [photoPreviewVc setDoneButtonClickBlockCropMode:^(UIImage *cropedImage, id asset) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didGetAllPhotos:@[cropedImage] assets:@[asset] infoArr:nil];
    }];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)doneButtonClick {
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.minImagesCount && pickerVC.selectedModels.count < pickerVC.minImagesCount) {
        NSString *title = [NSString stringWithFormat:@"至少选择%ld张图片",(long)pickerVC.minImagesCount];
        [pickerVC showAlertWithTitle:title];
        return;
    }
    
    [pickerVC showProgressHUD];
    _doneButton.enabled = NO;
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *photos;
    NSMutableArray *infoArr;
    if (pickerVC.onlyReturnAsset) {
        for (NSInteger i = 0; i < pickerVC.selectedModels.count; i++) {
            HLLAssetModel *model = pickerVC.selectedModels[i];
            [assets addObject:model.asset];
        }
    }else{
        //获取图片
        photos = [NSMutableArray array];
        infoArr = [NSMutableArray array];
        //初始化数组
        for (NSInteger i = 0; i < pickerVC.selectedModels.count; i++) {
            [photos addObject:@1];
            [assets addObject:@1];
            [infoArr addObject:@1];
        }
        
        __block BOOL havenotShowAlert = YES;
        [HLLImageManager manager].shouldFixOrientation = YES;
        __block UIAlertController *alertView;
        for (NSInteger i = 0; i < pickerVC.selectedModels.count; i++) {
            HLLAssetModel *model = pickerVC.selectedModels[i];
            HLLImageRequestOperation *operation = [[HLLImageRequestOperation alloc]initWithAsset:model.asset completion:^(UIImage * _Nullable photo, NSDictionary * _Nullable info, BOOL isDegraded) {
                if (isDegraded) return;
                if (photo) {
                    if ([HLLImagePickerConfig sharedInstance].notScaleImage) {
                        photo = [[HLLImageManager manager] scaleImage:photo toSize:CGSizeMake(pickerVC.photoWidth , (int)(pickerVC.photoWidth * photo.size.height / photo.size.width))];
                    }
                    [photos replaceObjectAtIndex:i withObject:photo];
                }
                if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
                [assets replaceObjectAtIndex:i withObject:model.asset];
                
                
                for (id item in photos) {
                    if ([item isKindOfClass:[NSNumber class]]) {
                        return;
                    }
                }
                
                if (havenotShowAlert) {
                    [pickerVC hideAlertView:alertView];
                    [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
                }
                
            } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                //如果图片正在iCloud同步中
                if (progress < 1 && havenotShowAlert && !alertView) {
                    alertView = [pickerVC showAlertWithTitle:@"正在从iCloud同步照片"];
                    havenotShowAlert = NO;
                    return ;
                }
            }];
            [self.operationQueue addOperation:operation];
        }
    }
    if (pickerVC.selectedModels.count <= 0 || pickerVC.onlyReturnAsset) {
        [self didGetAllPhotos:photos assets:assets infoArr:infoArr];
    }
}


- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr {
    HLLTemplatePickerViewController *picerVC = (HLLTemplatePickerViewController *)self.navigationController;
    [picerVC hideProgressHUD];
    _doneButton.enabled = YES;
    if (picerVC.autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
        }];
    }else{
         [self callDelegateMethodWithPhotos:photos assets:assets infoArr:infoArr];
    }
}

- (void)callDelegateMethodWithPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.allowPickingVideo && pickerVC.maxImagesCount == 1) {
        if ([[HLLImageManager manager] isVideo:[assets firstObject]]) {
            if ([pickerVC.pickerDelegate respondsToSelector:@selector(hll_imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
                [pickerVC.pickerDelegate hll_imagePickerController:pickerVC didFinishPickingVideo:[photos firstObject] sourceAssets:[assets firstObject]];
            }
            if (pickerVC.didFinishPickingVideoHandle) {
                pickerVC.didFinishPickingVideoHandle([photos firstObject], [assets firstObject]);
            }
            return;
        }
    }
    
    if ([pickerVC.pickerDelegate respondsToSelector:@selector(hll_imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:)]) {
        [pickerVC.pickerDelegate hll_imagePickerController:pickerVC didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto];
    }
    if ([pickerVC.pickerDelegate respondsToSelector:@selector(hll_imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
        [pickerVC.pickerDelegate hll_imagePickerController:pickerVC didFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:_isSelectOriginalPhoto infos:infoArr];
    }
    if (pickerVC.didFinishPickingPhotosHandle) {
        pickerVC.didFinishPickingPhotosHandle(photos,assets,_isSelectOriginalPhoto);
    }
    if (pickerVC.didFinishPickingPhotosWithInfosHandle) {
        pickerVC.didFinishPickingPhotosWithInfosHandle(photos,assets,_isSelectOriginalPhoto,infoArr);
    }
}

- (void)refreshBottomToolBarStatus {
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    
    _previewButton.enabled = pickerVC.selectedModels.count > 0;
    _doneButton.enabled = pickerVC.selectedModels.count > 0 || pickerVC.alwaysEnableDoneBtn;
    
    _numberImageView.hidden = pickerVC.selectedModels.count <= 0;
    _numberLabel.hidden = pickerVC.selectedModels.count <= 0;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",pickerVC.selectedModels.count];
    
    _originalPhotoButton.enabled = pickerVC.selectedModels.count > 0;
    _originalPhotoButton.selected = (_isSelectOriginalPhoto && _originalPhotoButton.enabled);
    _originalPhotoLabel.hidden = (!_originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) [self getSelectedPhotoBytes];
    
    if (pickerVC.photoPickerPageDidRefreshStateBlock) {
        pickerVC.photoPickerPageDidRefreshStateBlock(_collectionView, _bottomToolBar, _previewButton, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel, _divideLine);;
    }
}

- (void)getSelectedPhotoBytes {
    
    if ([[HLLImagePickerConfig sharedInstance].preferredLanguage isEqualToString:@"vi"] && self.view.al_width <= 320) {
        return;
    }
    HLLTemplatePickerViewController *imagePickerVc = (HLLTemplatePickerViewController *)self.navigationController;
    [[HLLImageManager manager] fetchPhotosBytesWithArray:imagePickerVc.selectedModels completion:^(NSString *totalBytes) {
        self->_originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}


#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_showTakePhotoBtn) {
        return _models.count + 1;
    }
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    //显示拍照cell
    if ((pickerVC.sortAscendingBymodificationDate && indexPath.item >= _models.count) || (!pickerVC.sortAscendingBymodificationDate && indexPath.item == 0 && _showTakePhotoBtn)) {
        HLLAssetCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLLAssetCameraCell class]) forIndexPath:indexPath];
        cell.imageView.image = pickerVC.takePictureImage;
        if ([pickerVC.takePictureImageName isEqualToString:@"takePicture80"]) {
            cell.imageView.contentMode = UIViewContentModeCenter;
             CGFloat rgb = 223 / 255.0;
             cell.imageView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        }else{
             cell.imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        }
        return cell;
    }
    //展示照片或视频的cell
    HLLAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLLAssetCell class]) forIndexPath:indexPath];
    cell.allowPickingMultipleVideo = pickerVC.allowPickingMultipleVideo;
    cell.photoDefImage = pickerVC.photoDefImage;
    cell.photoSelImage = pickerVC.photoSelImage;
    cell.assetCellDidSetModelBlock = pickerVC.assetCellDidSetModelBlock;
    cell.assetCellDidLayoutSubviewsBlock = pickerVC.assetCellDidLayoutSubviewsBlock;
    HLLAssetModel *model;
    if (pickerVC.sortAscendingBymodificationDate || !_showTakePhotoBtn) {
        model = _models[indexPath.item];
    }else{
        model = _models[indexPath.item - 1];
    }
    cell.allowPickingGif = pickerVC.allowPickingGif;
       cell.model = model;
       if (model.isSelected && pickerVC.showSelectedIndex) {
           cell.index = [pickerVC.selectedAssetIds indexOfObject:model.asset.localIdentifier] + 1;
       }
       cell.showSelectBtn = pickerVC.showSelectBtn;
       cell.allowPreview = pickerVC.allowPreview;
       
       if (pickerVC.selectedModels.count >= pickerVC.maxImagesCount && pickerVC.showPhotoCannotSelectLayer && !model.isSelected) {
           cell.cannotSelectLayerButton.backgroundColor = pickerVC.cannotSelectLayerColor;
           cell.cannotSelectLayerButton.hidden = NO;
       } else {
           cell.cannotSelectLayerButton.hidden = YES;
       }
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_numberImageView.layer) weakLayer = _numberImageView.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakLayer) strongLayer = weakLayer;
        HLLTemplatePickerViewController *imagePickerVc = (HLLTemplatePickerViewController *)strongSelf.navigationController;
        // 1.  取消选择
        if (isSelected) {
            strongCell.selectPhotoBtn.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:imagePickerVc.selectedModels];
            for (HLLAssetModel *model_item in selectedModels) {
                if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                    [imagePickerVc removeSelectedModel:model_item];
                    break;
                }
            }
            [strongSelf refreshBottomToolBarStatus];
            if (imagePickerVc.showSelectedIndex || imagePickerVc.showPhotoCannotSelectLayer) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PHOTO_PICKER_RELOAD_NOTIFICATION" object:strongSelf.navigationController];
            }
            [UIView showOscillatoryAnimationWithLayer:strongLayer type:HLLscillatoryAnimationToSmaller];
            if (strongCell.model.iCloudFailed) {
                [strongSelf->_models replaceObjectAtIndex:indexPath.item withObject:strongCell.model];
                NSString *title = @"iCloud 同步失败";
                [pickerVC showAlertWithTitle:title];
            }
        } else {
            // 2.  选择照片,检查是否超过了最大个数的限制
            if (imagePickerVc.selectedModels.count < imagePickerVc.maxImagesCount) {
                if (!imagePickerVc.allowPreview) {
                    BOOL shouldDone = imagePickerVc.maxImagesCount == 1;
                    if (!imagePickerVc.allowPickingMultipleVideo && (model.type == HLLAssetModelMediaTypeVideo || model.type == HLLAssetModelMediaTypePhotoGif)) {
                        shouldDone = YES;
                    }
                    if (shouldDone) {
                        model.isSelected = YES;
                        [imagePickerVc addSelectedModel:model];
                        [strongSelf doneButtonClick];
                        return;
                    }
                }
                strongCell.selectPhotoBtn.selected = YES;
                model.isSelected = YES;
                [imagePickerVc addSelectedModel:model];
                if (imagePickerVc.showSelectedIndex || imagePickerVc.showPhotoCannotSelectLayer) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PHOTO_PICKER_RELOAD_NOTIFICATION" object:strongSelf.navigationController];
                }
                [strongSelf refreshBottomToolBarStatus];
                [UIView showOscillatoryAnimationWithLayer:strongLayer type:HLLscillatoryAnimationToSmaller];
            } else {
                NSString *title = [NSString stringWithFormat:@"选择数目超过%zd张数", imagePickerVc.maxImagesCount];
                [imagePickerVc showAlertWithTitle:title];
            }
        }
    };
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //去拍照
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (((pickerVC.sortAscendingBymodificationDate && indexPath.item >= _models.count) || (!pickerVC.sortAscendingBymodificationDate && indexPath.item == 0)) && _showTakePhotoBtn) {
        [self takePhoto];
        return;
    }
    //预览图片或视频
    NSInteger index = indexPath.item;
    if (!pickerVC.sortAscendingBymodificationDate && _showTakePhotoBtn) {
        index = indexPath.item - 1;
    }
    
    HLLAssetModel *model =  _models[index];
    if (model.type == HLLAssetModelMediaTypeVideo && !pickerVC.allowPickingMultipleVideo) {
        if (pickerVC.selectedModels.count > 0) {
             HLLTemplatePickerViewController *imagePickerVC = (HLLTemplatePickerViewController *)self.navigationController;
            [imagePickerVC showAlertWithTitle:@"不能同时选择视频和图片"];
        }else{
            HLLVideoPlayerViewController *videoPlayerVC = [[HLLVideoPlayerViewController alloc]init];
            videoPlayerVC.model = model;
            [self.navigationController pushViewController:videoPlayerVC animated:YES];
        }
    }else if (model.type == HLLAssetModelMediaTypePhotoGif && pickerVC.allowPickingGif && !pickerVC.allowPickingMultipleVideo){
        if (pickerVC.selectedModels.count > 0) {
              HLLTemplatePickerViewController *imagePickerVC = (HLLTemplatePickerViewController *)self.navigationController;
            [imagePickerVC showAlertWithTitle:@"不能同时选择图片和GIF图"];
        }else{
            HLLGifPhotoPreViewController *gifPreviewVC = [[HLLGifPhotoPreViewController alloc]init];
            gifPreviewVC.model = model;
            [self.navigationController pushViewController:gifPreviewVC animated:YES];
        }
    }else{
        HLLPhotoPreViewController *photoPreviewVC = [[HLLPhotoPreViewController alloc]init];
        photoPreviewVC.currentIndex = index;
        photoPreviewVC.models = _models;
        [self pushPhotoPrevireViewController:photoPreviewVC];
    }
}


- (void)addPHAsset:(PHAsset *)asset{
    HLLAssetModel *assetModel = [[HLLImageManager manager] createModelWithAsset:asset];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    [pickerVC hideProgressHUD];
    if (pickerVC.sortAscendingBymodificationDate) {
        [_models addObject:assetModel];
    }else{
        [_models insertObject:assetModel atIndex:0];
    }
    if (pickerVC.maxImagesCount <= 1) {
        if (pickerVC.allowCrop && asset.mediaType == PHAssetMediaTypeImage) {
            HLLPhotoPreViewController *photoPreviewVC = [[HLLPhotoPreViewController alloc]init];
            if (pickerVC.sortAscendingBymodificationDate) {
                photoPreviewVC.currentIndex = _models.count - 1;
            }else{
                photoPreviewVC.currentIndex = 0;
            }
            photoPreviewVC.models = _models;
            [self pushPhotoPrevireViewController:photoPreviewVC];
        }else{
            [pickerVC addSelectedModel:assetModel];
            [self doneButtonClick];
        }
        return;
    }
    if (pickerVC.selectedModels.count < pickerVC.maxImagesCount) {
        if (assetModel.type == HLLAssetCellTypeVideo && !pickerVC.allowPickingVideo) {
            //不能选择多视频的情况下，不选中拍摄的视频
        }else{
            assetModel.isSelected = YES;
            [pickerVC addSelectedModel:assetModel];
            [self refreshBottomToolBarStatus];
        }
    }
    _collectionView.hidden = YES;
    [_collectionView reloadData];
    _shouldScrollToBottom = YES;
    [self scrollCollectionViewToBottom];
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.model refreshFetchResult];
        [self fetchAssetModels];
    });
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
        [pickerVC showProgressHUD];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        if (photo) {
            [[HLLImageManager manager] savePhotoWithImage:photo meta:meta location:self.location completion:^(PHAsset *asset, NSError *error) {
                if (!error && asset) {
                    [self addPHAsset:asset];
                }else{
                    HLLTemplatePickerViewController *pickerPC = (HLLTemplatePickerViewController *)self.navigationController;
                    [pickerPC hideProgressHUD];
                }
            }];
            self.location = nil;
        }
    }else if ([type isEqualToString:@"public.movie"]){
        HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
        [pickerVC showProgressHUD];
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoURL) {
            [[HLLImageManager manager] saveVideoWithUrl:videoURL location:self.location completion:^(PHAsset *asset, NSError *error) {
                if (!error) {
                    [self addPHAsset:asset];
                }
            }];
            self.location = nil;
        }
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
}

#pragma mark 私有方法

//拍照
- (void)takePhoto{
    //获取权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)) {
        NSDictionary *infoDict = [HLLCommonTools hll_getInfoDictionary];
        NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
        if (!appName) appName = [infoDict valueForKey:@"CFBundleExecutable"];
        
        NSString *title = @"不能使用照相机";
        NSString *message = [NSString stringWithFormat:@"请允许%@访问你的照相机\n设置->隐私->照相机",appName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:settingAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self pushImagePickerController];
                });
            }
        }];
    }else{
        [self pushImagePickerController];
    }
}


- (void)pushImagePickerController{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.allowCameraLocation) {
        __weak typeof(self) weakSelf = self;
        [[HLLLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.location = [locations firstObject];
        } failureBlock:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.location = nil;
        }];
    }
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePickerVC.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        if (pickerVC.allowTakePicture) {
            [mediaTypes addObject:(NSString *)kUTTypeImage];
        }
        if (pickerVC.allowTakeVideo) {
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
            self.imagePickerVC.videoMaximumDuration = pickerVC.videoMaximunDuration;
        }
        self.imagePickerVC.mediaTypes = mediaTypes;
        if (pickerVC.UIImagePickerControllerSettingBlock) {
            pickerVC.UIImagePickerControllerSettingBlock(self.imagePickerVC);
        }
        [self presentViewController:self.imagePickerVC animated:YES completion:nil];
    }else{
        NSLog(@"模拟器无法使用照相机功能，请使用真机");
    }
}

#pragma clang diagnostic pop


@end


@implementation HLLCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
