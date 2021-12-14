//
//  ActionObject.h
//  ScreenShot
//
//  Created by wuxi on 2021/11/23.
//

#import <Foundation/Foundation.h>
#import "BaseTypes.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActionObject : NSObject
// 操作类型：文字、矩形、椭圆、线条
@property (nonatomic,assign) ActionType actionType;
// 画笔颜色
@property (nonatomic,assign) PenColor penColor;
// 放大比例
@property (nonatomic,assign) double scale;
// 画笔大小,strokeWidth = penSize*2 + 1
@property (nonatomic,assign) PenSize penSize;
// 在scollview的偏移量
@property (nonatomic,assign) CGPoint offset;
// 绘制对象的react
@property (nonatomic,assign) CGRect react;
// 生成的结果图
@property (nonatomic,strong) UIImage *resultImg;
// 文本内容
@property (nonatomic,copy) NSString *text;

// 获取画笔的uicolor值
@property (nonatomic,copy,readonly) UIColor *color;

- (instancetype)initWithType:(ActionType)type color:(PenColor)color scale:(double)scale penSize:(PenSize)penSize;
-(void)setParams:(PenColor)color scale:(double)scale penSize:(PenSize)penSize;
+(UIColor *)getColorByEnumValue:(PenColor)color;

@end

NS_ASSUME_NONNULL_END
