//
//  OtherTypeView.h
//  ScreenShot
//
//  Created by wuxi on 2021/11/30.
//

#import <UIKit/UIKit.h>
#import "BaseTypes.h"
#import "ActionObject.h"
#import "EditMainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OtherTypeView : UIView<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic,weak) EditMainViewController * vc;

@property (nonatomic, strong) ActionObject *action;

+ (instancetype)initWithAction:(ActionObject *)action;

-(void)endAllOperation;

- (void)setViewFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
