//
//  OtherTypeView.m
//  ScreenShot
//
//  Created by wuxi on 2021/11/30.
//

#import "OtherTypeView.h"

typedef enum : NSUInteger {
    MovePositionNone = -1,
    MovePositionLeftTop = 0,
    MovePositionRightTop,
    MovePositionLeftBottom,
    MovePositionRightBottom,
    MovePositionCenter
} MovePosition;

@interface OtherTypeView()

@property (nonatomic,assign) Boolean isMoving;

@property (nonatomic,strong) CAShapeLayer *shapeLayer;

@property (nonatomic,strong) UIBezierPath *path;

@property (nonatomic,assign) MovePosition position;

@property (weak, nonatomic) IBOutlet UIView *tapView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *points;


@end

@implementation OtherTypeView

+ (instancetype)initWithAction:(ActionObject *)action {
    OtherTypeView * otherTypeView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil].lastObject;
    CGRect rect;
    otherTypeView.backgroundColor = [UIColor clearColor];
    if (action.actionType == ActionTypeTxt) {
        rect = CGRectMake(0, 0, 150, 80);
        otherTypeView.textView.editable = NO;
        otherTypeView.textView.hidden = NO;
        otherTypeView.tapView.hidden = NO;
        otherTypeView.textView.textColor = action.color;
        otherTypeView.textView.text = !action.text ? @"这里写文字" : action.text;
        otherTypeView.textView.font = [UIFont systemFontOfSize:13+action.penSize*4];
    }
    else if (action.actionType == ActionTypeRectangle) {
        rect = CGRectMake(0, 0, 150, 150);
    }
    else {
        rect = CGRectMake(0, 0, 150, 150);
    }
    otherTypeView.textView.delegate = otherTypeView;
    otherTypeView.frame = rect;
    otherTypeView.action = action;
    otherTypeView.position = MovePositionNone;
    if (action.actionType <= 1) {
        otherTypeView.shapeLayer = [[CAShapeLayer alloc]init];
        [otherTypeView.layer addSublayer:otherTypeView.shapeLayer];
        otherTypeView.shapeLayer.lineWidth = action.penSize*2+1;
        otherTypeView.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        otherTypeView.shapeLayer.strokeColor = action.color.CGColor;
        if (action.actionType == 0) {
            otherTypeView.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 20, rect.size.width-40, rect.size.height-40) cornerRadius:4];
            otherTypeView.shapeLayer.path = otherTypeView.path.CGPath;
        }
        else{
            otherTypeView.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, 20, rect.size.width-40, rect.size.height-40)];
            otherTypeView.shapeLayer.path = otherTypeView.path.CGPath;

        }
    }
    return otherTypeView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    // 判断是否双击
    if (touch.tapCount == 2) {
        [self tapTextView];
        return;
    }
    CGPoint currentPoint = [touch locationInView:self];
    CGSize size = self.frame.size;
    CGRect moveRect = CGRectMake(20, 20, size.width-40, size.height-40);
    self.isMoving = CGRectContainsPoint(moveRect, currentPoint);
    if (CGRectContainsPoint(moveRect, currentPoint)) {
        self.position = MovePositionCenter;
    }
    else if (CGRectContainsPoint(CGRectMake(0, 0, 20, 20), currentPoint)) {
        self.position = MovePositionLeftTop;
    }
    else if (CGRectContainsPoint(CGRectMake(0, size.height-20, 20, 20), currentPoint)) {
        self.position = MovePositionLeftBottom;
    }
    else if (CGRectContainsPoint(CGRectMake(size.width-20, 0, 20, 20), currentPoint)) {
        self.position = MovePositionRightTop;
    }
    else {
        self.position = MovePositionRightBottom;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    CGRect r = self.frame;
    CGFloat x_d = currentPoint.x - previousPoint.x;
    CGFloat y_d = currentPoint.y - previousPoint.y;
    
    if (self.position == MovePositionCenter) {
        self.frame = CGRectMake(r.origin.x+x_d, r.origin.y+y_d, r.size.width, r.size.height);
    }
    else{
        CGRect resultRect;
        // 左上角缩放
        if (self.position == MovePositionLeftTop) {
            resultRect = CGRectMake(r.origin.x+x_d, r.origin.y+y_d, r.size.width-x_d, r.size.height-y_d);
        }
        else if (self.position == MovePositionLeftBottom) {
            resultRect = CGRectMake(r.origin.x+x_d, r.origin.y, r.size.width-x_d, r.size.height+y_d);
        }
        else if (self.position == MovePositionRightTop) {
            resultRect = CGRectMake(r.origin.x, r.origin.y+y_d, r.size.width+x_d, r.size.height-y_d);
        }
        else {
            resultRect = CGRectMake(r.origin.x, r.origin.y, r.size.width+x_d, r.size.height+y_d);
        }
        if (resultRect.size.height < 70 || resultRect.size.width < 90) {
            return;
        }
        self.frame = resultRect;
        
        if (self.path) {
            if (self.action.actionType == 0) {
                self.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 20, resultRect.size.width-40, resultRect.size.height-40) cornerRadius:4];
            }
            else {
                self.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, 20, resultRect.size.width-40, resultRect.size.height-40)];
            }
            
            self.shapeLayer.path = self.path.CGPath;
        }
    }
    [self.vc startDragOtherTypeView];
    self.action.react = self.frame;
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.action.text = textView.text;
    self.tapView.hidden = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.action.text = textView.text;
}

- (void)tapTextView{
    self.tapView.hidden = YES;
    self.textView.editable = YES;
    [self.textView becomeFirstResponder];
}

- (void)endAllOperation {
    [self.textView resignFirstResponder];
    [self.points enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ((UIView *)obj).hidden = YES;
    }];
}

- (void)setViewFrame:(CGRect)frame {
    self.frame = frame;
    if (self.action.actionType == 0) {
        self.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 20, frame.size.width-40, frame.size.height-40) cornerRadius:4];
        self.shapeLayer.path = self.path.CGPath;
    }
    else {
        self.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, 20, frame.size.width-40, frame.size.height-40)];
        self.shapeLayer.path = self.path.CGPath;
    }
}


@end
