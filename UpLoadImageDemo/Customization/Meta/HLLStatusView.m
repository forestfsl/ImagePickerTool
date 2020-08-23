//
//  HLLStatusView.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLStatusView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Helper.h"

@implementation HLLStatusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)setupView {
    self.flashControl.delegate = self;
}

- (void)flashControlWillExpand {
    [UIView animateWithDuration:0.2f animations:^{
        self.elapsedTimeLabel.alpha = 0.0f;
    }];
}

- (void)flashControlDidCollapse {
    [UIView animateWithDuration:0.1f animations:^{
        self.elapsedTimeLabel.alpha = 1.0f;
    }];
}

@end
