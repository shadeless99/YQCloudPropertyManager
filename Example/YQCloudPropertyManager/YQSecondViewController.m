//
//  YQSecondViewController.m
//  YQCloudPropertyManager_Example
//
//  Created by yongqingguo on 2018/4/4.
//  Copyright © 2018年 qianjing123. All rights reserved.
//

#import "YQSecondViewController.h"
#import "YQCloudPropertyManager.h"

@interface YQSecondViewController ()<UIAlertViewDelegate>

@end

@implementation YQSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"动画配置";
    [self showInputView];
}

- (void)showInputView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入动画时间" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CGFloat duration = [alertView textFieldAtIndex:0].text.floatValue;
    Class cls = NSClassFromString(@"YQViewController");
    id<YQCloudPropertyObject> object = [[cls alloc] init];
    [YQCloudPropertyManager yq_setCGFloat:duration forObject:object name:@"_animation_duration"];
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
