//
//  ViewController.m
//  BMKSingeleLocation
//
//  Created by cbs on 16/8/30.
//  Copyright © 2016年 CBS. All rights reserved.
//

#import "ViewController.h"
#import "BSAMapLocationManager.h"
#import "BSBMKLocationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [[UIButton alloc] init];
    [self.view addSubview:button];
    
    button.frame = CGRectMake(0, 0, 44, 44);
    button.center = self.view.center;
    [button setTitle:@"开始定位" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    button.titleLabel.numberOfLines = 0;
    
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)btnClick:(UIButton *)sender {
    
    static dispatch_source_t timer = nil;
    
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }else{
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC, 0.05 * NSEC_PER_SEC);
        
        __block typeof (self) _self = self;
        dispatch_source_set_event_handler(timer, ^{
            [_self getUserLocation];
        });
        dispatch_resume(timer);
    }
}
- (void)getUserLocation{
    
    [BSAMapLocationManager aMapUserLocation:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSLog(@"AMap %f  %f",location.coordinate.latitude,location.coordinate.longitude);
        NSLog(@"%@",regeocode.formattedAddress);
    }];
    
    [BSBMKLocationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, BMKReverseGeoCodeResult *regeocode, NSError *error) {
        NSLog(@"BMK %f  %f",location.coordinate.latitude,location.coordinate.longitude);
        NSLog(@"%@",regeocode.address);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
