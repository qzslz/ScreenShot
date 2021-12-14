//
//  UIView+Present.m
//  GreenRecycle
//
//  Created by qzslz on 2020/4/11.
//  Copyright © 2020 qzslz. All rights reserved.
//

#import "UIView+Present.h"
#import <objc/runtime.h>
#import "AlertManager.h"

@implementation UIView (Present)

- (void)setClickBackHide:(BOOL)clickBackHide {
    objc_setAssociatedObject(self, @selector(clickBackHide), [NSNumber numberWithBool:clickBackHide], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)clickBackHide {
    return [objc_getAssociatedObject(self, @selector(clickBackHide)) boolValue];
}

- (void)setIsPresenting:(BOOL)isPresenting {
    objc_setAssociatedObject(self, @selector(isPresenting), [NSNumber numberWithBool:isPresenting], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isPresenting {
    return [objc_getAssociatedObject(self, @selector(isPresenting)) boolValue];
}

- (void)setPresentType:(NSInteger)presentType {
    objc_setAssociatedObject(self, @selector(presentType), [NSNumber numberWithBool:presentType], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)presentType {
    return [objc_getAssociatedObject(self, @selector(presentType)) integerValue];
}



- (void)presentCenterOffset:(CGPoint)point inView:(UIView *)view {
    if (self.isPresenting) {
        return;
    }
    self.isPresenting = YES;
    self.presentType = 1;
    
    CGSize backViewSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    CGSize selfSize = self.frame.size;
    
    //重叠弹框不加载动画，直接布局
    AlertManager * manager = [AlertManager shareInstance];
    [manager.alertViews addObject:self];
    if (manager.alertViews.count >= 2) {
        UIView * backView = manager.backView;
        [backView addSubview:self];
        manager.alertViews[manager.alertViews.count-2].hidden = YES;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(selfSize.width);
            make.height.mas_equalTo(selfSize.height);
            make.centerX.equalTo(backView.mas_centerX).offset(point.x);
            make.centerY.equalTo(backView.mas_centerY).offset(-point.y);
        }];
        [backView layoutIfNeeded];
        return;
    }

    UIView * backView = [[UIView alloc]init];
    manager.backView = backView;
    TapGesture(backView, @selector(clickBackViewCenterType))
    backView.backgroundColor = RGBHexA(0x000000, 0.5);
    backView.alpha = 0;
    if (view) {//加载到指定view上
        backViewSize = view.frame.size;
        [view addSubview:backView];
    }else{//默认加载到window上
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:backView];
    }
    backView.frame = CGRectMake(0, 0, backViewSize.width, backViewSize.height);
    //将self布局到背景视图上并往下偏移60用作上移动画
    [backView addSubview:self];
    
    self.alpha = 0.5;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(selfSize.width);
        make.height.mas_equalTo(selfSize.height);
        make.centerX.equalTo(backView.mas_centerX).offset(point.x);
        make.centerY.equalTo(backView.mas_centerY).offset(-point.y-100);
    }];
    [self layoutIfNeeded];
    [backView layoutIfNeeded];
    
    //开始显示动画
    [UIView animateWithDuration:0.5 animations:^{
        backView.alpha = 1;
        self.alpha = 1;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(selfSize.width);
            make.height.mas_equalTo(selfSize.height);
            make.centerX.equalTo(backView.mas_centerX).offset(point.x);
            make.centerY.equalTo(backView.mas_centerY).offset(-point.y);
        }];
        [backView layoutIfNeeded];
        
    }];
    
}

- (void)dismissCenter {
    if (self.isPresenting) {
        UIView * backView = self.superview;
        
        //如果有重叠弹框，则不加载消失动画以及背景渐消
        AlertManager * manager = [AlertManager shareInstance];
        if (manager.alertViews.count >= 2) {
            [self removeFromSuperview];
            [manager.alertViews removeObject:self];
            manager.alertViews.lastObject.hidden = NO;
            return;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            backView.alpha = 0;
            self.alpha = 0;
            WeakObj(backView)
            CGSize selfSize = self.frame.size;
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(selfSize.width);
                make.height.mas_equalTo(selfSize.height);
                make.centerX.equalTo(backView.mas_centerX);
                make.centerY.equalTo(backView.mas_centerY).offset(-100);
            }];
            [backViewWeak layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            self.isPresenting = NO;
            [backView removeFromSuperview];
        }];
        [manager.alertViews removeObject:self];
        manager.backView = nil;
    }
}

//点击背景视图
-(void)clickBackViewCenterType {
    if (self.clickBackHide) {
        [self dismissCenter];
    }
}

//点击背景视图
-(void)clickBackViewBottomType {
    if (self.clickBackHide) {
        [self dismissBottom];
    }
}


- (void)presentBottomInView:(UIView *)view {
    [self presentBottomOffset:CGPointZero inView:view];
}

- (void)presentBottomOffset:(CGPoint)point inView:(UIView *)view {
    if (self.isPresenting) {
        return;
    }
    self.isPresenting = YES;
    self.presentType = 1;
    
    CGSize backViewSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    CGSize selfSize = self.frame.size;
    
    //重叠弹框不加载动画，直接布局
    AlertManager * manager = [AlertManager shareInstance];
    [manager.alertViews addObject:self];
    if (manager.alertViews.count >= 2) {
        UIView * backView = manager.backView;
        [backView addSubview:self];
        manager.alertViews[manager.alertViews.count-2].hidden = YES;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(selfSize.width);
            make.height.mas_equalTo(selfSize.height);
            make.centerX.equalTo(backView.mas_centerX).offset(point.x);
            make.bottom.equalTo(backView.mas_bottom).offset(-point.y);
        }];
        [backView layoutIfNeeded];
        return;
    }
    
    UIView * backView = [[UIView alloc]init];
    manager.backView = backView;
    TapGesture(backView, @selector(clickBackViewBottomType))
    backView.backgroundColor = RGBHexA(0x000000, 0.5);
    backView.alpha = 0;
    if (view) {//加载到指定view上
        backViewSize = view.frame.size;
        [view addSubview:backView];
    }else{//默认加载到window上
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:backView];
    }
    backView.frame = CGRectMake(0, 0, backViewSize.width, backViewSize.height);
    //将self布局到背景视图上并往下偏移60用作上移动画
    [backView addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(selfSize.width);
        make.height.mas_equalTo(selfSize.height);
        make.centerX.equalTo(backView.mas_centerX).offset(point.x);
        make.bottom.equalTo(backView.mas_bottom).offset(selfSize.height);
    }];
    [self layoutIfNeeded];
    [backView layoutIfNeeded];
    
    //开始显示动画
    [UIView animateWithDuration:0.5 animations:^{
        backView.alpha = 1;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(selfSize.width);
            make.height.mas_equalTo(selfSize.height);
            make.centerX.equalTo(backView.mas_centerX).offset(point.x);
            make.bottom.equalTo(backView.mas_bottom).offset(-point.y);
        }];
        [backView layoutIfNeeded];
        
    }];
    
}

- (void)dismissBottom {
    if (self.isPresenting) {
        UIView * backView = self.superview;
        
        //如果有重叠弹框，则不加载消失动画以及背景渐消
        AlertManager * manager = [AlertManager shareInstance];
        if (manager.alertViews.count >= 2) {
            [self removeFromSuperview];
            [manager.alertViews removeObject:self];
            manager.alertViews.lastObject.hidden = NO;
            return;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            backView.alpha = 0;
            WeakObj(backView)
            CGSize selfSize = self.frame.size;
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(selfSize.width);
                make.height.mas_equalTo(selfSize.height);
                make.centerX.equalTo(backView.mas_centerX);
                make.bottom.equalTo(backView.mas_bottom).offset(selfSize.height);
            }];
            [backViewWeak layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            self.isPresenting = NO;
            [backView removeFromSuperview];
        }];
        [manager.alertViews removeObject:self];
        manager.backView = nil;
    }
}

- (void)allDismiss {
    AlertManager * manager = [AlertManager shareInstance];
    UIView * lastView = manager.alertViews.lastObject;
    for (UIView * itemView in manager.alertViews) {
        if (itemView != lastView) {
            [manager.alertViews removeObject:itemView];
            [itemView removeFromSuperview];
        }
    }
    if (lastView.presentType == 0) {
        [lastView dismissCenter];
    }
    else{
        [lastView dismissBottom];
    }
}

@end
