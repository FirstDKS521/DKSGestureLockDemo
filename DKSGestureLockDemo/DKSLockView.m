//
//  DKSLockView.m
//  DKSGestureLockDemo
//
//  Created by aDu on 2017/10/27.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import "DKSLockView.h"

#define Btn_Width 60 //button的高度
#define K_Width [UIScreen mainScreen].bounds.size.width
#define K_Height [UIScreen mainScreen].bounds.size.height
@interface DKSLockView ()

@property (nonatomic, strong) NSMutableArray *selectBtns; //选中的按钮
@property (nonatomic, strong) NSMutableArray *errorBtns; //错误的按钮数组
@property (nonatomic, assign) BOOL isFinish; //是否完成
@property (nonatomic, assign) CGPoint currentPoint; //当前触摸点

@property (nonatomic, assign) LockResultType resultType;

@end

@implementation DKSLockView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutViews];
    }
    return self;
}

#pragma mark ====== 创建视图 ======
- (void)layoutViews {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    //间距
    float margin = (K_Width - (Btn_Width * 3)) / 4;
    //当前所在的列
    int curClounm = 0;
    //当前所在的行
    int curRow = 0;
    //创建按钮
    for (int i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"select"] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
        btn.tag = i + 1;
        
        //当前所在的列
        curClounm = i % 3;
        //当前所在的行
        curRow = i / 3;
        float x = margin * (curClounm + 1) + Btn_Width * curClounm;
        float y = margin * (curRow + 1) + Btn_Width * curRow;
        btn.frame = CGRectMake(x, y, Btn_Width, Btn_Width);
        [self addSubview:btn];
    }
}

- (void)drawRect:(CGRect)rect {
    if (_selectBtns.count == 0) {
        return;
    }
    //把所有选中的按钮中心连线
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < self.selectBtns.count; i++) {
        UIButton *btn = self.selectBtns[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    //判断是否完成手势
    if (self.isFinish) {
        //传递创建的密码
        NSMutableString *pwdStr = [self transferGestrueResult];
        //线的颜色
        [[UIColor greenColor] set];
        if (self.delegate && [self.delegate respondsToSelector:@selector(getstureLockViewFinished:)]) {
            [self.delegate getstureLockViewFinished:pwdStr];
        }
        
        switch (self.resultType) {
            case ResultTypeTrue:
                [[UIColor clearColor] set];
                break;
            case ResultTypeFalse:
                [[UIColor redColor] set];
                for (UIButton *btn in self.errorBtns) {
                    [btn setSelected:YES];
                }
                break;
            case ResultTypeNotEnough:
                [[UIColor clearColor] set];
                break;
            default:
                break;
        }
    } else {
        [path addLineToPoint:self.currentPoint];
        [[UIColor greenColor] set];
    }
    
    //连线样式
    [path setLineJoinStyle:kCGLineJoinRound];
    [path setLineCapStyle:kCGLineCapButt];
    //线宽
    [path setLineWidth:1.0];
    //开始绘制
    [path stroke];
}

#pragma mark ====== 手势 ======
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        for (UIButton *btn in self.errorBtns) {
            [btn setSelected:NO];
        }
        [self.errorBtns removeAllObjects];
    }
    _currentPoint = [pan locationInView:self];
    
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, _currentPoint)) {
            if (btn.selected == NO) {
                btn.selected = YES;
                [self.selectBtns addObject:btn];
            }
        }
    }
    
    //重绘
    [self setNeedsDisplay];
    //监听手指松开
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.isFinish = YES;
    }
}

#pragma mark ====== 清除绘制 ======
- (void)clearLockView {
    self.isFinish = NO;
    for (UIButton *btn in self.selectBtns) {
        btn.selected = NO;
    }
    [self.selectBtns removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark ====== 手势密码 ======
- (NSMutableString *)transferGestrueResult {
    NSMutableString *resultStr = [NSMutableString string];
    for (UIButton *btn in self.selectBtns) {
        [resultStr appendFormat:@"%@", @(btn.tag - 1)];
    }
    return resultStr;
}

#pragma mark ====== 检测绘制结果 ======
- (void)checkResult:(LockResultType)type {
    self.resultType = type;
    switch (type) {
        case ResultTypeTrue:
            break;
        case ResultTypeFalse:
            self.errorBtns = [NSMutableArray arrayWithArray:self.selectBtns];
            break;
        case ResultTypeNotEnough:
            break;
        default:
            break;
    }
    [self clearLockView];
}

#pragma mark ====== init ======
- (NSMutableArray *)selectBtns {
    if (!_selectBtns) {
        _selectBtns = [NSMutableArray arrayWithCapacity:1];
    }
    return _selectBtns;
}

- (NSMutableArray *)errorBtns {
    if (!_errorBtns) {
        _errorBtns = [NSMutableArray arrayWithCapacity:1];
    }
    return _errorBtns;
}

@end
