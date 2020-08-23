//
//  HLLTemplatePickerViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "HLLPhotoPreviewView.h"
#import "HLLImageManager.h"
#import "HLLAssetModel.h"
#import "HLLPhotoPreviewView.h"
#import "HLLLocationManager.h"
#import "HLLAssetCell.h"

@class HLLAlbumCell;
@protocol HLLTemplatePickerViewControllerDelegate;

@interface HLLTemplatePickerViewController : UINavigationController

///############################### 初始化方法 ###############################///
///初始化方法
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImageCount delegate:(id<HLLTemplatePickerViewControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                          columnNumber:(NSInteger)columnNumber delegate:(id<HLLTemplatePickerViewControllerDelegate>)delegate;

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
                          columnNumber:(NSInteger)columnNumber
                              delegate:(id<HLLTemplatePickerViewControllerDelegate>)delegate pushPhotoPickerVC:(BOOL)pushPhotoPickerVC;

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index;

- (instancetype)initCropTypeWithAsset:(PHAsset *)asset photo:(UIImage *)photo
                           completion:(void (^)(UIImage *cropImage,PHAsset *asset))completion;


///############################### 初始化方法 ###############################///


///******************************* 暴露可以更改的属性 *******************************///

//最大选择照片个数
@property (nonatomic, assign) NSInteger maxImagesCount;
/// 最小照片必选张数,默认是0
@property (nonatomic, assign) NSInteger minImagesCount;
//默认为NO，为YES时可以多选视频/gif/图片，和照片共享最大可选张数maxImagesCount的限制
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
/// 如果用户未选择任何图片，在点击完成按钮时自动选中当前图片，默认YES
@property (nonatomic, assign) BOOL autoSelectCurrentWhenDone;
///在单选模式下，照片列表页中，显示选择按钮,默认为NO
@property (nonatomic, assign) BOOL allowCrop;
///允许编辑 默认为yes
@property (nonatomic, assign) BOOL allowEdit;
/// 单选模式,maxImagesCount为1时才生效
@property (nonatomic, assign) BOOL showSelectBtn;
/// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图 并且选择了原图之后是不能使用裁剪功能的，也就是说和裁剪功能互斥
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;
///完成按钮一直可以点击，不需要选择至少一张图片
@property (nonatomic, assign) BOOL alwaysEnableDoneBtn;
///照片排序，按修改时间升序，默认是YES，如果是NO，反过来
@property (nonatomic, assign) BOOL sortAscendingBymodificationDate;

///图片的宽度
@property (nonatomic, assign) CGFloat photoWidth;
///默认像素
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;
///超时时间，默认为15秒，当取图片时间超过15秒还没有取成功，会自动dismiss
@property (nonatomic, assign) NSInteger timeout;
///是否能选择视频
@property (nonatomic, assign) BOOL allowPickingVideo;
///是否可以选择gif
@property (nonatomic, assign) BOOL allowPickingGif;
///是否可以选择图片
@property (nonatomic, assign) BOOL allowPickingImage;
///是否允许拍照
@property (nonatomic, assign) BOOL allowTakePicture;
///是否允许拍照定位
@property (nonatomic, assign) BOOL allowCameraLocation;
///默认为YES，如果设置为NO，不能拍摄视频
@property (nonatomic, assign) BOOL allowTakeVideo;
///设置拍摄的最长时间，默认是10分钟 秒为单位
@property (nonatomic, assign) NSTimeInterval videoMaximunDuration;

///是否支持预览
@property (nonatomic, assign) BOOL allowPreview;
///暂时不支持这个属性
@property (copy, nonatomic) NSString *preferredLanguage;
@property (strong, nonatomic) NSBundle *languageBundle;

/// 默认为YES，如果设置为NO, 选择器将不会自己dismiss
@property(nonatomic, assign) BOOL autoDismiss;
/// 默认为NO，如果设置为YES，代理方法里photos和infos会是nil，只返回assets
@property (assign, nonatomic) BOOL onlyReturnAsset;

/// 默认为NO，如果设置为YES，会显示照片的选中序号
@property (assign, nonatomic) BOOL showSelectedIndex;
/// 默认是YES，如果设置为NO，内部会缩放图片到photoWidth像素宽
@property (assign, nonatomic) BOOL notScaleImage;
/// 默认是NO，如果设置为YES，当照片选择张数达到maxImagesCount时，其它照片会显示颜色为cannotSelectLayerColor的浮层
@property (assign, nonatomic) BOOL showPhotoCannotSelectLayer;

@property (strong, nonatomic) UIColor *cannotSelectLayerColor;



///默认是NO，如果设置为YES，导出视频时候会修正转向
@property (assign, nonatomic) BOOL needFixComposition;
@property (nonatomic, copy) void(^UIImagePickerControllerSettingBlock)(UIImagePickerController *imagePickerController);

/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;

//选中的数组
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<HLLAssetModel *> *selectedModels;
@property (nonatomic, strong) NSMutableArray *selectedAssetIds;
/// 隐藏不可以选中的图片，默认是NO，不推荐将其设置为YES
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

/// statusBar的样式，默认为UIStatusBarStyleLightContent
@property (assign, nonatomic) UIStatusBarStyle statusBarStyle;

@property (nonatomic, copy) void (^cropViewSettingBlock)(UIView *cropView);     ///< 自定义裁剪框的其他属性
@property (nonatomic, copy) void (^navLeftBarButtonSettingBlock)(UIButton *leftButton);     ///< 自定义返回按钮样式及其属性

///******************************* 暴露可以更改的属性 *******************************///

//添加模型数组
- (void)addSelectedModel:(HLLAssetModel *)model;
- (void)removeSelectedModel:(HLLAssetModel *)model;

@property (nonatomic, assign) BOOL scaleAspectFillCrop;  ///< 是否图片等比缩放填充cropRect区域
@property (nonatomic, assign) CGRect cropRect;           ///< 裁剪框的尺寸
@property (nonatomic, assign) CGRect cropRectPortrait;   ///< 裁剪框的尺寸(竖屏)
@property (nonatomic, assign) CGRect cropRectLandscape;  ///< 裁剪框的尺寸(横屏)
@property (nonatomic, assign) BOOL needCircleCrop;       ///< 需要圆形裁剪框
@property (nonatomic, assign) NSInteger circleCropRadius;  ///< 圆形裁剪框半径大小

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (assign, nonatomic) BOOL needShowStatusBar;

@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, assign) BOOL isStatusBarDefault;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;


@property (nonatomic, strong) UIImage *takePictureImage;
@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;
@property (nonatomic, strong) UIImage *photoOriginSelImage;
@property (nonatomic, strong) UIImage *photoOriginDefImage;
@property (nonatomic, strong) UIImage *photoPreviewOriginDefImage;
@property (nonatomic, strong) UIImage *photoNumberIconImage;



///############################### HUD 和 弹框 ###############################///
- (UIAlertController *)showAlertWithTitle:(NSString *)title;
- (void)hideAlertView:(UIAlertController *)alertView;
- (void)showProgressHUD;
- (void)hideProgressHUD;
///############################### HUD 和 弹框 ###############################///


#pragma mark 更改外观属性
@property (nonatomic, strong) UIColor *okBtnTitleColorNormal;
@property (nonatomic, strong) UIColor *okBtnTitleColorDisabled;
@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIFont *naviTitleFont;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;
@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *editBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;
@property (nonatomic, strong) UIColor *iconThemeColor;

#pragma mark 其他方法
- (void)cancelButtonClick;


///******************************* block返回给调用者更改的属性 *******************************///

//【自定义各页面/组件的frame】在界面viewDidLayoutSubviews/组件layoutSubviews后调用，允许外界修改frame等
@property (nonatomic, copy) void (^photoPickerPageDidLayoutSubviewsBlock)(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine);

@property (nonatomic, copy) void (^photoPickerPageUIConfigBlock)(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine);

@property (nonatomic, copy) void (^photoPickerPageDidRefreshStateBlock)(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine);

@property (nonatomic, copy) void (^photoPreviewPageUIConfigBlock)(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel);

@property (nonatomic, copy) void (^photoPreviewPageDidLayoutSubviewsBlock)(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel);

@property (nonatomic, copy) void (^photoPreviewPageDidRefreshStateBlock)(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel);

@property (nonatomic, copy) void (^videoPreviewPageDidLayoutSubviewsBlock)(UIButton *playButton, UIView *toolBar, UIButton *doneButton);

@property (nonatomic, copy) void (^gifPreviewPageDidLayoutSubviewsBlock)(UIView *toolBar, UIButton *doneButton);

@property (nonatomic, copy) void (^albumPickerPageDidLayoutSubviewsBlock)(UITableView *tableView);

@property (nonatomic, copy) void (^videoPreviewPageUIConfigBlock)(UIButton *playButton, UIView *toolBar, UIButton *doneButton);

@property (nonatomic, copy) void (^assetCellDidSetModelBlock)(HLLAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);

@property (nonatomic, copy) void (^albumCellDidSetModelBlock)(HLLAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);

@property (nonatomic, copy) void (^albumCellDidLayoutSubviewsBlock)(HLLAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);


@property (nonatomic, copy) void (^assetCellDidLayoutSubviewsBlock)(HLLAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);

@property (nonatomic, copy) void (^gifPreviewPageUIConfigBlock)(UIView *toolBar, UIButton *doneButton);

@property (nonatomic, copy) id<HLLTemplatePickerViewControllerDelegate> pickerDelegate;

@property (nonatomic, copy) void (^albumPickerPageUIConfigBlock)(UITableView *tableView);

@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)(void);
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,PHAsset *asset);
@property (nonatomic, copy) void (^didFinishPickingGifImageHandle)(UIImage *animatedImage,id sourceAssets);

///******************************* block返回给调用者更改的属性 *******************************///



@end





/**
 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行夏敏的代理方法，你可以通过设置属性autoDismiss为NO，这样就不会自动dismiss
 isSelectOriginalPhoto为YES，代表选择原图
 */
@protocol HLLTemplatePickerViewControllerDelegate <NSObject>
@optional
- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;

- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;

- (void)hll_imagePickerControllerDidCancel:(HLLTemplatePickerViewController *)picker;


- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset;

- (void)hll_imagePickerController:(HLLTemplatePickerViewController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset;

///决定相册显示与否 albumName：相册名字 result：相册原始数据
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result;

///决定图片显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset;

@end


//定义一个相册选择控制器
@interface HLLAlbumPickerController : UIViewController

@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, assign) BOOL isFirstAppear;
- (void)configTableView;
@end



//定义一个属性配置类，单独抽取一个配置类出来，主要是为了面向对象的思想
@interface HLLImagePickerConfig : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, copy) NSString *preferredLanguage;
@property (nonatomic, assign) BOOL allowPickingImage;
@property (nonatomic, assign) BOOL allowPickingVideo;
@property (nonatomic, strong) NSBundle *languageBundle;
@property (nonatomic, assign) BOOL showSelectedIndex;
@property (nonatomic, assign) BOOL showPhotoCannotSelectLayer;
@property (nonatomic, assign) BOOL notScaleImage;
@property (nonatomic, assign) BOOL needFixComosition;

/// gif 图能存储的最大，担心内存会爆
@property (nonatomic, assign) NSInteger gifPreviewMaxImagesCount;

@property (nonatomic, copy) void (^gifImagePlayBolck)(HLLPhotoPreviewView *view ,UIImageView *imageView,NSData *gifData,NSDictionary *info);

@end
