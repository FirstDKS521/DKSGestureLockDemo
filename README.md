#iOS开发：手势锁

![效果图.png](http://upload-images.jianshu.io/upload_images/1840399-b9516104feed8398.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

思路：先布局九个`UIButton `并设置背景图片，然后给当前视图添加欢动手势`UIPanGestureRecognizer`，手势触碰到的UIButton更换背景图片；

给每个button设置不同的`tag`值，手势滑动过的button使用U`UIBezierPath`划线连接中心点，并保存到数组；

![效果GIF.gif](http://upload-images.jianshu.io/upload_images/1840399-d15cf5c2bffe0af6.gif?imageMogr2/auto-orient/strip)

####.h文件代码如下：

```
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
```


####.m文件代码如下：

```
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
```

其中给九个`UIButton`布局的代码再次贴出来，这个地方还是稍微花费了些时间的

```
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
```
具体的功能实现，可以下载demo看一下，其实整个实现下来，就是简单的贝塞尔曲线的划线以及不同业务要求，代码很简单；
