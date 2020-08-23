//
//  NSTimer+Helper.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//




#import <Foundation/Foundation.h>

typedef void(^TimerFireBlock)(void);


NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Helper)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval firing:(TimerFireBlock)fireBlock;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock;

@end

NS_ASSUME_NONNULL_END
