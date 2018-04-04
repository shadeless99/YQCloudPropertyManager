//
//  YQViewController.m
//  YQCloudPropertyManager
//
//  Created by qianjing123 on 04/03/2018.
//  Copyright (c) 2018 qianjing123. All rights reserved.
//

#import "YQViewController.h"
#import "YQCloudProperty.h"
#import "YQSecondViewController.h"

@interface YQViewController ()<YQCloudPropertyObject>
{
    UIButton *btn;
}

YQCloudFloat(animation_duration) // 动画时间

@end

@implementation YQViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _animation_duration = 4.f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"YQCloudPropertyManager Demo";
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, 100, 40);
    btn.center = self.view.center;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.layer.borderWidth = 1.f;
    [btn setTitle:@"开始动画" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(startAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.bounds = CGRectMake(0, 0, 100, 40);
    btn1.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn1.layer.borderWidth = 1.f;
    [btn1 setTitle:@"设置" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn1.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
    btn1.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[YQCloudPropertyManager sharedManager] loadProperties:self];
}

- (void)startAnimation {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.duration = _animation_duration;
    [btn.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
}

- (void)stopAnimation {
    [btn.layer removeAllAnimations];
}

- (void)restartAnimation {
    [self stopAnimation];
    [self startAnimation];
}

- (void)setting {
    YQSecondViewController *secondVC = [[YQSecondViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
