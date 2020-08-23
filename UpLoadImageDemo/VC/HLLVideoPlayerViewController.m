//
//  HLLVideoPlayerViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/17.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLVideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+Helper.h"
#import "HLLImageManager.h"
#import "HLLAssetModel.h"
#import "HLLTemplatePickerViewController.h"
#import "HLLPhotoPreViewController.h"
#import "UIImage+Helper.h"
#import "HLLCommonTools.h"

@interface HLLVideoPlayerViewController (){
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
    UIButton *_playButton;
    UIImage *_cover;
    
    UIView *_toolBar;
    UIButton *_doneButton;
    UIProgressView *_progress;
    
    UIStatusBarStyle _originStatusBarStyle;
}

@property (assign, nonatomic) BOOL needShowStatusBar;
// iCloud无法同步提示UI
@property (nonatomic, strong) UIView *iCloudErrorView;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation HLLVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
    self.view.backgroundColor = [UIColor blackColor];
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    
    if (pickerVC) {
        self.navigationItem.title = pickerVC.previewBtnTitleStr;
    }
    [self configMoviePlayer];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:UIApplicationWillResignActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
}

- (void)viewDidLayoutSubviews{
    BOOL isFullScreen = self.view.al_height == [UIScreen mainScreen].bounds.size.height;
       CGFloat statusBarHeight = isFullScreen ? [HLLCommonTools hll_statusBarHeight] : 0;
       CGFloat statusBarAndNaviBarHeight = statusBarHeight + self.navigationController.navigationBar.al_height;
       _playerLayer.frame = self.view.bounds;
       CGFloat toolBarHeight = [HLLCommonTools hll_isIPhoneX] ? 44 + (83 - 49) : 44;
       _toolBar.frame = CGRectMake(0, self.view.al_height - toolBarHeight, self.view.al_width, toolBarHeight);
       _doneButton.frame = CGRectMake(self.view.al_width - 44 - 12, 0, 44, 44);
       _playButton.frame = CGRectMake(0, statusBarAndNaviBarHeight, self.view.al_width, self.view.al_height - statusBarAndNaviBarHeight - toolBarHeight);
       
       HLLTemplatePickerViewController *pickerPC = (HLLTemplatePickerViewController *)self.navigationController;
       if (pickerPC.videoPreviewPageDidLayoutSubviewsBlock) {
           pickerPC.videoPreviewPageDidLayoutSubviewsBlock(_playButton, _toolBar, _doneButton);
       }
}


- (void)configMoviePlayer{
    [[HLLImageManager manager] fetchPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        BOOL iCloudSyncFailed = !photo && [HLLCommonTools isICloudSyncError:info[PHImageErrorKey]];
        self.iCloudErrorView.hidden = !iCloudSyncFailed;
        if (!isDegraded && photo) {
            self->_cover = photo;
            self->_doneButton.enabled = YES;
        }
    }];
    [[HLLImageManager manager] fetchVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_player = [AVPlayer playerWithPlayerItem:playerItem];
            self->_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self->_player];
            self->_playerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:self->_playerLayer];
            [self addProgressObserver];
            [self configPlayButton];
            [self configBottomToolBar];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self->_player.currentItem];
        });
    }];
}


- (void)addProgressObserver{
    AVPlayerItem *playerItem = _player.currentItem;
    UIProgressView *progress = _progress;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
    }];
}

- (void)configPlayButton{
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
       [self.view addSubview:_playButton];
}

- (void)configBottomToolBar{
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
       CGFloat rgb = 34 / 255.0;
       _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
       
       _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
       _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
       if (!_cover) {
           _doneButton.enabled = NO;
       }
       [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC) {
        [_doneButton setTitle:pickerVC.doneBtnTitleStr forState:UIControlStateNormal];
        [_doneButton setTitleColor:pickerVC.okBtnTitleColorNormal forState:UIControlStateNormal];
    }else{
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    }
    
    [_doneButton setTitleColor:pickerVC.okBtnTitleColorDisabled forState:UIControlStateDisabled];
    [_toolBar addSubview:_doneButton];
    [self.view addSubview:_toolBar];
    
    if (pickerVC.videoPreviewPageUIConfigBlock) {
        pickerVC.videoPreviewPageUIConfigBlock(_playButton, _toolBar, _doneButton);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    HLLTemplatePickerViewController *pickerVC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerVC && [pickerVC isKindOfClass:[HLLTemplatePickerViewController class]]) {
        return pickerVC.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}


#pragma mark - Notification Method

- (void)pausePlayerAndShowNaviBar {
    [_player pause];
    _toolBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [_playButton setImage:[UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    
    if (self.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
}


#pragma mark 响应事件
- (void)playButtonClick{
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        [_player play];
        [self.navigationController setNavigationBarHidden:YES];
        _toolBar.hidden = YES;
        [_playButton setImage:nil forState:UIControlStateNormal];
        [UIApplication sharedApplication].statusBarHidden = YES;
    }else{
         [self pausePlayerAndShowNaviBar];
    }
}

- (void)doneButtonClick{
    if (self.navigationController) {
        HLLTemplatePickerViewController *pickerVc = (HLLTemplatePickerViewController *)self.navigationController;
        if (pickerVc.autoDismiss) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self callDelegateMethod];
            }];
        }else{
            [self callDelegateMethod];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    }
}

- (void)callDelegateMethod {
    HLLTemplatePickerViewController *pickerPC = (HLLTemplatePickerViewController *)self.navigationController;
    if (pickerPC.pickerDelegate && [pickerPC.pickerDelegate respondsToSelector:@selector(hll_imagePickerController:didFinishPickingVideo:sourceAssets:)]) {
        [pickerPC.pickerDelegate hll_imagePickerController:pickerPC didFinishPickingVideo:_cover sourceAssets:_model.asset];
    }
    if (pickerPC.didFinishPickingVideoHandle) {
        pickerPC.didFinishPickingVideoHandle(_cover, _model.asset);
    }
}

- (UIView *)iCloudErrorView{
    if (!_iCloudErrorView) {
        _iCloudErrorView = [[UIView alloc] initWithFrame:CGRectMake(0, [HLLCommonTools hll_isIPhoneX] ? 88 + 10 : 64 + 10, self.view.al_width, 28)];
        UIImageView *icloud = [[UIImageView alloc] init];
        icloud.image = [UIImage hll_imageNamedFromBundle:@"iCloudError"];
        icloud.frame = CGRectMake(20, 0, 28, 28);
        [_iCloudErrorView addSubview:icloud];
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(53, 0, self.view.al_width - 63, 28);
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        label.text = @"iCloud 同步失败";
        [_iCloudErrorView addSubview:label];
        [self.view addSubview:_iCloudErrorView];
        _iCloudErrorView.hidden = YES;
    }
    return _iCloudErrorView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma clang diagnostic pop

@end
