//
//  UIView+Present.h
//  GreenRecycle
//
//  Created by qzslz on 2020/4/11.
//  Copyright © 2020 qzslz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Present)
//点击背景视图是否消失，yes消失
@property (assign, nonatomic) BOOL clickBackHide;
//显示状态 0：居中 ，1：底部
@property (assign, nonatomic) NSInteger presentType;
//是否正在显示
@property (assign, nonatomic) BOOL isPresenting;

/// 显示到屏幕中间
/// @param point 偏移量 x> 0右移，y>0下移
/// @param view 加载在什么视图,nil时默认添加在window上
-(void)presentCenterOffset:(CGPoint)point inView:(nullable UIView *) view;

/// 从中间消失
-(void)dismissCenter;

//从底部弹出
-(void)presentBottomInView:(UIView *)view;

//从底部弹出
-(void)presentBottomOffset:(CGPoint)point inView:(nullable UIView *) view;

//从底部消失
-(void)dismissBottom;

//重叠弹框的时候强制全部消失,以最后一个弹框的弹出方式作为消失动画方式
-(void)allDismiss;

@end

NS_ASSUME_NONNULL_END
