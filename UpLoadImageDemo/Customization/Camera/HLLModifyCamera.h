
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    HLLCameraPositionRear,
    HLLCameraPositionFront
} HLLCameraPosition;

typedef enum : NSUInteger {
   
    HLLCameraFlashOff,
    HLLCameraFlashOn,
    HLLCameraFlashAuto
} HLLCameraFlash;

typedef enum : NSUInteger {
   
    HLLCameraMirrorOff,
    HLLCameraMirrorOn,
    HLLCameraMirrorAuto
} HLLCameraMirror;

extern NSString *const HLLModifyCameraErrorDomain;
typedef enum : NSUInteger {
    HLLModifyCameraErrorCodeCameraPermission = 10,
    HLLModifyCameraErrorCodeMicrophonePermission = 11,
    HLLModifyCameraErrorCodeSession = 12,
    HLLModifyCameraErrorCodeVideoNotEnabled = 13
} HLLModifyCameraErrorCode;

@interface HLLModifyCamera : UIViewController

//设备更改时候出发
@property (nonatomic, copy) void (^onDeviceChange)(HLLModifyCamera *camera, AVCaptureDevice *device);

//错误返回
@property (nonatomic, copy) void (^onError)(HLLModifyCamera *camera, NSError *error);

//照相机开始录制
@property (nonatomic, copy) void (^onStartRecording)(HLLModifyCamera* camera);

//拍摄质量
@property (copy, nonatomic) NSString *cameraQuality;

//闪光灯
@property (nonatomic, readonly) HLLCameraFlash flash;

//切换摄像头
@property (nonatomic) HLLCameraMirror mirror;

//照相机位置更改
@property (nonatomic) HLLCameraPosition position;

/**
 * 默认 AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
 */
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**
 * 是否可以开启录像设置
 */
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/**
 * 是否正在录制
 */
@property (nonatomic, getter=isRecording) BOOL recording;

/**
 * 是否支持放大
 */
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

/**
 * 最大所放量
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 * Fixess the orientation after the image is captured is set to Yes.
 * see: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
 */
@property (nonatomic) BOOL fixOrientationAfterCapture;

/**
 * 是否获取焦点
 */
@property (nonatomic) BOOL tapToFocus;

/**
 *
 * 设置设备方向
 */
@property (nonatomic) BOOL useDeviceOrientation;

/**
 * 照相机权限回调
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**
 * 请求麦克风权限
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

/**
 *
 * 初始化方法
 */
- (instancetype)initWithQuality:(NSString *)quality position:(HLLCameraPosition)position videoEnabled:(BOOL)videoEnabled;


- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled;

/**
 * 开始session
 */
- (void)start;

/**
 * 停止session
 */
- (void)stop;

-(void)capture:(void (^)(HLLModifyCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock;


-(void)capture:(void (^)(HLLModifyCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;


-(void)capture:(void (^)(HLLModifyCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture;

/*
 * 开始录制视频
 */
- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(HLLModifyCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock;

/**
 * 结束录制视频
 */
- (void)stopRecording;

/**
 * 附加到哪个控制器上面
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

/**
 * 更改position
 */
- (HLLCameraPosition)togglePosition;

/**
 * 更新flash 模式
 */
- (BOOL)updateFlashMode:(HLLCameraFlash)cameraFlash;

/**
 * 闪光灯是否开启
 */
- (BOOL)isFlashAvailable;


- (BOOL)isTorchAvailable;


- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

/**
 * 判断是否是前置摄像头
 */
+ (BOOL)isFrontCameraAvailable;

/**
 * 判断是否是后置摄像头
 */
+ (BOOL)isRearCameraAvailable;
@end
