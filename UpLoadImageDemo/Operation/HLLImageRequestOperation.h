//
//  HLLImageRequestOperation.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


@interface HLLImageRequestOperation : NSOperation

typedef void(^HLLImageRequestCompleteBlock)(UIImage * _Nullable photo,NSDictionary * _Nullable info,BOOL isDegraded);

typedef void(^HLLImageRequestProgressBlock)(double progress, NSError * _Nullable error, BOOL *stop, NSDictionary * _Nullable info);


@property (nonatomic, copy, nullable) HLLImageRequestCompleteBlock completedBlock;
@property (nonatomic, copy, nullable) HLLImageRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;

@property (assign, nonatomic, getter=isExecuting) BOOL executing;
@property (assign, nonatomic, getter=isFinished) BOOL finished;


- (instancetype _Nullable )initWithAsset:(PHAsset *_Nullable)asset completion:(HLLImageRequestCompleteBlock _Nullable )completionBlock progressHandler:(HLLImageRequestProgressBlock _Nullable )progressHandler;

- (void)done;

@end


