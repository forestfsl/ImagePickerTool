//
//  HLLVideoPreviewCell.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLPhotoPreViewCell.h"


@class AVPlayer,AVPlayerLayer;

@interface HLLVideoPreviewCell : HLLPhotoPreViewCell
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) UIImageView *iCloudErrorIcon;
@property (nonatomic, strong) UILabel *iCloudErrorLabel;
@property (nonatomic, copy) void (^iCloudSyncFailedHandle)(id asset, BOOL isSyncFailed);
- (void)pausePlayerAndShowNaviBar;

@end


