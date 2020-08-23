//
//  HLLBeautifyImageBorderView.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/23.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLLBeautifyImageBorderViewDelegate <NSObject>

- (void)cancel;
- (void)commit;

@optional
- (void)didSelectBorderAtIndex:(NSInteger)index;

@end

@interface HLLBeautifyImageBorderView : UIView

@property (nonatomic, weak) id<HLLBeautifyImageBorderViewDelegate> delegate;
@end


