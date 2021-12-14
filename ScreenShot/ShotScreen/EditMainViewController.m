//
//  EditMainViewController.m
//  ScreenShot
//
//  Created by wuxi on 2021/11/22.
//

#import "EditMainViewController.h"
#import "BaseTypes.h"
#import "DrawView.h"
#import "ActionObject.h"
#import "OtherTypeView.h"

@interface EditMainViewController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *point;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerX;
@property (strong, nonatomic) OtherTypeView *currentOtherTypeView;

@property (strong, nonatomic) DrawView *drawView;
@property (strong, nonatomic) UIView *contentView;

/// 当前选择的功能类型
@property (assign,nonatomic) BottomItemType currenbaseType;
/// 画笔大小
@property (assign,nonatomic) PenSize penSize;
/// 画笔颜色
@property (assign,nonatomic) PenColor penColor;
/// 更多功能类型
@property (assign, nonatomic) ActionType actionType;
/// 放大的倍率
@property (assign,nonatomic) double scale;

/// 当前叠加绘制的图
@property (strong,nonatomic) NSMutableArray<ActionObject *> *actions;
/// 撤销的图
@property (strong,nonatomic) NSMutableArray<ActionObject *> *revertActions;

@end

@implementation EditMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self baseInit];
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(onDeviceOrientationChange:)
            name:UIDeviceOrientationDidChangeNotification
          object:nil];
}

-(void)baseInit {
    self.scale = 1.0f;
    self.currenbaseType  = BottomItemTypePen;
    self.penSize = PenSizeMiddle;
    self.penColor = PenColorRed;
    self.actions = [NSMutableArray array];
    self.revertActions = [NSMutableArray array];
    
    self.image = [UIImage imageNamed:@"test.png"];
    
}

-(void)setUI {
    
    
    CGSize size = self.containerView.frame.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:rect];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 3.0f;
    self.scrollView.contentSize = size;
    [self.containerView addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc]init];
    [self.scrollView addSubview:self.contentView];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.centerYAnchor constraintEqualToAnchor:self.scrollView.centerYAnchor].active = YES;
    [self.contentView.centerXAnchor constraintEqualToAnchor:self.scrollView.centerXAnchor].active = YES;
    [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;
    [self.contentView.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor].active = YES;
    
    self.imageView = [[UIImageView alloc]initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.imageView];
    [self.imageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.imageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.imageView.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;
    [self.imageView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor].active = YES;

    self.drawView = [[DrawView alloc]init];
    self.drawView.vc = self;
    [self.drawView setParams:_scale color:_penColor penSize:_penSize];
    self.drawView.translatesAutoresizingMaskIntoConstraints = NO;
    self.drawView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.drawView];
    [self.drawView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [self.drawView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.drawView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.drawView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    
    self.point.layer.cornerRadius = 3;
    self.point.clipsToBounds = YES;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.point.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.backBtn.enabled = NO;
    self.forwardBtn.enabled = NO;
}

- (void)finishCurrentDraw{
    UIImage * resultImg = [self getmakeImage];
    self.imageView.image = resultImg;
    self.drawView.action.resultImg = resultImg;
    [self.actions addObject:self.drawView.action];
    [self.revertActions removeAllObjects];
    [self.drawView clear];
    [self.drawView setParams:_scale color:_penColor penSize:_penSize];
    [self judgeForwardAndRevert];
    [self.currentOtherTypeView removeFromSuperview];
}

/// 将传入的视图绘制成image
- (UIImage *)getmakeImage {
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/// 判断撤销和恢复按钮是否可用
-(void)judgeForwardAndRevert {
    self.backBtn.enabled = self.actions.count > 0;
    self.forwardBtn.enabled = self.revertActions.count > 0;
}

/// 完成编辑
- (IBAction)finishBtnClick:(UIButton *)sender {
}

/// 删除并取消编辑
- (IBAction)deleteBtnClick:(UIButton *)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定放弃本次编辑？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"确定放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:sure];
    [alertController addAction:cancle];
    [alertController presentationController];
    
}

/// 切换画笔
- (IBAction)penBtnClick:(UIButton *)sender {
    if (_currenbaseType != BottomItemTypePen) {
        _currenbaseType = BottomItemTypePen;
        [self.collectionView reloadData];
    }
    _centerX.constant = 0;
}

/// 切换颜色
- (IBAction)colorBtnClick:(UIButton *)sender {
    if (_currenbaseType != BottomItemTypeColor) {
        _currenbaseType = BottomItemTypeColor;
        [self.collectionView reloadData];
    }
    _centerX.constant = 56;
}

/// 添加（添加形状、文本）
- (IBAction)addBtnClick:(UIButton *)sender {
    if (_currenbaseType != BottomItemTypeMore) {
        _currenbaseType = BottomItemTypeMore;
        [self.collectionView reloadData];
    }
    _centerX.constant = 112;
}

/// 撤销
- (IBAction)backBtnClick:(UIButton *)sender {
    // 当前处于othertypeView的编辑状态
    if (self.currentOtherTypeView) {
        [self.currentOtherTypeView removeFromSuperview];
        self.currentOtherTypeView = nil;
    }
    
    ActionObject *action = self.actions.lastObject;
    [self.actions removeLastObject];
    [self.revertActions addObject:action];
    if (self.actions.count == 0) {
        self.imageView.image = self.image;
    }
    else{
        action = self.actions.lastObject;
        self.imageView.image = action.resultImg;
    }
    [self judgeForwardAndRevert];
}

/// 恢复
- (IBAction)forwardBtnClick:(UIButton *)sender {
    ActionObject *action = self.revertActions.lastObject;
    // 还原otherTypeView
    if (action.actionType < ActionTypePoint ) {
        [self.currentOtherTypeView endAllOperation];
        UIImage * resultImg = [self getmakeImage];
        self.imageView.image = resultImg;
        self.actions.lastObject.resultImg = resultImg;
        [self.currentOtherTypeView removeFromSuperview];
        
        
        OtherTypeView *otherTypeView = [OtherTypeView initWithAction:action];
        self.currentOtherTypeView = otherTypeView;
        [otherTypeView setViewFrame:action.react];
        [self.contentView addSubview:otherTypeView];
    }
    else{
        if (self.currentOtherTypeView) {
            [self.currentOtherTypeView removeFromSuperview];
            self.currentOtherTypeView = nil;
        }
    }
    [self.revertActions removeLastObject];
    [self.actions addObject:action];
    if (action.actionType == ActionTypePoint) {
        self.imageView.image = action.resultImg;
    }
    [self judgeForwardAndRevert];
}

/// 开始拖动otherTypeView
-(void)startDragOtherTypeView {
    [self.revertActions removeAllObjects];
    [self judgeForwardAndRevert];
}


/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification {
    CGSize size = self.containerView.frame.size;
    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    self.contentView.frame = CGRectMake(0, 0, size.width*self.scale, size.height*self.scale);

}

/// 开始手绘线条或者开始新的othertypeview
-(void)startDrawLines {
    if (self.currentOtherTypeView) {
        [self.currentOtherTypeView endAllOperation];
        UIImage * resultImg = [self getmakeImage];
        self.imageView.image = resultImg;
        self.actions.lastObject.resultImg = resultImg;
        [self.revertActions removeAllObjects];
        [self judgeForwardAndRevert];
        [self.currentOtherTypeView removeFromSuperview];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma setter&&getter

- (void)setScale:(double)scale {
    _scale = scale;
}

-(void)setCurrenbaseType:(BottomItemType)currenbaseType {
    _currenbaseType = currenbaseType;
}

#pragma scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollView == self.scrollView ? self.contentView : nil;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    [self.drawView clear];
//    NSLog(@"开始缩放");
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    self.scale = scale;
    [self.drawView setParams:_scale color:_penColor penSize:_penSize];
//    NSLog(@"结束缩放");
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    NSLog(@"缩放中");
}

// 开始滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        self.drawView.action.scale = self.scale;
        self.drawView.action.offset = scrollView.contentOffset;
    }
}

#pragma collectionView delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *itemCounts = @[@3,@9,@3];
    return [itemCounts[self.currenbaseType] integerValue];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc]init];
    }
    CGRect rect = CGRectMake(0, 0, 40, 40);
    UILabel * text;
    UIImageView * imageView;
    BOOL isCurrentChoose = NO;
    if (cell.contentView.subviews.count > 0) {
        text = cell.contentView.subviews[0];
        imageView = cell.contentView.subviews[1];
    }
    else{
        text = [[UILabel alloc]initWithFrame:rect];
        text.textAlignment = NSTextAlignmentCenter;
        text.textColor = [UIColor whiteColor];
        text.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:text];
        imageView = [[UIImageView alloc]initWithFrame:rect];
        [cell.contentView addSubview:imageView];
        
    }
    
    cell.backgroundColor = [UIColor clearColor];
    imageView.hidden = YES;
    text.text = @"";
    
    if (_currenbaseType == BottomItemTypePen) {
        NSArray * titles = @[@"小",@"中",@"大"];
        text.text = titles[indexPath.row];
        isCurrentChoose = _penSize == indexPath.row;
    }
    else if (_currenbaseType == BottomItemTypeColor) {
        cell.backgroundColor = [ActionObject getColorByEnumValue:indexPath.row];
        isCurrentChoose = _penColor == indexPath.row;
    }
    else{
        NSArray * titles = @[@"rectangle",@"tuo",@"txt"];
        imageView.image = [UIImage imageNamed:titles[indexPath.row]];
        imageView.hidden = NO;
//        isCurrentChoose = _actionType == indexPath.row;
    }
    
    cell.contentView.layer.borderWidth = isCurrentChoose ? 1 : 0;
    cell.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(40, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currenbaseType == BottomItemTypePen) {
        self.penSize = indexPath.row;
    }
    else if (_currenbaseType == BottomItemTypeColor) {
        self.penColor = indexPath.row;
    }
    else{
        [self startDrawLines];
        ActionObject *action = [[ActionObject alloc]initWithType:indexPath.row color:_penColor scale:_scale penSize:_penSize];
        [self.actions addObject:action];
        OtherTypeView *otherTypeView = [OtherTypeView initWithAction:action];
        self.currentOtherTypeView = otherTypeView;
        otherTypeView.center = self.scrollView.center;
        [self.contentView addSubview:otherTypeView];
        [self.revertActions removeAllObjects];
        [self judgeForwardAndRevert];
    }
    [self.drawView setParams:_scale color:_penColor penSize:_penSize];
    [collectionView reloadData];
}
@end
