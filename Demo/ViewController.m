//
//  ViewController.m
//  Demo
//
//  Created by Lin YiPing on 2017/10/24.
//  Copyright © 2017年 LeoFeng. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    
    
}

- (IBAction)click:(UIButton *)sender {
    
    CameraViewController  *vc = [[CameraViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}


@end
