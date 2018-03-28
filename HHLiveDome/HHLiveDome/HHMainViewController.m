//
//  HHMainViewController.m
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import "HHMainViewController.h"
#import "HHCaptureViewController.h"
#import "HHBroadListViewController.h"

@interface HHMainViewController ()

@end

@implementation HHMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"HH直播";
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self _initSubView];
}


- (void)_initSubView{
    
    UIButton *captureBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureBut setTitle:@"采集" forState:UIControlStateNormal];
    captureBut.titleLabel.font = [UIFont systemFontOfSize:15];
    captureBut.frame = CGRectMake(170, 200, 50, 50);
    [self.view addSubview:captureBut];
    captureBut.backgroundColor = [UIColor greenColor];
    [captureBut addTarget:self action:@selector(captureAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *playBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBut setTitle:@"播放" forState:UIControlStateNormal];
    playBut.titleLabel.font = [UIFont systemFontOfSize:15];
    playBut.frame = CGRectMake(170, 300, 50, 50);
    [self.view addSubview:playBut];
    playBut.backgroundColor = [UIColor greenColor];
    [playBut addTarget:self action:@selector(palyAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)captureAction{
    HHCaptureViewController *caputureVC = [[HHCaptureViewController alloc] init];
    [self.navigationController pushViewController:caputureVC animated:YES];
}

- (void)palyAction{
    HHBroadListViewController *broadVC = [[HHBroadListViewController alloc] init];
    [self.navigationController pushViewController:broadVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
