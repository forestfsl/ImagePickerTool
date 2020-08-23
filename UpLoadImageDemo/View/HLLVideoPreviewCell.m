//
//  HLLVideoPreviewCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLVideoPreviewCell.h"
#import "UIImage+Helper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "HLLAssetModel.h"
#import "HLLImageManager.h"
#import "HLLCommonTools.h"
#import "UIView+Helper.h"


@implementation HLLVideoPreviewCell

- (void)configSubviews{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
}

- (void)photoPreviewCollectionViewDidScroll {
    if (_player && _player.rate != 0.0) {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)configPlayButton{
    if (!self.playButton) {
        [self.playButton removeFromSuperview];
    }
    
    
    
    [self addSubview:self.playButton];
    [self addSubview:self.iCloudErrorIcon];
    [self addSubview:self.iCloudErrorLabel];
    
}

- (void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    [self configMoviePlayer];
}

- (void)setModel:(HLLAssetModel *)model{
    [super setModel:model];
    [self configMoviePlayer];
}

- (void)configMoviePlayer{
    if (self.player) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        [self.player pause];
        self.player = nil;
    }
    if (self.model && self.model.asset) {
        [[HLLImageManager manager] fetchPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            BOOL iCloudSyncFailed = !photo && [HLLCommonTools isICloudSyncError:info[PHImageErrorKey]];
            self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
            self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
            if (self.iCloudSyncFailedHandle) {
                self.iCloudSyncFailedHandle(self.model.asset, iCloudSyncFailed);
            }
            if (photo) {
                self.cover = photo;
            }
        }];
        [[HLLImageManager manager] fetchVideoWithAsset:self.model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL iCloudSyncFailed = !playerItem && [HLLCommonTools isICloudSyncError:info[PHImageErrorKey]];
                self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
                self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
                if (self.iCloudSyncFailedHandle) {
                    self.iCloudSyncFailedHandle(self.model.asset, iCloudSyncFailed);
                }
                
                [self configPlayerWithItem:playerItem];
            });
        }];
    }else{
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
        [self configPlayerWithItem:playerItem];
    }
}

- (void)configPlayerWithItem:(AVPlayerItem *)playerItem {
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    [self configPlayButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.playButton.frame = CGRectMake(0, 64, self.al_width, self.al_height - 64);
    self.iCloudErrorIcon.frame = CGRectMake(20, [HLLCommonTools hll_isIPhoneX] ? 88 + 10 : 64 + 10, 28, 28);
    self.iCloudErrorLabel.frame = CGRectMake(53, [HLLCommonTools hll_isIPhoneX] ? 88 + 10 : 64 + 10, self.al_width - 63, 28);
}

#pragma mark 点击事件

- (void)playButtonClick{
    CMTime currentTime = self.player.currentItem.currentTime;
    CMTime durationTime = self.player.currentItem.duration;
    if (self.player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
           
        [self.player play];
            [self.playButton setImage:nil forState:UIControlStateNormal];
            [UIApplication sharedApplication].statusBarHidden = YES;
            if (self.singleTapGestureBlock) {
                self.singleTapGestureBlock();
            
        }
    }else{
        [self pausePlayerAndShowNaviBar];
    }
}

#pragma mark - Notification

- (void)appWillResignActiveNotification {
    if (_player && _player.rate != 0.0) {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)pausePlayerAndShowNaviBar{
    [_player pause];
    [_playButton setImage:[UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}


- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage hll_imageNamedFromBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIImageView *)iCloudErrorIcon{
    if (!_iCloudErrorIcon) {
        _iCloudErrorIcon = [[UIImageView alloc]init];
        _iCloudErrorIcon.image = [UIImage hll_imageNamedFromBundle:@"iCloudError"];
        _iCloudErrorIcon.hidden = YES;
    }
    return _iCloudErrorIcon;
}

- (UILabel *)iCloudErrorLabel{
    if (!_iCloudErrorLabel) {
        _iCloudErrorLabel = [[UILabel alloc]init];
        _iCloudErrorLabel.font = [UIFont systemFontOfSize:10];
        _iCloudErrorLabel.textColor = [UIColor whiteColor];
        _iCloudErrorLabel.text = @"iCloud 同步失败";
        _iCloudErrorLabel.hidden = YES;
    }
    return _iCloudErrorLabel;
}

@end
