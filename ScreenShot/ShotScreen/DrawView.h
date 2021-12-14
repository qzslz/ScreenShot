//
//  DrawView.h
//  ScreenShot
//
//  Created by wuxi on 2021/11/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EditMainViewController.h"
#import "BaseTypes.h"
#import "ActionObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawView : UIView

@property (nonatomic,weak) EditMainViewController * vc;

@property (nonatomic,strong,nullable) ActionObject *action;

-(void)setParams:(double)scale color:(PenColor)color penSize:(PenSize)penSize;

-(void)clear;

@end

NS_ASSUME_NONNULL_END
