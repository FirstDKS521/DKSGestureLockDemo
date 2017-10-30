//
//  LockViewController.m
//  DKSGestureLockDemo
//
//  Created by aDu on 2017/10/27.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import "LockViewController.h"
#import "DKSLockView.h"

#define K_Width [UIScreen mainScreen].bounds.size.width
#define K_Height [UIScreen mainScreen].bounds.size.height
@interface LockViewController ()<DKSLockViewDelegate>

@property (nonatomic, strong) DKSLockView *lockView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, copy) NSString *lastPwdStr;
@property (nonatomic, assign) NSInteger timesNum; //输入的次数

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手势锁";
    self.view.backgroundColor = [UIColor grayColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.timesNum = 0;
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.lockView];
}

#pragma mark ====== DKSLockViewDelegate ======
- (void)getstureLockViewFinished:(NSMutableString *)pwdStr {
    NSLog(@"%@", pwdStr);
    if (pwdStr.length < 4) {
        self.statusLabel.text = @"密码不能少于4个点";
        [self.lockView checkResult:ResultTypeNotEnough];
        return;
    }
    
    if (self.timesNum == 0) {
        self.statusLabel.text = @"请再次输入以校验";
        [self.lockView checkResult:ResultTypeTrue];
        self.timesNum++;
    } else {
        if ([pwdStr isEqualToString:self.lastPwdStr]) {
            self.statusLabel.text = @"密码校验成功";
            [self.lockView checkResult:ResultTypeTrue];
        } else {
            self.statusLabel.text = @"密码校验失败";
            [self.lockView checkResult:ResultTypeFalse];
        }
        self.timesNum = 0;
    }
    self.lastPwdStr = pwdStr;
}

#pragma mark ====== init ======
- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.frame = CGRectMake(0, 25, K_Width, 50);
        _statusLabel.backgroundColor = [UIColor whiteColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (DKSLockView *)lockView {
    if (!_lockView) {
        _lockView = [[DKSLockView alloc] initWithFrame:CGRectMake(0, 100, K_Width, K_Width)];
        _lockView.delegate = self;
        _lockView.backgroundColor = [UIColor whiteColor];
    }
    return _lockView;
}

@end
