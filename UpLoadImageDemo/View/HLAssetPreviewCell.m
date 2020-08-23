//
//  HLAssetPreviewCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/15.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLAssetPreviewCell.h"
#import "HLLAssetModel.h"


@implementation HLAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self configSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    return self;
}


- (void)configSubviews{
    
}

#pragma mark - Notification

- (void)photoPreviewCollectionViewDidScroll {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
