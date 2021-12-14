//
//  DrawView.m
//  ScreenShot
//
//  Created by wuxi on 2021/11/23.
//

#import "DrawView.h"

@interface DrawView()

@property (nonatomic,strong) UIBezierPath *beganPath;

@property (nonatomic,strong) CAShapeLayer *shapeLayer;

@property (nonatomic,assign) CGPoint startPoint;
@end

@implementation DrawView

-(void)setParams:(double)scale color:(PenColor)color penSize:(PenSize)penSize {
    [self.action setParams:color scale:scale penSize:penSize];
    self.action.actionType = ActionTypePoint;
    self.shapeLayer = [[CAShapeLayer alloc]init];
    [self.layer addSublayer:self.shapeLayer];
    self.shapeLayer.lineWidth = penSize*2+1;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = self.action.color.CGColor;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.frame, point);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([event touchesForView:self].count == 1) {
        [self.vc startDrawLines];
        CGPoint touchPoint = [[touches  anyObject] locationInView:self];
        self.beganPath = [[UIBezierPath alloc]init];
        [self.beganPath moveToPoint:touchPoint];
        self.startPoint = touchPoint;
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([event touchesForView:self].count == 1) {
        [self moveToNextPoint:touches];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([event touchesForView:self].count == 1) {
        [self moveToNextPoint:touches];
        
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self];
        if (_startPoint.x != currentPoint.x && _startPoint.y != currentPoint.y) {
            [_vc finishCurrentDraw];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
}

-(void)moveToNextPoint:(NSSet<UITouch *> *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    //上一个点的坐标
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGPoint middlePoint = midPoint(previousPoint,currentPoint);
    [self.beganPath addQuadCurveToPoint:currentPoint controlPoint:middlePoint];
    self.shapeLayer.path = self.beganPath.CGPath;
}

- (void)clear {
    [self.shapeLayer removeFromSuperlayer];
    self.beganPath = nil;
    self.shapeLayer = nil;
    self.action = nil;
}

// 计算中间点
CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (ActionObject *)action{
    if (!_action) {
        _action = [[ActionObject alloc]init];
    }
    _action.actionType = ActionTypePoint;
    return _action;
}


@end
