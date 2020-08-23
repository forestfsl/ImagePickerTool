

#import "HLLImageStretchController.h"
#include <vector>
#import "MMOpenCVHelper.h"
#import "UIColor+HexRepresentation.h"
#import "MMCropView.h"
#import <opencv2/imgproc/types_c.h>
#import "UIView+Helper.h"
#import "HLLConfig.h"
#import "HLLBeautifyNavView.h"
#import "UIImage+Helper.h"

#define backgroundHex @"2196f3"

@interface HLLImageStretchController ()

@property (nonatomic, strong) UIImage     *sourceImage;
//@property (nonatomic, strong) UIImage     *cropgrayImage;
@property (nonatomic, strong) UIImage     *cropImage;

@property (nonatomic, strong) HLLBeautifyNavView *navView;
@property (nonatomic, strong) UIView      *bottomToolView;//底部工具栏view
@property (nonatomic, strong) MMCropView  *cropRectView;
@property (nonatomic, strong) UIImageView *sourceImageView;
@property (nonatomic, strong) UIButton    *closeButton;
@property (nonatomic, strong) UIButton    *saveButton;
//页面进入和离开时的时间
@property (nonatomic, assign) CFAbsoluteTime StartTime;
@property (nonatomic, assign) CFAbsoluteTime EndTime;
@property (nonatomic, assign) NSInteger stayTime;//停留时间(以秒为单位)
@end

@implementation HLLImageStretchController

- (void)dealloc{
    _sourceImage = nil;
    _navView = nil;
    _cropRectView = nil;
    _sourceImageView = nil;
    _bottomToolView = nil;
}

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        _sourceImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self initSubViews];
    self.StartTime = CFAbsoluteTimeGetCurrent();
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.EndTime = CFAbsoluteTimeGetCurrent();
    self.stayTime = (self.EndTime - self.StartTime);//停留时间(以秒为单位)

}




- (void)initSubViews{
    
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.navView];
    
    _sourceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _navView.al_maxY + 122, kScreenWidth, kScreenWidth *0.75)];
    _sourceImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_sourceImageView setImage:_sourceImage];
    _sourceImageView.clipsToBounds  = YES;
    [self.view addSubview:_sourceImageView];
    
    CGRect contentFrame = self.sourceImageView.contentFrame;
    CGRect ajustImageFrame = CGRectMake(contentFrame.origin.x-kCropButtonSize/2, contentFrame.origin.y-kCropButtonSize/2+ 122+kTopHeight, contentFrame.size.width+kCropButtonSize, contentFrame.size.height+kCropButtonSize);
    _cropRectView = [[MMCropView alloc] initWithFrame:ajustImageFrame];
    [self.view addSubview:_cropRectView];
    
    UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePan:)];
    singlePan.maximumNumberOfTouches = 1;
    [_cropRectView addGestureRecognizer:singlePan];
    
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.saveButton];
    
   
    [self.view bringSubviewToFront:_cropRectView];
    
//    [self detectEdges];
    _initialRect = self.sourceImageView.frame;
    final_Rect = self.sourceImageView.frame;
}

- (void)singlePan:(UIPanGestureRecognizer *)gesture{
    CGPoint posInStretch = [gesture locationInView:_cropRectView];
    if(gesture.state == UIGestureRecognizerStateBegan){
        [_cropRectView findPointAtLocation:posInStretch];
    }
    if(gesture.state == UIGestureRecognizerStateEnded){
        _cropRectView.activePoint.backgroundColor = [UIColor grayColor];
        _cropRectView.activePoint = nil;
        [_cropRectView checkangle:0];
    }
    [_cropRectView moveActivePointToLocation:posInStretch];
    
}


#pragma mark OpenCV
- (void)detectEdges{
    
    cv::Mat original = [MMOpenCVHelper cvMatFromUIImage:_sourceImageView.image];
    CGSize targetSize = _sourceImageView.contentSize;
    cv::resize(original, original, cvSize(targetSize.width, targetSize.height));
    
    std::vector<std::vector<cv::Point>>squares;
    std::vector<cv::Point> largest_square;
    
    find_squares(original, squares);
    find_largest_square(squares, largest_square);
    
    if (largest_square.size() == 4){
        
        // Manually sorting points, needs major improvement. Sorry.
        
        NSMutableArray *points = [NSMutableArray array];
        NSMutableDictionary *sortedPoints = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < 4; i++)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:CGPointMake(largest_square[i].x, largest_square[i].y)], @"point" , [NSNumber numberWithInt:(largest_square[i].x + largest_square[i].y)], @"value", nil];
            [points addObject:dict];
        }
        
        int min = [[points valueForKeyPath:@"@min.value"] intValue];
        int max = [[points valueForKeyPath:@"@max.value"] intValue];
        
        int minIndex = 0;
        int maxIndex = 0;
        
        int missingIndexOne = 0;
        int missingIndexTwo = 0;
        
        for (int i = 0; i < 4; i++)
        {
            NSDictionary *dict = [points objectAtIndex:i];
            
            if ([[dict objectForKey:@"value"] intValue] == min)
            {
                [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"0"];
                minIndex = i;
                continue;
            }
            
            if ([[dict objectForKey:@"value"] intValue] == max)
            {
                [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"2"];
                maxIndex = i;
                continue;
            }
            
            NSLog(@"MSSSING %i", i);
            
            missingIndexOne = i;
        }
        
        for (int i = 0; i < 4; i++)
        {
            if (missingIndexOne != i && minIndex != i && maxIndex != i)
            {
                missingIndexTwo = i;
            }
        }
        
        
        if (largest_square[missingIndexOne].x < largest_square[missingIndexTwo].x)
        {
            //2nd Point Found
            [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"3"];
            [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"1"];
        }
        else
        {
            //4rd Point Found
            [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"1"];
            [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"3"];
        }
        
        [_cropRectView topLeftCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"0"] CGPointValue]];
        [_cropRectView topRightCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"1"] CGPointValue]];
        [_cropRectView bottomRightCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"2"] CGPointValue]];
        [_cropRectView bottomLeftCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"3"] CGPointValue]];
        
        NSLog(@"%@ Sorted Points",sortedPoints);
    }else{
        
    }
    
    original.release();
    
}


// http://stackoverflow.com/questions/8667818/opencv-c-obj-c-detecting-a-sheet-of-paper-square-detection
void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point>>&squares) {
    
    // blur will enhance edge detection
    
    cv::Mat blurred(image);
    //    medianBlur(image, blurred, 9);
    GaussianBlur(image, blurred, cvSize(11,11), 0);//change from median blur to gaussian for more accuracy of square detection
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
                Canny(gray0, gray, 10, 20, 3); //
                //                Canny(gray0, gray, 0, 50, 5);
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
}

void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
    if (!squares.size())
    {
        // no squares detected
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    
    for (size_t i = 0; i < squares.size(); i++)
    {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
        
        //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
        {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}


double angle(cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

cv::Mat debugSquares(std::vector<std::vector<cv::Point> > squares, cv::Mat image ){
    
    NSLog(@"DEBUG!/?!");
    for (unsigned int i = 0; i< squares.size(); i++ ) {
        // draw contour
        
        NSLog(@"LOOP!");
        
        cv::drawContours(image, squares, i, cv::Scalar(255,0,0), 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point());
        
        // draw bounding rect
        cv::Rect rect = boundingRect(cv::Mat(squares[i]));
        cv::rectangle(image, rect.tl(), rect.br(), cv::Scalar(0,255,0), 2, 8, 0);
        
        // draw rotated rect
        cv::RotatedRect minRect = minAreaRect(cv::Mat(squares[i]));
        cv::Point2f rect_points[4];
        minRect.points(rect_points );
        for (int j = 0; j < 4; j++ ) {
            cv::line(image, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,0,255), 1, 8 ); // blue
        }
    }
    
    return image;
}

//Image Processing
- (UIImage *)grayImage:(UIImage *)processedImage{
    cv::Mat grayImage = [MMOpenCVHelper cvMatGrayFromAdjustedUIImage:processedImage];
    
    cv::GaussianBlur(grayImage, grayImage, cvSize(11,11), 0);
    cv::adaptiveThreshold(grayImage, grayImage, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
    
    UIImage *grayeditImage = [MMOpenCVHelper UIImageFromCVMat:grayImage];
    grayImage.release();
    
    return grayeditImage;
    
}

- (UIImage *)magicColor:(UIImage *)processedImage{
    cv::Mat original = [MMOpenCVHelper cvMatFromAdjustedUIImage:processedImage];
    
    cv::Mat new_image = cv::Mat::zeros(original.size(), original.type());
    
    original.convertTo(new_image, -1, 1.9, -80);
    
    original.release();
    UIImage *magicColorImage = [MMOpenCVHelper UIImageFromCVMat:new_image];
    new_image.release();
    return magicColorImage;
}

- (UIImage *)blackandWhite:(UIImage *)processedImage {
    cv::Mat original = [MMOpenCVHelper cvMatGrayFromAdjustedUIImage:processedImage];
    
    cv::Mat new_image = cv::Mat::zeros(original.size(), original.type());
    
    original.convertTo(new_image, -1, 1.4, -50);
    original.release();
    
    UIImage *blackWhiteImage = [MMOpenCVHelper UIImageFromCVMat:new_image];
    new_image.release();
    
    return blackWhiteImage;
    
}

#pragma mark Animate
- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise{
    
    CGFloat arg = _rotateSlider*M_PI;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    transform = CATransform3DRotate(transform, 0*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, 0*M_PI, 1, 0, 0);
    
    return transform;
}

- (void)rotateStateDidChange {
    
    CATransform3D transform = [self rotateTransform:CATransform3DIdentity clockwise:YES];
    
    CGFloat arg = _rotateSlider*M_PI;
    CGFloat Wnew = fabs(_initialRect.size.width * cos(arg)) + fabs(_initialRect.size.height * sin(arg));
    CGFloat Hnew = fabs(_initialRect.size.width * sin(arg)) + fabs(_initialRect.size.height * cos(arg));
    
    CGFloat Rw = final_Rect.size.width / Wnew;
    CGFloat Rh = final_Rect.size.height / Hnew;
    CGFloat scale = MIN(Rw, Rh) * 1;
    transform = CATransform3DScale(transform, scale, scale, 1);
    _sourceImageView.layer.transform = transform;
    _cropRectView.layer.transform = transform;
}

#pragma mark - button create methods
#pragma mark - 取消
- (void)closeButtonClick{
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - 完成拉伸
- (void)saveButtonClick{
    
    if([_cropRectView frameEdited]){
        
        //Thanks To stackOverflow
        CGFloat scaleFactor =  [_sourceImageView contentScale];
        CGPoint ptBottomLeft = [_cropRectView coordinatesForPoint:1 withScaleFactor:scaleFactor];
        CGPoint ptBottomRight = [_cropRectView coordinatesForPoint:2 withScaleFactor:scaleFactor];
        CGPoint ptTopRight = [_cropRectView coordinatesForPoint:3 withScaleFactor:scaleFactor];
        CGPoint ptTopLeft = [_cropRectView coordinatesForPoint:4 withScaleFactor:scaleFactor];
        
        CGFloat w1 = sqrt(pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
        CGFloat w2 = sqrt(pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
        
        CGFloat h1 = sqrt(pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
        CGFloat h2 = sqrt(pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
        
        CGFloat maxWidth = (w1 < w2) ? w1 : w2;
        CGFloat maxHeight = (h1 < h2) ? h1 : h2;
        
        cv::Point2f src[4], dst[4];
        src[0].x = ptTopLeft.x;
        src[0].y = ptTopLeft.y;
        src[1].x = ptTopRight.x;
        src[1].y = ptTopRight.y;
        src[2].x = ptBottomRight.x;
        src[2].y = ptBottomRight.y;
        src[3].x = ptBottomLeft.x;
        src[3].y = ptBottomLeft.y;
        
        dst[0].x = 0;
        dst[0].y = 0;
        dst[1].x = maxWidth - 1;
        dst[1].y = 0;
        dst[2].x = maxWidth - 1;
        dst[2].y = maxHeight - 1;
        dst[3].x = 0;
        dst[3].y = maxHeight - 1;
        
        cv::Mat undistorted = cv::Mat(cvSize(maxWidth,maxHeight), CV_8UC4);
        cv::Mat original = [MMOpenCVHelper cvMatFromUIImage:_sourceImage];
        
        NSLog(@"%f %f %f %f",ptBottomLeft.x,ptBottomRight.x,ptTopRight.x,ptTopLeft.x);
        cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
        
        @autoreleasepool {
            UIImage *image = [MMOpenCVHelper UIImageFromCVMat:undistorted];
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.completeEditBlock) {
                    self.completeEditBlock(image);
                }
            }];
            original.release();
            undistorted.release();
        }
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"非有效区域" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    
}

#pragma mark CLOSE

- (void)closeWithCompletion:(void (^)(void))completion {
    
    // Need alpha 0.0 before dismissing otherwise sticks out on dismissal
    [self dismissViewControllerAnimated:YES completion:^{
        
        completion();
        self->_sourceImageView = nil;
        self->_sourceImage = nil;
        self->_cropRectView = nil;
        [self removeFromParentViewController];
        
    }];
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(14, self.view.al_height - 42 - 115, 42, 42);
        [_closeButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_close_white"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(self.view.al_width - 44 - 14, self.view.al_height - 42 - 115, 42, 42);
        [_saveButton setImage:[UIImage hll_imageNamedFromBundle:@"icon_btn_save"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (HLLBeautifyNavView *)navView{
    if (!_navView) {
        _navView = [[HLLBeautifyNavView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopHeight)];
        _navView.title = @"拉伸";
        _navView.needBack = false;
        _navView.needSure = false;
    }
    return _navView;
}
@end
