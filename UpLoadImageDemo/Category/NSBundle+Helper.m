//
//  NSBundle+Helper.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "NSBundle+Helper.h"
#import "HLLModelPicViewController.h"


@implementation NSBundle (Helper)

+ (NSBundle *)hll_fetchBundle{
    NSBundle *bundle = [NSBundle bundleForClass:[HLLModelPicViewController class]];
    NSURL *url = [bundle URLForResource:@"MediaResource" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

@end
