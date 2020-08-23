//
//  NSFileManager+Helper.h
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Helper)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;

@end

NS_ASSUME_NONNULL_END
