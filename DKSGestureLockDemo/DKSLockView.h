//
//  DKSLockView.h
//  DKSGestureLockDemo
//
//  Created by aDu on 2017/10/27.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LockResultType) {
    ResultTypeTrue, //密码正确
    ResultTypeFalse, //密码错误
    ResultTypeNotEnough, //密码长度不够
};
@protocol DKSLockViewDelegate <NSObject>

/**
 密码结果
 @param pwdStr 结果
 */
- (void)getstureLockViewFinished:(NSMutableString *)pwdStr;

@end

@interface DKSLockView : UIView

@property (nonatomic, weak)id <DKSLockViewDelegate>delegate;

/**
 清除布局
 */
- (void)clearLockView;

/**
 判断绘制结果
 */
- (void)checkResult:(LockResultType)type;

@end
