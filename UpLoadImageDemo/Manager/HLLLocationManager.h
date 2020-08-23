//
//  HLLLocationManager.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



@interface HLLLocationManager : NSObject

+ (instancetype)manager;

///开始定位
- (void)startLocation;

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *))successBlock failureBlock:(void (^)(NSError *))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock;

///结束定位
- (void)stopUpdatingLocation;

@end


