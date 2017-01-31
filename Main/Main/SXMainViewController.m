//
//  SXMainViewController.m
//  SXNews
//
//  Created by 董 尚先 on 15-1-31.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXMainViewController.h"
#import <Tools/SXTitleLabel.h>
#import <Tools/UIView+Frame.h>
#import <Search-Category/Lothar+Search.h>
#import <Weather-Category/Lothar+Weather.h>
#import <News-Category/Lothar+News.h>

@interface SXMainViewController ()<UIScrollViewDelegate>

/** 标题栏 */
@property (weak, nonatomic) IBOutlet UIScrollView *smallScrollView;

/** 下面的内容栏 */
@property (weak, nonatomic) IBOutlet UIScrollView *bigScrollView;
@property(nonatomic,strong) SXTitleLabel *oldTitleLable;
@property (nonatomic,assign) CGFloat beginOffsetX;

/** 新闻接口的数组 */
@property(nonatomic,strong) NSArray *arrayLists;
@property(nonatomic,assign,getter=isWeatherShow)BOOL weatherShow;
@property(nonatomic,strong)UIImageView *tran;
@property(nonatomic, strong)UIView *weatherPage;
//@property(nonatomic,strong)SXWeatherEntity *weatherModel;

@property(nonatomic,strong)UIButton *rightItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TopToTop;

@property(nonatomic,strong)UITableViewController *needScrollToTopPage;

@end

@implementation SXMainViewController

#pragma mark - ******************** 懒加载
- (NSArray *)arrayLists
{
    if (_arrayLists == nil) {
        _arrayLists = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"NewsURLs.plist" ofType:nil]];
    }
    return _arrayLists;
}

#pragma mark - ******************** 页面首次加载
- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showRightItem) name:@"SXAdvertisementKey" object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.smallScrollView.showsHorizontalScrollIndicator = NO;
    self.smallScrollView.showsVerticalScrollIndicator = NO;
    self.smallScrollView.scrollsToTop = NO;
    self.bigScrollView.scrollsToTop = NO;
    self.bigScrollView.delegate = self;
    
    [self addController];
    [self addLabel];
    
    CGFloat contentX = self.childViewControllers.count * [UIScreen mainScreen].bounds.size.width;
    self.bigScrollView.contentSize = CGSizeMake(contentX, 0);
    self.bigScrollView.pagingEnabled = YES;
    
    // 添加默认控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.bigScrollView.bounds;
    [self.bigScrollView addSubview:vc.view];
    SXTitleLabel *lable = [self.smallScrollView.subviews firstObject];
    lable.scale = 1.0;
    self.bigScrollView.showsHorizontalScrollIndicator = NO;
    
   
    UIButton *rightItem = [[UIButton alloc]init];
    self.rightItem = rightItem;
    
    [self.navigationController.navigationBar addSubview:rightItem];
    
    rightItem.y = 0;
    rightItem.width = 45;
    rightItem.height = 45;
    [rightItem addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    rightItem.x = [UIScreen mainScreen].bounds.size.width - rightItem.width;
    NSLog(@"%@",NSStringFromCGRect(rightItem.frame));
    [rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
    
    self.needScrollToTopPage = self.childViewControllers[0];
    [self addWeather];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.TopToTop.constant = 0;
    self.rightItem.hidden = NO;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"rightItem"]) {
        self.rightItem.hidden = YES;
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"rightItem"];
    }
    self.rightItem.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.rightItem.alpha = 1;
    }];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.rightItem.hidden = YES;
    self.rightItem.transform = CGAffineTransformIdentity;
    [self.rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
}

- (void)showRightItem
{
    self.rightItem.hidden = NO;
}

#pragma mark - ******************** 添加方法

/** 添加子控制器 */
- (void)addController
{
    for (int i=0 ; i<self.arrayLists.count ;i++) {
        UIViewController *vc = [[Lothar shared] News_aViewControllerWithUrlString:self.arrayLists[i][@"urlString"] atIndex:i];
        vc.title = self.arrayLists[i][@"title"];
        [self addChildViewController:vc];
    }
}

/** 添加标题栏 */
- (void)addLabel {
    for (int i = 0; i < 8; i++) {
        CGFloat lblW = 70;
        CGFloat lblH = 40;
        CGFloat lblY = 0;
        CGFloat lblX = i * lblW;
        SXTitleLabel *lbl1 = [[SXTitleLabel alloc]init];
        UIViewController *vc = self.childViewControllers[i];
        lbl1.text =vc.title;
        lbl1.frame = CGRectMake(lblX, lblY, lblW, lblH);
        lbl1.font = [UIFont fontWithName:@"HYQiHei" size:19];
        [self.smallScrollView addSubview:lbl1];
        lbl1.tag = i;
        lbl1.userInteractionEnabled = YES;
        
        [lbl1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
    }
    self.smallScrollView.contentSize = CGSizeMake(70 * 8, 0);
    
}

/** 标题栏label的点击事件 */
- (void)lblClick:(UITapGestureRecognizer *)recognizer
{
    SXTitleLabel *titlelable = (SXTitleLabel *)recognizer.view;
    
    CGFloat offsetX = titlelable.tag * self.bigScrollView.frame.size.width;
   
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    
    [self.bigScrollView setContentOffset:offset animated:YES];
    
    [self setScrollToTopWithTableViewIndex:titlelable.tag];
}

#pragma mark - ScrollToTop

- (void)setScrollToTopWithTableViewIndex:(NSInteger)index
{
    self.needScrollToTopPage.tableView.scrollsToTop = NO;
    self.needScrollToTopPage = self.childViewControllers[index];
    self.needScrollToTopPage.tableView.scrollsToTop = YES;
}

#pragma mark - ******************** scrollView代理方法

/** 滚动结束后调用（代码导致） */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.bigScrollView.frame.size.width;
    
    // 滚动标题栏
    SXTitleLabel *titleLable = (SXTitleLabel *)self.smallScrollView.subviews[index];
    
    CGFloat offsetx = titleLable.center.x - self.smallScrollView.frame.size.width * 0.5;
    
    CGFloat offsetMax = self.smallScrollView.contentSize.width - self.smallScrollView.frame.size.width;
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax){
        offsetx = offsetMax;
    }
    
    CGPoint offset = CGPointMake(offsetx, self.smallScrollView.contentOffset.y);
    [self.smallScrollView setContentOffset:offset animated:YES];
    // 添加控制器
    UITableViewController *newsVc = self.childViewControllers[index];
    
    [self.smallScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            SXTitleLabel *temlabel = self.smallScrollView.subviews[idx];
            temlabel.scale = 0.0;
        }
    }];
    
    [self setScrollToTopWithTableViewIndex:index];
    
    if (newsVc.view.superview) return;
    
    newsVc.view.frame = scrollView.bounds;
    [self.bigScrollView addSubview:newsVc.view];
}

/** 滚动结束（手势导致） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    SXTitleLabel *labelLeft = self.smallScrollView.subviews[leftIndex];
    labelLeft.scale = scaleLeft;
    // 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
    if (rightIndex < self.smallScrollView.subviews.count) {
        SXTitleLabel *labelRight = self.smallScrollView.subviews[rightIndex];
        labelRight.scale = scaleRight;
    }
}

- (UIView *)weatherPage {
    if (!_weatherPage) {
        _weatherPage = [[Lothar shared] Weather_aViewWithCallback:^{
            [self rightItemClick];
        }];
    }
    return _weatherPage;
}

- (void)addWeather{
    self.weatherPage.alpha = 0.9;
    UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
    [win addSubview:self.weatherPage];
    
    UIImageView *tran = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"224"]];
    self.tran = tran;
    tran.width = 7;
    tran.height = 7;
    tran.y = 57;
    tran.x = [UIScreen mainScreen].bounds.size.width - 33;
    [win addSubview:tran];
    
    self.weatherPage.frame = [UIScreen mainScreen].bounds;
    self.weatherPage.y = 64;
    self.weatherPage.height -= 64;
    self.weatherPage.hidden = YES;
    self.tran.hidden = YES;
}

- (void)rightItemClick {
    
    if (self.isWeatherShow) {
        self.weatherPage.hidden = YES;
        self.tran.hidden = YES;
        [UIView animateWithDuration:0.1 animations:^{
            self.rightItem.transform = CGAffineTransformRotate(self.rightItem.transform, M_1_PI * 5);
            
        } completion:^(BOOL finished) {
            [self.rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
        }];
    }else{
        
        [self.rightItem setImage:[UIImage imageNamed:@"223"] forState:UIControlStateNormal];
        self.weatherPage.hidden = NO;
        self.tran.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SXWeatherPageAddAnimate object:nil];
        [UIView animateWithDuration:0.2 animations:^{
            self.rightItem.transform = CGAffineTransformRotate(self.rightItem.transform, -M_1_PI * 6);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.rightItem.transform = CGAffineTransformRotate(self.rightItem.transform, M_1_PI );
            }];
        }];
    }
    self.weatherShow = !self.isWeatherShow;
}

- (IBAction)leftClick:(id)sender {
    UIViewController *vc = [[Lothar shared] Search_aViewControllerWithKeyword:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
