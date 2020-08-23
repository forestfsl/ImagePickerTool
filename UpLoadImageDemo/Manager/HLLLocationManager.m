//
//  HLLLocationManager.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/16.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLLocationManager.h"
#import "HLLTemplatePickerViewController.h"


@interface HLLLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
//定位成功的回调block
@property (nonatomic, copy) void (^successBlock)(NSArray<CLLocation *> *);
//编码成功的回调block
@property (nonatomic, copy) void (^geocodeBlock)(NSArray *geocodeArray);
///定位失败的回调block
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

@end

@implementation HLLLocationManager




+ (instancetype)manager{
    static HLLLocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
        manager.locationManager = [[CLLocationManager alloc]init];
        manager.locationManager.delegate = manager;
        [manager.locationManager requestWhenInUseAuthorization];
    });
    return manager;
}

///开始定位
- (void)startLocation{
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:nil];
}

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *))successBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [self startLocationWithSuccessBlock:successBlock failureBlock:failureBlock geocoderBlock:nil];
}

- (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock{
    [self startLocationWithSuccessBlock:nil failureBlock:nil geocoderBlock:geocoderBlock];
}

- (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *))successBlock failureBlock:(void (^)(NSError *))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray))geocoderBlock{
    [self.locationManager startUpdatingLocation];
    _successBlock = successBlock;
    _geocodeBlock = geocoderBlock;
    _failureBlock = failureBlock;
}

///结束定位
- (void)stopUpdatingLocation{
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate

///地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [manager stopUpdatingLocation];
    
    if (self.successBlock) {
        self.successBlock(locations);
    }
    
    if (self.geocodeBlock && locations.count) {
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:[locations firstObject] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            self.geocodeBlock(placemarks);
        }];
    }
}

///定位失败回调方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败原因是:%@",error);
    switch ([error code]) {
        case kCLErrorDenied:
        {
            //用户禁止了定位权限
        }
            break;
            
        default:
            break;
    }
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

@end
