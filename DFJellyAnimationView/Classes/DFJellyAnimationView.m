//
//  DFJellyAnimationView.m
//  DFJellyAnimationView
//
//  Created by 丁志伟 on 2021/2/25.
//

#import "DFJellyAnimationView.h"

#define kJellyMinHeight 100
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

static NSString *const kControlPoint = @"controlPoint";

@interface DFJellyAnimationView ()<UITableViewDelegate,UITableViewDataSource>

/// 果冻动画视图
@property (nonatomic, strong) UIView *jellyView;
/// 路径
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
/// 曲线控制点视图（为了更容易理解添加的）
@property (nonatomic, strong) UIView *controlView;
/// 控制点（切点）位置
@property (nonatomic, assign) CGPoint controlPoint;
/// 定时器
@property (nonatomic, strong) CADisplayLink *displayLink;
/// 记录当前是否正在做动画
@property (nonatomic, assign) BOOL isAnimating;
/// 列表视图
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DFJellyAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kControlPoint];
}

- (void)setupUI {
    
    [self addSubview:self.tableView];
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerAction:)];
    
    [self addObserver:self forKeyPath:kControlPoint options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    _jellyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kJellyMinHeight)];
    _jellyView.backgroundColor = [UIColor redColor];
    [self addSubview:_jellyView];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.fillColor = [UIColor redColor].CGColor;
    [self.jellyView.layer addSublayer:_shapeLayer];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    _displayLink.paused = YES;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.controlPoint = CGPointMake(kScreenWidth/2.0, kJellyMinHeight);
    _controlView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth/2.0, kJellyMinHeight, 2, 2)];
    _controlView.backgroundColor = [UIColor yellowColor];
    [self addSubview:_controlView];
    
    _isAnimating = NO;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd",indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGesture {
    if (_isAnimating) { return; }
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [panGesture translationInView:self];
        CGFloat controlHeight = point.y *0.5 + kJellyMinHeight;
        CGFloat controlX = kScreenWidth/2.0 + point.x;
        CGFloat controlY = controlHeight > kJellyMinHeight ? controlHeight : kJellyMinHeight;
        self.controlPoint = CGPointMake(controlX, controlY);
        _controlView.frame = CGRectMake(controlX, controlY, 3, 3);
//        [self updateShapeLayerPath]; // 可用KVO代替实现
    } else if (panGesture.state == UIGestureRecognizerStateCancelled ||
               panGesture.state == UIGestureRecognizerStateEnded ||
               panGesture.state == UIGestureRecognizerStateFailed) {
        _isAnimating = YES;
        _displayLink.paused = NO;
        [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.controlView.frame = CGRectMake(kScreenWidth/2.0, kJellyMinHeight, 3, 3);
        } completion:^(BOOL finished) {
            if (finished) {
                self.displayLink.paused = YES;
                self.isAnimating = NO;
            }
        }];
    }
}

- (void)calculatePath {
    CALayer *layer = _controlView.layer.presentationLayer;
    self.controlPoint = CGPointMake(layer.position.x, layer.position.y);
//    [self updateShapeLayerPath]; // 可用KVO代替实现
}

- (void)updateShapeLayerPath {
    // 更新_shapeLayer的形状
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(kScreenWidth, 0)];
    [path addLineToPoint:CGPointMake(kScreenWidth, kJellyMinHeight)];
    [path addQuadCurveToPoint:CGPointMake(0, kJellyMinHeight) controlPoint:self.controlPoint];
    [path closePath];
    _shapeLayer.path = path.CGPath;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kControlPoint]) {
        [self updateShapeLayerPath];
    }
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kJellyMinHeight, kScreenWidth, kScreenHeight - kJellyMinHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        if (@available(iOS 11.0,*)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

@end
