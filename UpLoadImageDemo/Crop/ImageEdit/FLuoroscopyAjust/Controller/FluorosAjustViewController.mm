//
//  CropViewController.m
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//

#import "FluorosAjustViewController.h"
#include <vector>
#import "MMOpenCVHelper.h"
#import "UIColor+HexRepresentation.h"
#import "MMCropView.h"
#import <opencv2/imgproc/types_c.h>
#import "HLLConfig.h"
#import "UIView+Helper.h"

#define backgroundHex @"2196f3"
#define kCameraToolBarHeight 100

@interface FluorosAjustViewController () {
    UIScrollView *scrollView;
}

@property (strong, nonatomic) MMCropView *cropRectView;
@property (strong, nonatomic) UIView     *bottomToolView;//底部工具栏view

@end

@implementation FluorosAjustViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
   
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    [self initCropFrame];
    //    [self adjustPossition];
    
    CGRect ajustImageFrame = CGRectMake(_sourceImageView.contentFrame.origin.x,_sourceImageView.contentFrame.origin.y+kTopHeight,_sourceImageView.contentFrame.size.width,_sourceImageView.contentFrame.size.height);
    _cropRectView = [[MMCropView alloc] initWithFrame:ajustImageFrame];
    [self.view addSubview:_cropRectView];
    
    UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePan:)];
    singlePan.maximumNumberOfTouches = 1;
    [_cropRectView addGestureRecognizer:singlePan];
    
    [self setCropUI];
    [self.view bringSubviewToFront:_cropRectView];
    
    [self detectEdges];
    _initialRect = self.sourceImageView.frame;
    final_Rect = self.sourceImageView.frame;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)initCropFrame {
    _sourceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kTopHeight, self.view.bounds.size.width, self.view.bounds.size.height-kCameraToolBarHeight-kTopHeight)];
    [_sourceImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_sourceImageView setImage:_adjustedImage];
    _sourceImageView.clipsToBounds=YES;
    
    [self.view addSubview:_sourceImageView];
    
    //    NSLog(@"%f %f",_sourceImageView.contentFrame.size.height,_sourceImageView.contentFrame.size.height);
    
    [self buttonsScroll];
    
    [UIView animateWithDuration:0.5 animations:^{
        self->scrollView.frame = CGRectMake(0, -kTopHeight, self.view.bounds.size.width, kTopHeight);
    }];
}

- (void)buttonsScroll {
    
    NSArray *butArr=@[@"",@"noedit_filled",@"original_filled",@"blackwhite_filled",@"magic_filled",@"default_filled"];
    NSArray *labArr=@[@"",@"Original",@"Gray Scale",@"Black & White",@"Magic Color",@"Default"];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTopHeight)];
    [self.view addSubview:scrollView];
    NSUInteger i;
    int xCoord=0;
    int yCoord=0;
    int buttonWidth=80;
    int buttonHeight=40;
    int buffer = 10;
    for (i = 1; i <= 5; i++)
    {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [aButton setImage:[UIImage renderImage:[butArr objectAtIndex:i]] forState:UIControlStateNormal];
        aButton.frame = CGRectMake(xCoord, yCoord,buttonWidth,buttonHeight);
        aButton.tintColor=[UIColor whiteColor];
        aButton.tag = i;
        [aButton addTarget:self action:@selector(scrolllButAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(xCoord,40,buttonWidth,24)];
        aLabel.text = [labArr objectAtIndex:i];
        aLabel.textColor = [UIColor whiteColor];
        [aLabel setAdjustsFontSizeToFitWidth:YES];
        aLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        aLabel.textAlignment = NSTextAlignmentCenter;
        [scrollView addSubview:aButton];
        [scrollView addSubview:aLabel];
        
        xCoord += buttonWidth + buffer;
    }
    [scrollView setContentSize:CGSizeMake(xCoord, yCoord)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor colorWithHexString:backgroundHex];
}


- (void)scrolllButAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
            _sourceImageView.image = _cropImage;
            break;
        case 2:
            _sourceImageView.image = [self grayImage:_cropImage];
            break;
        case 3:
            _sourceImageView.image = [self blackandWhite:_cropImage];
            break;
        case 4:
            _sourceImageView.image = [self magicColor:_cropImage];
            break;
            
        case 5:
            _sourceImageView.image = _adjustedImage;
            _cropRectView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self->scrollView.frame=CGRectMake(0, -kTopHeight, self.view.bounds.size.width, kTopHeight);
                
            }];
            break;
            
    }
}

- (void)setCropUI{
    
    [self.view addSubview:self.bottomToolView];
    
    [self.bottomToolView addSubview:self.cropBut];
    [self.bottomToolView addSubview:self.dismissBut];
    
    //Done
    self.dismissBut.tintColor = [UIColor whiteColor];
    //    self.dismissBut.backgroundColor=[UIColor colorWithHexString:backgroundHex];
    //    self.dismissBut.layer.cornerRadius = self.dismissBut.frame.size.width / 2;
    //    self.dismissBut.clipsToBounds=YES;
    
    [self.dismissBut setImage:[UIImage renderImage:@"Done"] forState:UIControlStateNormal];
    [self.leftRotateBut setImage:[UIImage renderImage:@"Left"] forState:UIControlStateNormal];
    [self.rightRotateBut setImage:[UIImage renderImage:@"Right"] forState:UIControlStateNormal];
    [self.cropBut setImage:[UIImage renderImage:@"Crop"] forState:UIControlStateNormal];
    
    
    self.cropBut.tintColor = [UIColor whiteColor];
    self.leftRotateBut.tintColor = [UIColor whiteColor];
    self.rightRotateBut.tintColor = [UIColor whiteColor];
    //    self.cropBut.backgroundColor=[UIColor colorWithHexString:backgroundHex];
    //    self.cropBut.layer.cornerRadius = self.cropBut.frame.size.width / 2;
    //    self.cropBut.clipsToBounds=YES;
    
}


//- (void)adjustPossition
//{
//    CGAffineTransform saveState = _sourceImageView.transform;
//
//    _sourceImageView.transform = CGAffineTransformIdentity;
//
//    [_sourceImageView setFrameToFitImage];
//
//    _sourceImageView.transform = saveState;
//}

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


- (void)ajustAction:(UIButton *)sender {
    
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
        cv::Mat original = [MMOpenCVHelper cvMatFromUIImage:_adjustedImage];
        
        NSLog(@"%f %f %f %f",ptBottomLeft.x,ptBottomRight.x,ptTopRight.x,ptTopLeft.x);
        cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
        
        [UIView transitionWithView:_sourceImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            self.sourceImageView.image=[MMOpenCVHelper UIImageFromCVMat:undistorted];
            self.cropImage = self->_sourceImageView.image;
            
        } completion:^(BOOL finished) {
            self->_cropRectView.hidden=YES;
            [UIView animateWithDuration:0.5 animations:^{
                self->scrollView.frame=CGRectMake(0, 0, self.view.bounds.size.width, kTopHeight);
                
            }];
            
        }];
        
        original.release();
        undistorted.release();
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"非有效区域" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
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

- (void)completeAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.cropdelegate respondsToSelector:@selector(didFinishCropping:from:)]) {
        [self.cropdelegate didFinishCropping:self.sourceImageView.image from:self];
    }
}

- (void)rightRotateAction:(UIButton *)sender {
    
    
    //    CIImage *imgToRotate = [CIImage imageWithCGImage:_sourceImageView.image.CGImage];
    //
    //    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    //
    //    CIImage *rotatedImage = [imgToRotate imageByApplyingTransform:transform];
    //
    //    CGRect extent = [rotatedImage extent];
    //
    //    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    //
    //    CGImageRef cgImage = [context createCGImage:rotatedImage fromRect:extent];
    //
    //    _adjustedImage = [UIImage imageWithCGImage:cgImage];
    //
    //
    //    [UIView transitionWithView:_sourceImageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    //        _sourceImageView.image = _adjustedImage;
    //    } completion:^(BOOL finished) {
    //
    //    }];
    //
    //
    //    CGRect cropFrame=CGRectMake(_sourceImageView.contentFrame.origin.x,_sourceImageView.contentFrame.origin.y+kTopHeight,_sourceImageView.contentFrame.size.width,_sourceImageView.contentFrame.size.height);
    //    _cropRect.frame=cropFrame;
    //
    //    [self detectEdges];
    //    CGImageRelease(cgImage);
    
    CGFloat value = (int)floorf((_rotateSlider + 1)*2) + 1;
    
    if(value>4){ value -= 4; }
    _rotateSlider = value / 2 - 1;
    [UIView animateWithDuration:0.5 animations:^{
        [self rotateStateDidChange];
    }];
    
    
}

- (void)leftRotateAction:(UIButton *)sender {
    
    //    CIImage *imgToRotate = [CIImage imageWithCGImage:_sourceImageView.image.CGImage];
    //
    //    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
    //
    //    CIImage *rotatedImage = [imgToRotate imageByApplyingTransform:transform];
    //
    //    CGRect extent = [rotatedImage extent];
    //
    //    CIContext *context =  [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    //
    //    CGImageRef cgImage = [context createCGImage:rotatedImage fromRect:extent];
    //
    //    _adjustedImage = [UIImage imageWithCGImage:cgImage];
    //
    //    [UIView transitionWithView:_sourceImageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    //        _sourceImageView.image = _adjustedImage;
    //    } completion:^(BOOL finished) {
    //
    //    }];
    //
    //    CGRect cropFrame=CGRectMake(_sourceImageView.contentFrame.origin.x,_sourceImageView.contentFrame.origin.y+kTopHeight,_sourceImageView.contentFrame.size.width,_sourceImageView.contentFrame.size.height);
    //    _cropRect.frame=cropFrame;
    //
    //
    //    [self detectEdges];
    //    CGImageRelease(cgImage);
    //
    
    CGFloat value = (int)floorf((_rotateSlider + 1)*2) - 1;
    
    if(value>4){ value -= 4; }
    _rotateSlider = value / 2 - 1;
    [UIView animateWithDuration:0.5 animations:^{
        [self rotateStateDidChange];
    }];
}


#pragma mark CLOSE

- (void)closeWithCompletion:(void (^)(void))completion {
    
    // Need alpha 0.0 before dismissing otherwise sticks out on dismissal
    [self dismissViewControllerAnimated:YES completion:^{
        
        completion();
        self->_sourceImageView = nil;
        self->_adjustedImage = nil;
        self->_cropRectView = nil;
        [self removeFromParentViewController];
        
    }];
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
    
    //    NSLog(@"%@",_sourceImageView);
}

#pragma mark - subview create
- (UIView *)bottomToolView{
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-100, kScreenWidth, 100)];
        _bottomToolView.backgroundColor = [UIColor colorWithRed:26 green:117 blue:238 alpha:1.0];
    }
    return _bottomToolView;
}

#pragma mark - button create methods
- (UIButton *)cropBut{
    if (!_cropBut) {
        _cropBut = [[UIButton alloc] initWithFrame:CGRectMake(50, 27, 60, 45)];
        [_cropBut addTarget:self action:@selector(ajustAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cropBut setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [_cropBut setTitle:@"矫正" forState:UIControlStateNormal];
    }
    return _cropBut;
}

- (UIButton *)dismissBut{
    if (!_dismissBut) {
        _dismissBut = [[UIButton alloc] initWithFrame:CGRectMake(_cropBut.al_maxX + 60, 27, 60, 45)];
        [_dismissBut addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_dismissBut setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [_dismissBut setTitle:@"完成" forState:UIControlStateNormal];
    }
    return _dismissBut;
}
@end


