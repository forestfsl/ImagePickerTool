//
//  HLLModelPicViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//


//显示照片相关类从这个入口开始

#import "HLLModelPicViewController.h"
#import <Photos/Photos.h>
#import "HLLGridViewFLowLayout.h"
#import "HLLMediaItemCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "HLLAnimatedImage.h"
#import "UIView+Helper.h"
#import "HLLTemplatePickerViewController.h"
#import "HLLGifPhotoPreViewController.h"
#import "HLLVideoPlayerViewController.h"
#import "HLLImageUploadOperation.h"
#import "HLLMediaItemModel.h"
#import "HLLCustomViewController.h"

static CGFloat upLoadSuccessNum = 0;

@interface HLLModelPicViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HLLTemplatePickerViewControllerDelegate>
{
    NSMutableArray *_selectedPhotos;//选择图片数组
    NSMutableArray *_selectedAssets;//选择的asset数组
    NSMutableArray *_selectedModels;//模型数组
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;//宽度和高度统一
    CGFloat _margin;
    
}

@property (nonatomic, strong) UIImagePickerController *imagePickerVC;
@property (nonatomic, strong) UICollectionView *collectionV;
@property (nonatomic, strong) HLLGridViewFLowLayout *layout;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) UIButton *uploadBtn;

@end

@implementation HLLModelPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubView];
}

- (void)setupSubView{
    self.view.backgroundColor = [UIColor whiteColor];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    _selectedModels = [NSMutableArray array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.uploadBtn];
    
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    [self configCollectionView];
}


- (UIButton *)uploadBtn{
    if (!_uploadBtn) {
        _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _uploadBtn.bounds = CGRectMake(0, 0, 60, 40);
        [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        [_uploadBtn addTarget:self action:@selector(upLoadButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_uploadBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _uploadBtn.hidden = YES;
//        _uploadBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    }
    return _uploadBtn;
}

- (void)backButtonClick{
    if (_selectedModels.count > 0 && upLoadSuccessNum != _selectedModels.count) {
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"图片未上传成功" message:@"是否退出" preferredStyle:UIAlertControllerStyleAlert];
                  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
           [alertController addAction:cancelAction];
           UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                      [self.navigationController popViewControllerAnimated:YES];
                  }];
           [alertController addAction:settingAction];
           [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }else{
          [self.navigationController popViewControllerAnimated:YES];
    }
   
   
}

- (void)upLoadButtonClick{
    if ([self.uploadBtn.titleLabel.text isEqualToString:@"上传"]) {
         [self.uploadBtn setTitle:@"上传中" forState:UIControlStateNormal];
        self.operationQueue = [[NSOperationQueue alloc]init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        for (NSInteger i = 0; i < _selectedAssets.count; i++) {
             PHAsset *asset = _selectedAssets[i];
            HLLMediaItemModel *itemModel = _selectedModels[i];
            if (itemModel.isSuccess) continue;
            //图片上传
            HLLImageUploadOperation *operation = [[HLLImageUploadOperation alloc] initWithAsset:asset completion:^(UIImage * _Nullable photo, NSDictionary * _Nullable info, BOOL isDegraded) {
                if (isDegraded) {
                    return ;
                }
                NSLog(@"图片获取完成");
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:i];
                //TODO 这里需要网络请求
                HLLMediaItemCell *itemCell = (HLLMediaItemCell *)[self->_collectionV cellForItemAtIndexPath:indexPath];
                [itemCell.progressView updateProgress:10];
                 itemCell.progressView.hidden = NO;
                itemModel.isSuccess = NO;
//                upLoadSuccessNum++;
                [self.uploadBtn setTitle:@"编辑" forState:UIControlStateNormal];
                [self.collectionV reloadData];
                
            } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                NSLog(@"获取图片进度 %f",progress);
            }];
            [self.operationQueue addOperation:operation];
        }
    }else if ([self.uploadBtn.titleLabel.text isEqualToString:@"编辑"]){
         [self.uploadBtn setTitle:@"完成" forState:UIControlStateNormal];
         [self.collectionV reloadData];
    }else if ([self.uploadBtn.titleLabel.text isEqualToString:@"完成"]){
         [self.uploadBtn setTitle:@"编辑" forState:UIControlStateNormal];
         [self.collectionV reloadData];
    }
   

    
}

- (void)uploadAgainWithAsset:(PHAsset *)asset itemModel:(HLLMediaItemModel *)itemModel itemCell:(HLLMediaItemCell *)itemCell{
    
    self.operationQueue = [[NSOperationQueue alloc]init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    //图片上传
    HLLImageUploadOperation *operation = [[HLLImageUploadOperation alloc] initWithAsset:asset completion:^(UIImage * _Nullable photo, NSDictionary * _Nullable info, BOOL isDegraded) {
        if (isDegraded) {
            return ;
            
        }
        NSLog(@"图片获取完成");
         //TODO 这里需要网络请求
        itemCell.progressView.hidden = NO;
        [itemCell.progressView updateProgress:10];
        itemModel.isSuccess = YES;
        upLoadSuccessNum++;
       
        //上传返回
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self->_selectedAssets.count == upLoadSuccessNum) {
             [self.uploadBtn setTitle:@"编辑" forState:UIControlStateNormal];
            }
           
            [self.collectionV reloadData];
        });
       
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        NSLog(@"获取图片进度 %f",progress);
        
    }];
    [self.operationQueue addOperation:operation];
}
    

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _margin = 4;
    _columnNumber = 4;
    _maxCount = 6;
    _canCrop = NO;
    _needCircleCrop = NO;
    _canPickImage = YES;
    _isSortAscend = YES;
    _canPickVideo = YES;
    _shouldShowSheet = NO;
    _canPickMuiltlpleVideo = YES;
    _shouldShowSelectIndex = YES;
    _itemWH = (self.view.al_width - 2 * _margin - 4) / 2 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    _canTakePhoto = YES;
    _canPickOriginal = YES;
    [self.collectionV setCollectionViewLayout:self.layout];

    self.collectionV.frame = CGRectMake(0, 0, self.view.al_width, self.view.al_height);
}

- (void)configCollectionView{
    [self.view addSubview:self.collectionV];
}

- (HLLGridViewFLowLayout *)layout{
    if (!_layout) {
        _layout = [[HLLGridViewFLowLayout alloc]init];
    }
    return _layout;
}

- (UICollectionView *)collectionV{
    if (!_collectionV) {
        _collectionV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        CGFloat rgb = 244 / 255.0;
        _collectionV.alwaysBounceVertical = YES;
        _collectionV.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        _collectionV.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
        _collectionV.dataSource = self;
        _collectionV.delegate = self;
        _collectionV.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        [_collectionV registerClass:[HLLMediaItemCell class] forCellWithReuseIdentifier:NSStringFromClass([HLLMediaItemCell class])];
    }
    return _collectionV;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVC{
    if (!_imagePickerVC) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
        _imagePickerVC.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVC.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVC.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HLLModelPicViewController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[HLLModelPicViewController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVC;
}


#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selectedModels.count >= self.maxCount) {
        return _selectedModels.count;
    }
    if (!self.canPickMuiltlpleVideo) {
        for (PHAsset *asset in _selectedAssets) {
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                return _selectedModels.count;
            }
        }
    }
    return _selectedModels.count + 1;//+ 1 是有个+号
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLLMediaItemCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLLMediaItemCell class]) forIndexPath:indexPath];
    itemCell.videoImageV.hidden = YES;
    //TODO 根据是上传还是返回显示不同的图片
    if (indexPath.item == _selectedModels.count) {
        itemCell.imageV.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
        itemCell.deleteBtn.hidden = YES;
        itemCell.retryUploadBtn.hidden = YES;
        itemCell.failureBtn.hidden = YES;
        itemCell.progressView.hidden = YES;
        itemCell.gifL.hidden = YES;
    }else{
        HLLMediaItemModel *model = _selectedModels[indexPath.item];
        itemCell.imageV.image = model.mediaImage;
        itemCell.asset = _selectedAssets[indexPath.item];
       
        if ([self.uploadBtn.titleLabel.text isEqualToString:@"编辑"]) {
            itemCell.isUploadSuccess = model.isSuccess;
        }else if ([self.uploadBtn.titleLabel.text isEqualToString:@"完成"] || [self.uploadBtn.titleLabel.text isEqualToString:@"上传"]){
             itemCell.deleteBtn.hidden = NO;
             itemCell.retryUploadBtn.hidden = YES;
             itemCell.failureBtn.hidden = YES;
        }else if ([self.uploadBtn.titleLabel.text isEqualToString:@"上传中"]){
             itemCell.isUploadSuccess = model.isSuccess;
           
        }
        __weak typeof(itemCell) weakItemCell = itemCell;
        itemCell.dataUpLoadBlock = ^(id  _Nullable asset) {
            __strong typeof(weakItemCell) strongItemCell = weakItemCell;
            strongItemCell.retryUploadBtn.hidden = YES;
            strongItemCell.failureBtn.hidden = YES;
            [self uploadAgainWithAsset:self->_selectedAssets[indexPath.item] itemModel:model itemCell:strongItemCell];
        };
        
       
    }
    itemCell.deleteBtn.tag = indexPath.item;
    [itemCell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return itemCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == _selectedModels.count) {
        BOOL showSheet = self.shouldShowSheet;
        if (showSheet) {
            NSString *takePhotoTitle = @"拍照";
            if (self.canTakeVideo && self.canTakePhoto) {
                takePhotoTitle = @"相机";
            } else if (self.canTakeVideo) {
                takePhotoTitle = @"拍摄";
            }
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:takePhotoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self takePhoto];
            }];
            [alertVc addAction:takePhotoAction];
            UIAlertAction *imagePickerAction = [UIAlertAction actionWithTitle:@"去相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self pushHLLTemplatePickerViewController];
            }];
            [alertVc addAction:imagePickerAction];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVc addAction:cancelAction];
            UIPopoverPresentationController *popover = alertVc.popoverPresentationController;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            if (popover) {
                popover.sourceView = cell;
                popover.sourceRect = cell.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [self presentViewController:alertVc animated:YES completion:nil];
        } else {
            [self chooseMediaVC];
        }
    }else{
        PHAsset *asset = _selectedAssets[indexPath.item];
        BOOL isVideo = NO;
        isVideo = asset.mediaType == PHAssetMediaTypeVideo;
        if ([[asset valueForKey:@"filename"] containsString:@"GIF"] && self.canPickGif && !self.canPickMuiltlpleVideo) {
            HLLGifPhotoPreViewController *vc = [[HLLGifPhotoPreViewController alloc] init];
            HLLAssetModel *model = [HLLAssetModel modelWithAsset:asset type:HLLAssetModelMediaTypePhotoGif timeLength:@""];
            vc.model = model;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
            
        } else if (isVideo && !self.canPickMuiltlpleVideo) { //预览视频
                   HLLVideoPlayerViewController *vc = [[HLLVideoPlayerViewController alloc] init];
                   HLLAssetModel *model = [HLLAssetModel modelWithAsset:asset type:HLLAssetModelMediaTypeVideo timeLength:@""];
                   vc.model = model;
                   vc.modalPresentationStyle = UIModalPresentationFullScreen;
                   [self presentViewController:vc animated:YES completion:nil];
               } else { // preview photos / 预览照片
                   HLLTemplatePickerViewController *imagePickerVc = [[HLLTemplatePickerViewController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.item];
                   imagePickerVc.maxImagesCount = 10;
                   imagePickerVc.allowPickingGif = self.canPickGif;
                   imagePickerVc.autoSelectCurrentWhenDone = NO;
                   imagePickerVc.allowPickingOriginalPhoto = self.canPickOriginal;
                   imagePickerVc.allowPickingMultipleVideo = self.canPickMuiltlpleVideo;
                   imagePickerVc.showSelectedIndex = self.shouldShowSelectIndex;
                   imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
                   imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
                   [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                       self->_selectedPhotos = [NSMutableArray arrayWithArray:photos];
                       self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
                         NSMutableArray *tempModelArray = [NSMutableArray array];
                         //初始化之前先判断
                       if (self->_selectedModels.count > 0) {
                           tempModelArray = [self->_selectedModels copy];
                         }
                       self->_selectedModels = [NSMutableArray arrayWithCapacity:self->_selectedPhotos.count];
                         
                       
                       for (NSInteger i = 0; i < self->_selectedPhotos.count; i++) {
                             HLLMediaItemModel *itemModel = [[HLLMediaItemModel alloc]init];
                           itemModel.mediaImage = self->_selectedPhotos[i];
                           itemModel.asset = self->_selectedAssets[i];
                             //遍历模型数组查看是否已经包含该图片
                             for (HLLMediaItemModel *currentImteModel in tempModelArray) {
                                 if ([currentImteModel.asset isEqual:itemModel.asset]) {
                                     itemModel.isSuccess = currentImteModel.isSuccess;
                                     break;
                                 }
                             }

                           [self->_selectedModels addObject:itemModel];
                            
                         }
                       

                       self->_isSelectOriginalPhoto = isSelectOriginalPhoto;
                       [self->_collectionV reloadData];
                       self->_collectionV.contentSize = CGSizeMake(0, ((self->_selectedPhotos.count + 2) / 3 ) * (self->_margin + self->_itemWH));
                   }];
                   [self presentViewController:imagePickerVc animated:YES completion:nil];
               }
    }
}

#pragma mark HLLGridViewFLowLayout

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < _selectedModels.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedModels.count && destinationIndexPath.item < _selectedModels.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    HLLMediaItemModel *itemModel = _selectedModels[sourceIndexPath.item];
     [_selectedModels removeObjectAtIndex:sourceIndexPath.item];
     [_selectedModels insertObject:itemModel atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionV reloadData];
}



#pragma mark 点击cell右上角的删除按钮
- (void)deleteBtnClick:(UIButton *)sender{
    if ([self collectionView:self.collectionV numberOfItemsInSection:0] <= _selectedModels.count) {
           [_selectedPhotos removeObjectAtIndex:sender.tag];
           [_selectedAssets removeObjectAtIndex:sender.tag];
        [_selectedModels removeObjectAtIndex:sender.tag];
           [self.collectionV reloadData];
           return;
       }
       
       [_selectedPhotos removeObjectAtIndex:sender.tag];
       [_selectedAssets removeObjectAtIndex:sender.tag];
    [_selectedModels removeObjectAtIndex:sender.tag];
       [_collectionV performBatchUpdates:^{
           NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
           [self->_collectionV deleteItemsAtIndexPaths:@[indexPath]];
       } completion:^(BOOL finished) {
           [self->_collectionV reloadData];
       }];
    self.uploadBtn.hidden = _selectedAssets.count > 0 ? NO : YES;
    if (!(_selectedAssets.count > 0)) {
         [self.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    }
   
}


- (void)chooseMediaVC{
   [ self pushHLLTemplatePickerViewController];
    return;
    if (!(_selectedModels.count > 0 )) {
        HLLCustomViewController *customVC = [[HLLCustomViewController alloc]initCustomVCWithTarget:self];
        //跳到自定义界面
        [self presentViewController:customVC animated:YES completion:nil];
    
    }else{
        [self pushHLLTemplatePickerViewController];
    }
    
}


#pragma mark - HLLTemplatePickerViewController
//重要方法
- (void)pushHLLTemplatePickerViewController{
    
    //判断最大可选择数目
    if (self.maxCount <= 0) {
        return;
    }
    if (self.canCrop) {
        self.maxCount = 1;
    }
    
    HLLTemplatePickerViewController *pickerVC = [[HLLTemplatePickerViewController alloc]initWithMaxImagesCount:self.maxCount columnNumber:self.columnNumber delegate:self pushPhotoPickerVC:YES];
    
    if (self.maxCount > 1) {
        //目前已经选中的图片数组
        pickerVC.selectedAssets = _selectedAssets;
    }
    pickerVC.allowTakePicture = self.canTakePhoto;
    pickerVC.allowTakeVideo = self.canTakeVideo;
    pickerVC.videoMaximunDuration = 10;
    [pickerVC setUIImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    //设置是否选中当前预览图片
    pickerVC.autoSelectCurrentWhenDone = NO;
    //设置pickerVC的外观属性
    // pickerVC.navigationBar.barTintColor = [UIColor greenColor];
    // pickerVC.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // pickerVC.oKButtonTitleColorNormal = [UIColor greenColor];
    // pickerVC.navigationBar.translucent = NO;
    
    pickerVC.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
       pickerVC.showPhotoCannotSelectLayer = YES;
       pickerVC.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
       /*
       [pickerVC setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
           [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
       }];
        */
       /*
       [pickerVC setAssetCellDidSetModelBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
           cell.contentView.clipsToBounds = YES;
           cell.contentView.layer.cornerRadius = cell.contentView.tz_width * 0.5;
       }];
        */
    
    //设置是否可以选择视频/图片/原图
    pickerVC.allowTakeVideo = self.canPickVideo;
    pickerVC.allowPickingImage = self.canPickImage;
    pickerVC.allowPickingOriginalPhoto = self.canPickOriginal;
    pickerVC.allowPickingGif = self.canPickGif;
    pickerVC.allowPickingMultipleVideo = self.canPickMuiltlpleVideo;
    
    //照片是否需要按照升序排序
    pickerVC.sortAscendingBymodificationDate = self.isSortAscend;
    
    // pickerVC.minImagesCount = 3;
    // pickerVC.alwaysEnableDoneBtn = YES;
       
    // pickerVC.minPhotoWidthSelectable = 3000;
    // pickerVC.minPhotoHeightSelectable = 2000;
    
    pickerVC.showSelectBtn = NO;
    pickerVC.allowCrop = self.canCrop;
    pickerVC.needCircleCrop = self.needCircleCrop;
    
    //设置竖屏裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = self.view.al_width - 2 * left;
    NSInteger top = (self.view.al_height - widthHeight) / 2;
    pickerVC.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    pickerVC.scaleAspectFillCrop = YES;
    
    //设置横屏下的裁剪尺寸
    // pickerVC.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [pickerVC setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //是否支持预览模式
//    pickerVC.allowPreview = NO;
    
    //自定义导航栏返回按钮，通过block回调设置
//    [pickerVC setNavLeftBarButtonSettingBlock:^(UIButton *leftButton) {
//        [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 20)];
//    }];
//
//    pickerVC.delegate = self;
    
    //设置statusBarsStyle
    pickerVC.isStatusBarDefault = NO;
    pickerVC.statusBarStyle = UIStatusBarStyleLightContent;
    
    //设置图片序号
    pickerVC.showSelectedIndex = self.shouldShowSelectIndex;
    
    
//    设置拍照时是否需要定位
//    pickerVC.allowCameraLocation = NO;
    
    //自定义gif播放方案
    [[HLLImagePickerConfig sharedInstance] setGifImagePlayBolck:^(HLLPhotoPreviewView *view, UIImageView *imageView, NSData *gifData, NSDictionary *info) {
        HLLAnimatedImage *animatedImage = [HLLAnimatedImage animatedImageWithGIFData:gifData];
        HLLAnimatedImageView *animatedImageView;
        for (UIView *subview in imageView.subviews) {
            if ([subview isKindOfClass:[HLLAnimatedImageView class]]) {
                animatedImageView = (HLLAnimatedImageView *)subview;
                animatedImageView.frame = imageView.bounds;
                animatedImageView.animatedImage = nil;
            }
        }
        if (!animatedImageView) {
            animatedImageView = [[HLLAnimatedImageView alloc] initWithFrame:imageView.bounds];
            animatedImageView.runLoopMode = NSDefaultRunLoopMode;
            [imageView addSubview:animatedImageView];
        }
        animatedImageView.animatedImage = animatedImage;
    }];
    
    //设置首选语言(暂时不支持这个属性)
//    pickerVC.preferredLanguage = @"zh-Hans";
     // pickerVC.languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"tz-ru" ofType:@"lproj"]];
    
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [pickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {

    }];
    
    pickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pickerVC animated:YES completion:nil];
}

/*
// 设置了navLeftBarButtonSettingBlock后，需打开这个方法，让系统的侧滑返回生效
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
 
    navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (viewController != navigationController.viewControllers[0]) {
        navigationController.interactivePopGestureRecognizer.delegate = nil; // 支持侧滑
    }
}
*/


#pragma mark - UIImgaePickerController
- (void)takePhoto{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
       if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
           // 无相机权限 做一个友好的提示
           UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" preferredStyle:UIAlertControllerStyleAlert];
           [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
           [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
           }]];
           [self presentViewController:alertController animated:YES completion:nil];
       } else if (authStatus == AVAuthorizationStatusNotDetermined) {
          
           [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
               if (granted) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self takePhoto];
                   });
               }
           }];
           // 拍照之前还需要检查相册权限
       } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
           UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
           [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
           [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
           }]];
           [self presentViewController:alertController animated:YES completion:nil];
       } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
           [[HLLImageManager manager] requestAuthorizationWithCompletion:^{
               [self takePhoto];
           }];
       } else {
           [self pushImagePickerController];
       }
}

// 调用相机
- (void)pushImagePickerController {
    //提前定位
    __weak typeof(self) weakSelf = self;
    [[HLLLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locaitons) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locaitons firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVC.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        if (self.canTakeVideo) {
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
        }
        if (self.canTakePhoto) {
            [mediaTypes addObject:(NSString *)kUTTypeImage];
        }
        if (mediaTypes.count) {
            self.imagePickerVC.mediaTypes = mediaTypes;
        }
        [self presentViewController:self.imagePickerVC animated:YES completion:nil];
    }else{
        NSLog(@"模拟器中无法打开照相机，请在真机中使用");
    }
}

// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result{
    
    /*
       if ([albumName isEqualToString:@"个人收藏"]) {
           return NO;
       }
       if ([albumName isEqualToString:@"视频"]) {
           return NO;
       }*/
    
    return YES;
}

// 决定asset显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset {
    /*
    switch (asset.mediaType) {
        case PHAssetMediaTypeVideo: {
            // 视频时长
            // NSTimeInterval duration = phAsset.duration;
            return NO;
        } break;
        case PHAssetMediaTypeImage: {
            // 图片尺寸
            if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
                // return NO;
            }
            return YES;
        } break;
        case PHAssetMediaTypeAudio:
            return NO;
            break;
        case PHAssetMediaTypeUnknown:
            return NO;
            break;
        default: break;
    }
     */
    return YES;
}


//拍摄回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    HLLTemplatePickerViewController *pickerVC = [[HLLTemplatePickerViewController alloc]initWithMaxImagesCount:1 delegate:self];
    pickerVC.sortAscendingBymodificationDate = self.isSortAscend;
    [pickerVC showProgressHUD];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
        //保存图片
        [[HLLImageManager manager] savePhotoWithImage:image meta:meta location:self.location completion:^(PHAsset *asset, NSError *error) {
            [pickerVC hideProgressHUD];
            if (error) {
                NSLog(@"图片保存失败 %@",error);
            }else{
                HLLAssetModel *assetModel = [[HLLImageManager manager] createModelWithAsset:asset];
                if (self.canCrop) {
                    HLLTemplatePickerViewController *pickerVC = [[HLLTemplatePickerViewController alloc]initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, PHAsset *asset) {
                        [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                    }];
                    pickerVC.allowPickingImage = YES;
                    pickerVC.needCircleCrop = self.needCircleCrop;
                    pickerVC.circleCropRadius = 100;
                    [self presentViewController:pickerVC animated:YES completion:nil];
                }else{
                    [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                }
            }
        }];
    }else if ([type isEqualToString:@"public.movie"]){
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            [[HLLImageManager manager] saveVideoWithUrl:videoUrl location:self.location completion:^(PHAsset *asset, NSError *error) {
                [pickerVC hideProgressHUD];
                if (!error) {
                    HLLAssetModel *assetModel = [[HLLImageManager manager] createModelWithAsset:asset];
                    [[HLLImageManager manager] fetchPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                        if (!isDegraded && photo) {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                        }
                    }];
                }
            }];
        }
    }
}


- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image{
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    HLLMediaItemModel *itemModel = [[HLLMediaItemModel alloc]init];
    itemModel.mediaImage = image;
    itemModel.asset = asset;
    [_selectedModels addObject:itemModel];
    [_collectionV reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark HLLTemplatePickerViewControllerDelegate

- (void)hll_imagePickerControllerDidCancel:(HLLTemplatePickerViewController *)picker{
    
}

//选择器dismiss调用
- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    //需要判断数组是否相同，相同，不需要做任何事情
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    NSMutableArray *tempModelArray = [NSMutableArray array];
    //初始化之前先判断
    if (_selectedModels.count > 0) {
        tempModelArray = [_selectedModels copy];
    }
    _selectedModels = [NSMutableArray arrayWithCapacity:_selectedPhotos.count];
    
  
    for (NSInteger i = 0; i < _selectedPhotos.count; i++) {
        HLLMediaItemModel *itemModel = [[HLLMediaItemModel alloc]init];
        itemModel.mediaImage = _selectedPhotos[i];
        itemModel.asset = _selectedAssets[i];
        //遍历模型数组查看是否已经包含该图片
        for (HLLMediaItemModel *currentImteModel in tempModelArray) {
            if ([currentImteModel.asset isEqual:itemModel.asset]) {
                itemModel.isSuccess = currentImteModel.isSuccess;
                break;
            }
        }

        [_selectedModels addObject:itemModel];
       
    }
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionV reloadData];
    
    //1.打印图片名字
    [self printAssetsName:assets];
    
    //2.图片位置信息
    for (PHAsset *phAsset in assets) {
         NSLog(@"location:%@",phAsset.location);
    }
    [self.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    self.uploadBtn.hidden = NO;
//    //3.获取原图
//    self.operationQueue = [[NSOperationQueue alloc]init];
//    self.operationQueue.maxConcurrentOperationCount = 1;
//    for (NSInteger i = 0; i < assets.count; i++) {
//         PHAsset *asset = assets[i];
//        //图片上传
//        HLLImageUploadOperation *operation = [[HLLImageUploadOperation alloc] initWithAsset:asset completion:^(UIImage * _Nullable photo, NSDictionary * _Nullable info, BOOL isDegraded) {
//            if (isDegraded) {
//                return ;
//            }
//            NSLog(@"图片获取完成");
//        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//            NSLog(@"获取图片进度 %f",progress);
//        }];
//        [self.operationQueue addOperation:operation];
//    }
}

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (PHAsset *asset in assets) {
        fileName = [asset valueForKey:@"filename"];
        // NSLog(@"图片名字:%@",fileName);
    }
}

//选择了一个视频且allowPickingMultipleVideo是NO
- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset{
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    _selectedModels = [NSMutableArray arrayWithCapacity:_selectedPhotos.count];
    for (NSInteger i = 0; i < _selectedPhotos.count; i++) {
           HLLMediaItemModel *itemModel = [[HLLMediaItemModel alloc]init];
           itemModel.mediaImage = _selectedPhotos[i];
           [_selectedModels addObject:itemModel];
       }
    
    [[HLLImageManager manager] fetchVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetLowQuality success:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    } failure:^(NSString *errorMessage, NSError *error) {
         NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
        
    }];
     [_collectionV reloadData];
}

//gif && MultipleVideo == NO
- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset{
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    _selectedModels = [NSMutableArray arrayWithCapacity:_selectedPhotos.count];
    for (NSInteger i = 0; i < _selectedPhotos.count; i++) {
           HLLMediaItemModel *itemModel = [[HLLMediaItemModel alloc]init];
           itemModel.mediaImage = _selectedPhotos[i];
           [_selectedModels addObject:itemModel];
       }
    [_collectionV reloadData];
}

#pragma clang diagnostic pop
@end
