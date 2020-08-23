//
//  HLLBeautifyCropViewController.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HLLImageTagDirectionNormal,
    HLLImageTagDirectionLeft,
    HLLImageTagDirectionRight,
}HLLImageTagDirection;

/** 比例 */
struct HLLImageTagPositionProportion {
    CGFloat x;
    CGFloat y;
};
typedef struct HLLImageTagPositionProportion HLLImageTagPositionProportion;
HLLImageTagPositionProportion HLLImageTagPositionProportionMake(CGFloat x, CGFloat y);

@interface HLLImageTagInfo : NSObject

/** 初始化 */
+ (HLLImageTagInfo *)tagInfo;

/** 记录位置点 */
@property (nonatomic, assign) CGPoint point;
/** 记录位置点在父视图中的比例 */
@property (nonatomic, assign) HLLImageTagPositionProportion proportion;
/** 方向 */
@property (nonatomic, assign) HLLImageTagDirection direction;
/** 标题 */
@property (nonatomic,   copy) NSString *title;
/** 其他需要存储的数据 */
@property (nonatomic, strong) id object;


@end

NS_ASSUME_NONNULL_END
