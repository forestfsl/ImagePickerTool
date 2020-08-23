//
//  HLLPhotoPreViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLPhotoPreViewController.h"
#import "HLLPhotoPreviewView.h"
#import "HLAssetPreviewCell.h"
#import "HLLPhotoPreViewCell.h"
#import "UIView+Helper.h"
#import "HLLImageManager.h"
#import "HLLTemplatePickerViewController.h"
#import "HLLImageCropManager.h"
#import "UIImage+Helper.h"
#import "HLLVideoPreviewCell.h"
#import "HLLGifPreviewCell.h"
#import "HLLCommonTools.h"

#import "HLLBeautifyViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface HLLPhotoPreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    NSArray *_photosTemp;
    NSArray *_assetsTemp;
    
    //顶部导航栏
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    UILabel *_indexLabel;
    
    //底部toolBar
    UIView *_toolBar;
    UIButton *_doneButton;
    UIImageView *_numberImageView;
    UILabel *_numberLabel;
    //原图
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    //编辑
    UIButton *_editPhotoButton;
    
    //移动的张数
    CGFloat _offsetItemCount;
    
    BOOL _didSetIsSelectoriginalPhoto;
   
}


@property (nonatomic, assign) BOOL isHideNaviBar;
@property (nonatomic, strong) UIView *cropBgView;
@property (nonatomic, strong) UIView *cropView;

@property (nonatomic, assign) double progress;
@property (nonatomic, strong) UIAlertController *alertView;
@property (nonatomic, strong) UIView *iCloudErrorView;

@end

@implementation HLLPhotoPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [HLLImageManager manager].shouldFixOrientation = YES;
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (!_didSetIsSelectoriginalPhoto) {
        _isSelectOriginalPhoto = pickerVC.isSelectOriginalPhoto;
    }
    if (!self.models.count) {
        self.models = [NSMutableArray arrayWithArray:pickerVC.selectedModels];
        _assetsTemp = [NSMutableArray arrayWithArray:pickerVC.selectedAssets];
    }
    [self setupSubView];
    self.view.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((self.view.al_width + 20) * self.currentIndex, 0) animated:NO];
    }
    [self refreshNaviBarAndBottomBarState];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [HLLImageManager manager].shouldFixOrientation = NO;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    BOOL isFullScrren = self.view.al_height == [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = isFullScrren ? [HLLCommonTools hll_statusBarHeight] : 0;
    CGFloat statusBarHeightInterval = isFullScrren ? (statusBarHeight - 20) : 0;
    CGFloat naviBarHeight = statusBarHeight + pickerVC.navigationBar.al_height;
    
    _naviBar.frame = CGRectMake(0, 0, self.view.al_width, naviBarHeight);
    _backButton.frame = CGRectMake(10, 10 + statusBarHeightInterval, 44, 44);
    _selectButton.frame = CGRectMake(self.view.al_width - 56, 10 + statusBarHeightInterval, 44, 44);
    _indexLabel.frame = _selectButton.frame;
       
    _layout.itemSize = CGSizeMake(self.view.al_width + 20, self.view.al_height);
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _collectionView.frame = CGRectMake(-10, 0, self.view.al_width + 20, self.view.al_height);
    [_collectionView setCollectionViewLayout:_layout];
    if (_offsetItemCount > 0) {
        CGFloat offsetX = _offsetItemCount * _layout.itemSize.width;
        [_collectionView setContentOffset:CGPointMake(offsetX, 0)];
    }
    if (pickerVC.allowCrop) {
        [_collectionView reloadData];
    }
       
    CGFloat toolBarHeight = [HLLCommonTools hll_isIPhoneX] ? 44 + (83 - 49) : 44;
    CGFloat toolBarTop = self.view.al_height - toolBarHeight;
    _toolBar.frame = CGRectMake(0, toolBarTop, self.view.al_width, toolBarHeight);
    if (pickerVC.allowPickingOriginalPhoto) {
        CGFloat fullImageWidth = [pickerVC.fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        _originalPhotoButton.frame = CGRectMake((self.view.bounds.size.width - fullImageWidth - 56) / 2, 0, fullImageWidth + 56, 44);
        _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 42, 0, 80, 44);
       }
    if (pickerVC.allowEdit) {
        [_editPhotoButton sizeToFit];
        _editPhotoButton.frame = CGRectMake(12, 0, _editPhotoButton.al_width, 44);
    }
    
  
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.al_width - _doneButton.al_width - 12, 0, _doneButton.al_width, 44);
    _numberImageView.frame = CGRectMake(_doneButton.al_x - 24 - 5, 10, 24, 24);
    _numberLabel.frame = _numberImageView.frame;
       
    [self configCropView];
       
       if (pickerVC.photoPreviewPageDidLayoutSubviewsBlock) {
           pickerVC.photoPreviewPageDidLayoutSubviewsBlock(_collectionView, _naviBar, _backButton, _selectButton, _indexLabel, _toolBar, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel);
       }
}

- (void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshSelectButtonImageViewContentMode{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           if (self->_selectButton.imageView.image.size.width <= 27) {
               self->_selectButton.imageView.contentMode = UIViewContentModeCenter;
           } else {
               self->_selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
           }
       });
}

- (void)refreshNaviBarAndBottomBarState{
    HLLTemplatePickerViewController *pickerPC = (HLLTemplatePickerViewController *)self.navigationController;
    HLLAssetModel *model = _models[self.currentIndex];
    _selectButton.selected = model.isSelected;
    [self refreshSelectButtonImageViewContentMode];
    
    if (_selectButton.isSelected && pickerPC.showSelectedIndex && pickerPC.showSelectBtn) {
        NSString *index = [NSString stringWithFormat:@"%d",(int)[pickerPC.selectedAssetIds indexOfObject:model.asset.localIdentifier] + 1];
        _indexLabel.text = index;
        _indexLabel.hidden = NO;
    }else{
        _indexLabel.hidden = YES;
    }
    
    _numberLabel.text = [NSString stringWithFormat:@"%zd",pickerPC.selectedModels.count];
    _numberImageView.hidden = (pickerPC.selectedModels.count <= 0 || _isHideNaviBar || _isCropImage);
    _numberLabel.hidden = (pickerPC.selectedModels.count <= 0 || _isHideNaviBar || _isCropImage);
    
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    
    if (_isSelectOriginalPhoto) [self showPhotoBytes];
    
    //如果正在预览的是视频，隐藏原图按钮
    if (!_isHideNaviBar) {
        if (model.type == HLLAssetModelMediaTypeVideo) {
            _originalPhotoButton.hidden = YES;
            _originalPhotoLabel.hidden = YES;
        }else{
            _originalPhotoButton.hidden = NO;
            if (_isSelectOriginalPhoto) _originalPhotoLabel.hidden = NO;
        }
    }
    
    _doneButton.hidden = NO;
    _selectButton.hidden = !pickerPC.showSelectBtn;
    
    if (![[HLLImageManager manager] isPhotoSelectableWithAsset:model.asset]) {
        _numberLabel.hidden = YES;
        _numberImageView.hidden = YES;
        _selectButton.hidden = YES;
        _originalPhotoButton.hidden = YES;
        _originalPhotoLabel.hidden = YES;
        _doneButton.hidden = YES;
    }
    
    [self didICloudSyncStatusChanged:model];
    
    if (pickerPC.photoPreviewPageDidRefreshStateBlock) {
         pickerPC.photoPreviewPageDidRefreshStateBlock(_collectionView, _naviBar, _backButton, _selectButton, _indexLabel, _toolBar, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel);
    }
}

- (void)didICloudSyncStatusChanged:(HLLAssetModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
        if (pickerVC.onlyReturnAsset) {
            return ;
        }
        HLLAssetModel *currentModel = self.models[self.currentIndex];
        if (pickerVC.selectedModels.count <= 0) {
            self->_doneButton.enabled = !currentModel.iCloudFailed;
        }else{
            self->_doneButton.enabled = YES;
        }
        self->_selectButton.hidden = currentModel.iCloudFailed || !pickerVC.showSelectBtn;
        self->_originalPhotoButton.hidden = currentModel.iCloudFailed;
        self->_originalPhotoLabel.hidden = currentModel.iCloudFailed;
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupSubView{
    [self configCollectionView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
}

- (void)configCollectionView{
    _layout = [[UICollectionViewFlowLayout alloc]init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.view.al_width + 20), 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[HLLPhotoPreViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HLLPhotoPreViewCell class])];
    [_collectionView registerClass:[HLLVideoPreviewCell class] forCellWithReuseIdentifier:NSStringFromClass([HLLVideoPreviewCell class])];
    [_collectionView registerClass:[HLLGifPreviewCell class] forCellWithReuseIdentifier:NSStringFromClass([HLLGifPreviewCell class])];
    
}


- (void)configCropView{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.maxImagesCount <= 1 && pickerVC.allowCrop && pickerVC.allowPickingImage) {
        [_cropView removeFromSuperview];
        [_cropBgView removeFromSuperview];
        
        _cropBgView = [UIView new];
        _cropBgView.userInteractionEnabled = NO;
        _cropBgView.frame = self.view.bounds;
        [self.view addSubview:_cropBgView];
        [HLLImageCropManager overlayClippingwWithViewV:_cropBgView cropRect:pickerVC.cropRect containerView:self.view needCircleCrop:pickerVC.needCircleCrop];
        
        _cropView = [UIView new];
        _cropView.userInteractionEnabled = NO;
        _cropView.frame = pickerVC.cropRect;
        _cropView.backgroundColor = [UIColor clearColor];
        _cropView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropView.layer.borderWidth = 1.0;
        if (pickerVC.needCircleCrop) {
            _cropView.layer.cornerRadius = pickerVC.cropRect.size.width / 2;
            _cropBgView.clipsToBounds = YES;
        }
        [self.view addSubview:_cropView];
        if (pickerVC.cropViewSettingBlock) {
            pickerVC.cropViewSettingBlock(_cropView);
        }
        [self.view bringSubviewToFront:_naviBar];
        [self.view bringSubviewToFront:_toolBar];
    }
}

- (void)configCustomNaviBar{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    
    _naviBar = [[UIView alloc]initWithFrame:CGRectZero];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    
    _backButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [_backButton setImage:[UIImage hll_imageNamedFromBundle:@"navi_back"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [_selectButton setImage:pickerVC.photoDefImage forState:UIControlStateNormal];
    [_selectButton setImage:pickerVC.photoSelImage forState:UIControlStateSelected];
    _selectButton.imageView.clipsToBounds = YES;
    _selectButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    _selectButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    _selectButton.hidden = !pickerVC.showSelectBtn;
    
    _indexLabel = [[UILabel alloc]init];
    _indexLabel.adjustsFontSizeToFitWidth = YES;
    _indexLabel.font = [UIFont systemFontOfSize:14];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    
    [_naviBar addSubview:_selectButton];
    [_naviBar addSubview:_indexLabel];
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}

- (void)configBottomToolBar{
    _toolBar = [[UIView alloc]initWithFrame:CGRectZero];
    static CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, [HLLCommonTools hll_isRightToLeftLayout] ? 10 : - 10, 0, 0);
        _originalPhotoButton.backgroundColor = [UIColor clearColor];
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
         _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_originalPhotoButton setTitle:pickerVC.fullImageBtnTitleStr forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:pickerVC.fullImageBtnTitleStr forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:pickerVC.photoPreviewOriginDefImage forState:UIControlStateNormal];
        [_originalPhotoButton setImage:pickerVC.photoOriginSelImage forState:UIControlStateSelected];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _originalPhotoLabel = [[UILabel alloc]init];
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:13];
        _originalPhotoLabel.textColor = [UIColor whiteColor];
        _originalPhotoLabel.backgroundColor = [UIColor clearColor];
        
        if (_isSelectOriginalPhoto) {
            [self showPhotoBytes];
        }
    }
    
    if (pickerVC.allowEdit) {
         _editPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editPhotoButton.backgroundColor = [UIColor clearColor];
        [_editPhotoButton addTarget:self action:@selector(editPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_editPhotoButton setTitle:pickerVC.editBtnTitleStr forState:UIControlStateNormal];
        [_editPhotoButton setTitle:pickerVC.editBtnTitleStr forState:UIControlStateSelected];
        [_editPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _editPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
    }
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitleColor:pickerVC.okBtnTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitle:pickerVC.doneBtnTitleStr forState:UIControlStateNormal];
    
    
    //选中图片
    _numberImageView = [[UIImageView alloc]initWithImage:pickerVC.photoNumberIconImage];
    _numberImageView.backgroundColor = [UIColor clearColor];
    _numberImageView.clipsToBounds = YES;
    _numberImageView.contentMode = UIViewContentModeScaleAspectFit;
    _numberImageView.hidden = pickerVC.selectedModels.count <= 0;
    //选中数字
    _numberLabel = [[UILabel alloc]init];
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.adjustsFontSizeToFitWidth = YES;
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",pickerVC.selectedModels.count];
    _numberLabel.hidden = pickerVC.selectedModels.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    [_originalPhotoButton addSubview:_originalPhotoLabel];
    [_toolBar addSubview:_doneButton];
    [_toolBar addSubview:_originalPhotoButton];
    [_toolBar addSubview:_editPhotoButton];
    [_toolBar addSubview:_numberImageView];
    [_toolBar addSubview:_numberLabel];
    [self.view addSubview:_toolBar];
    
    if (pickerVC.photoPreviewPageUIConfigBlock) {
        pickerVC.photoPreviewPageUIConfigBlock(_collectionView, _naviBar, _backButton, _selectButton, _indexLabel, _toolBar, _originalPhotoButton, _originalPhotoLabel, _doneButton, _numberImageView, _numberLabel);
    }
}

- (void)setIsSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    _didSetIsSelectoriginalPhoto = YES;
}

- (void)setPhotos:(NSMutableArray *)photos{
    _photos = photos;
    _photosTemp = [NSArray arrayWithArray:photos];
}

#pragma mark 事件响应


#pragma mark 返回按钮
- (void)backButtonClick{
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        if ([self.navigationController isKindOfClass:[HLLTemplatePickerViewController class]]) {
            HLLTemplatePickerViewController *pickerNav = (HLLTemplatePickerViewController *)self.navigationController;
            if (pickerNav.imagePickerControllerDidCancelHandle) {
                pickerNav.imagePickerControllerDidCancelHandle();
            }
        }
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(_isSelectOriginalPhoto);
    }
}

#pragma mark 选中图片按钮
- (void)select:(UIButton *)sender{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    HLLAssetModel *model = _models[self.currentIndex];
    if (!sender.isSelected) {
        //检查是否超过最大显示个数
        if (pickerVC.selectedModels.count >= pickerVC.maxImagesCount) {
            NSString *title = [NSString stringWithFormat:@"选择照片已经超过了%zd张照片",pickerVC.maxImagesCount];
            [pickerVC showAlertWithTitle:title];
        }else{
            //如果没有超过最大个数的限制
            [pickerVC addSelectedModel:model];
            if (self.photos) {
                [pickerVC.selectedAssets addObject:_assetsTemp[self.currentIndex]];
                [self.photos addObject:_photosTemp[self.currentIndex]];
            }
            if (model.type == HLLAssetModelMediaTypeVideo && !pickerVC.allowPickingMultipleVideo) {
                [pickerVC showAlertWithTitle:@"多选状态下选择视频，默认将视频当图片发送"];
            }
        }
    }else{
        NSArray *selectedModels= [NSArray arrayWithArray:pickerVC.selectedModels];
        for (HLLAssetModel *model_item in selectedModels) {
            if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                NSArray *selectedModeslTmp = [NSArray arrayWithArray:pickerVC.selectedModels];
                for (NSInteger i = 0; i < selectedModeslTmp.count; i++) {
                    HLLAssetModel *model = selectedModeslTmp[i];
                    if ([model isEqual:model_item]) {
                        [pickerVC removeSelectedModel:model];
                        break;
                    }
                }
                if (self.photos) {
                    NSArray *selectedAssetsTmp = [NSArray arrayWithArray:pickerVC.selectedAssets];
                    for (NSInteger i = 0; i < selectedAssetsTmp.count; i++) {
                        id asset = selectedAssetsTmp[i];
                        if ([asset isEqual:_assetsTemp[self.currentIndex]]) {
                            [pickerVC.selectedAssets removeObjectAtIndex:i];
                            break;
                        }
                        
                    }
                    [self.photos removeObject:_photosTemp[self.currentIndex]];
                }
                break;
            }
        }
    }
    model.isSelected = !sender.isSelected;
    [self refreshNaviBarAndBottomBarState];
    if (model.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:sender.imageView.layer type:HLLscillatoryAnimationToBigger];
    }
    [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:HLLscillatoryAnimationToSmaller];
}




#pragma mark 编辑
- (void)editPhotoButtonClick{
     HLLAssetModel *model = _models[self.currentIndex];
    HLLBeautifyViewController *beautiViewController = [[HLLBeautifyViewController alloc]init];
    [[HLLImageManager manager] fetchPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        beautiViewController.sourceImage = photo;
        beautiViewController.completeBlock = ^(UIImage *image) {
            [[HLLImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error) {
                //保存之后需要继续显示还是退回到上一个控制器，可以在这里控制，如果想继续浏览则刷新即可，否则直接保存之后pop即可
                model.asset = asset;
                [self->_collectionView reloadData];
//                [self.navigationController popViewControllerAnimated:YES];
            }];
           
        };
        if ([[self.navigationController childViewControllers] containsObject:beautiViewController]) return ;
           [self.navigationController pushViewController:beautiViewController animated:NO];

       } progressHandler:nil networkAccessAllowed:YES];


}
#pragma mark  按钮点击
- (void)doneButtonClick{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    //如果图片正在从iCloud同步，需要提醒用户
    if (_progress > 0 && _progress < 1 && (_selectButton.isSelected || !pickerVC.selectedModels.count)) {
        _alertView = [pickerVC showAlertWithTitle:@"正在同步iCloud照片"];
        return;
    }
    //如果没有选中过照片，点击确定时，选中当前预览的照片
    if (pickerVC.selectedModels.count == 0 && pickerVC.minImagesCount <= 0 && pickerVC) {
        [self select:_selectButton];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    HLLPhotoPreViewCell *cell = (HLLPhotoPreViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if (pickerVC.allowCrop && [cell isKindOfClass:[HLLPhotoPreViewCell class]]) {
        //裁剪状态
        _doneButton.enabled = NO;
        [pickerVC showProgressHUD];
        UIImage *cropedImage = [HLLImageCropManager cropImageView:cell.previewView.imageView toRect:pickerVC.cropRect zoomScale:cell.previewView.scrollView.zoomScale containerView:self.view];
        if (pickerVC.needCircleCrop) {
            cropedImage = [HLLImageCropManager circularClipImage:cropedImage];
        }
        _doneButton.enabled = YES;
        [pickerVC hideProgressHUD];
        if (self.doneButtonClickBlockCropMode) {
            HLLAssetModel *model = _models[self.currentIndex];
            self.doneButtonClickBlockCropMode(cropedImage, model.asset);
        }
    }else if (self.doneButtonClickBlock){
        //非裁剪状态
        self.doneButtonClickBlock(_isSelectOriginalPhoto);
    }
    if (self.doneButtonClickBlockWithPreviewType) {
        self.doneButtonClickBlockWithPreviewType(self.photos, pickerVC.selectedAssets, self.isSelectOriginalPhoto);
    }
}

#pragma mark 原图按钮点击
- (void)originalPhotoButtonClick{
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) {
            //如果当前选择照片张数 < 最大可选张数 && 最大可选张数大于1，就选中该张图
            HLLTemplatePickerViewController *imagePickerVC = (HLLTemplatePickerViewController *)self.navigationController;
            if (imagePickerVC.selectedModels.count < imagePickerVC.maxImagesCount && imagePickerVC.showSelectBtn) {
                [self select:_selectButton];
            }
        }
    }
}

#pragma mark 点击预览cell
- (void)didTapPreviewCell{
    self.isHideNaviBar = !self.isHideNaviBar;
    _naviBar.hidden = self.isHideNaviBar;
    _toolBar.hidden = self.isHideNaviBar;
}

- (void)showPhotoBytes{
    [[HLLImageManager manager] fetchPhotosBytesWithArray:@[_models[self.currentIndex]] completion:^(NSString *totalBytes) {
        self->_originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

-(NSInteger)currentIndex{
    return [HLLCommonTools hll_isRightToLeftLayout] ? self.models.count - _currentIndex - 1 : _currentIndex;
}

#pragma mark - Notification

- (void)didChangeStatusBarOrientationNotification:(NSNotification *)noti {
    _offsetItemCount = _collectionView.contentOffset.x / _layout.itemSize.width;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth + ((self.view.al_width + 20) * 0.5);
    NSInteger currentIndex = offSetWidth / (self.view.al_width + 20);
    if (currentIndex < _models.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewCollectionViewDidScroll" object:nil];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    
    HLLAssetModel *model = _models[indexPath.item];
    
    HLAssetPreviewCell *cell;
    
    __weak typeof(self) weakSelf = self;
    if (pickerVC.allowPickingMultipleVideo && model.type == HLLAssetModelMediaTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLLVideoPreviewCell class]) forIndexPath:indexPath];
        HLLVideoPreviewCell *currentCell = (HLLVideoPreviewCell *)cell;
        currentCell.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            model.iCloudFailed = isSyncFailed;
            [weakSelf didICloudSyncStatusChanged:model];
            [weakSelf.models replaceObjectAtIndex:indexPath.item withObject:model];
        };
        
    }else if (pickerVC.allowPickingMultipleVideo && model.type == HLLAssetModelMediaTypePhotoGif && pickerVC.allowPickingGif){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLLGifPreviewCell class]) forIndexPath:indexPath];
        HLLGifPreviewCell *currentCell = (HLLGifPreviewCell *)cell;
        currentCell.previewView.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            model.iCloudFailed = isSyncFailed;
            [weakSelf didICloudSyncStatusChanged:model];
            [weakSelf.models replaceObjectAtIndex:indexPath.item withObject:model];
        };
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLLPhotoPreViewCell class]) forIndexPath:indexPath];
        HLLPhotoPreViewCell *photoPreviewCell = (HLLPhotoPreViewCell *)cell;
        photoPreviewCell.cropRect = pickerVC.cropRect;
        photoPreviewCell.allowCrop = pickerVC.allowCrop;
        photoPreviewCell.scaleAspectFillCrop = pickerVC.scaleAspectFillCrop;
        
        __weak typeof(pickerVC) weakPickerVC = pickerVC;
        __weak typeof(_collectionView) weakCollectionView = _collectionView;
        __weak typeof(photoPreviewCell) weakCell = photoPreviewCell;
        [photoPreviewCell setImageProgressUpdateBlock:^(double progress) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            __strong typeof(weakPickerVC) strongPickerVC = weakPickerVC;
            __strong typeof(weakCollectionView) strongCollectionView = weakCollectionView;
            __strong typeof(weakCell) strongCell = weakCell;
            strongSelf.progress = progress;
            if (progress >= 1) {
                if (strongSelf.isSelectOriginalPhoto) [strongSelf showPhotoBytes];
                if (strongSelf.alertView && [strongCollectionView.visibleCells containsObject:strongCell]){
                    [strongPickerVC hideAlertView:strongSelf.alertView];
                    strongSelf.alertView = nil;
                    [strongSelf doneButtonClick];
                }
            }
        }];
        photoPreviewCell.previewView.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            model.iCloudFailed = isSyncFailed;
            [weakSelf didICloudSyncStatusChanged:model];
            [weakSelf.models replaceObjectAtIndex:indexPath.item withObject:model];
        };
    }
    
    cell.model = model;
    [cell setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didTapPreviewCell];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HLLPhotoPreViewCell class]]) {
        [(HLLPhotoPreViewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HLLPhotoPreViewCell class]]) {
        [(HLLPhotoPreViewCell *)cell recoverSubviews];
    } else if ([cell isKindOfClass:[HLLVideoPreviewCell class]]) {
        HLLVideoPreviewCell *videoCell = (HLLVideoPreviewCell *)cell;
        if (videoCell.player && videoCell.player.rate != 0.0) {
            [videoCell pausePlayerAndShowNaviBar];
        }
    }
}
#pragma clang diagnostic pop

@end
