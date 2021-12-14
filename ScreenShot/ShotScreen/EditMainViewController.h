//
//  EditMainViewController.h
//  ScreenShot
//
//  Created by wuxi on 2021/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditMainViewController : UIViewController

@property (nonatomic,strong) UIImage *image;

/// 结束手绘线条
-(void)finishCurrentDraw;

/// 开始手绘线条
-(void)startDrawLines;

/// 开始拖动otherTypeView
-(void)startDragOtherTypeView;

@end

NS_ASSUME_NONNULL_END
