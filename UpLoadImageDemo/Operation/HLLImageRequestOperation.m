//
//  HLLImageRequestOperation.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLImageRequestOperation.h"
#import "HLLImageManager.h"



@implementation HLLImageRequestOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype _Nullable )initWithAsset:(PHAsset *_Nullable)asset completion:(HLLImageRequestCompleteBlock _Nullable )completionBlock progressHandler:(HLLImageRequestProgressBlock _Nullable )progressHandler{
    if (self = [super init]) {
        self.asset = asset;
        self.completedBlock = completionBlock;
        self.progressBlock = progressHandler;
        _executing = NO;
        _finished = NO;
    }
    return self;
}

- (void)start{
    self.executing = YES;
    [[HLLImageManager manager] fetchPhotoWithAsset:self.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isDegraded) {
                if (self.completedBlock) {
                    self.completedBlock(photo,info,isDegraded);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self done];
                });
            }
        });
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(progress, error, stop, info);
            }
        });
    } networkAccessAllowed:YES];
}

- (void)done{
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset{
    self.asset = nil;
    self.completedBlock = nil;
    self.progressBlock = nil;
}

- (void)setFinished:(BOOL)finished{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isAsynchronous{
    return YES;
}

@end
