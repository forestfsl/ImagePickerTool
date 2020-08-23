//
//  ViewController.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/13.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "ViewController.h"
#import "HLLModelPicViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 100, 100, 100);
    btn.titleLabel.text = @"跳转";
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(jumpToDrawVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)jumpToDrawVC{
   
    HLLModelPicViewController *picVC = [[HLLModelPicViewController alloc]init];

    [self.navigationController pushViewController:picVC animated:YES];
}


@end
