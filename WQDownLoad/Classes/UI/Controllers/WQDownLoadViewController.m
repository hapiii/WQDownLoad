//
//  WQDownLoadViewController.m
//  ebooksystem
//
//  Created by hapii on 2020/6/28.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadViewController.h"
#import "WQDownLoadDownController.h"
#import "WQDownLoadDownloadController.h"
#import <YYKit/YYKit.h>
#import "WQDownLoadModel.h"

@interface WQDownLoadViewController ()

@property (nonatomic, strong) WQDownLoadDownController *downVC;

@property (nonatomic, strong) WQDownLoadDownloadController *ingVC;

@property (nonatomic, strong) UIViewController *currectVC;

@end

@implementation WQDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
}

- (void)configUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"已下载",@"下载中",nil];
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    control.frame = CGRectMake(80, 5 , kScreenWidth - 180, 34);
    control.selectedSegmentIndex = 0;
    control.tintColor = [UIColor colorWithHexString:kDownLoadColor];
    [control addTarget:self action:@selector(changeControl:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = control;
    
    _ingVC = [[WQDownLoadDownloadController alloc] init];
    _downVC = [[WQDownLoadDownController alloc] init];
    _ingVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _downVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:_downVC];
    [self addChildViewController:_ingVC];
    [self.view addSubview:_downVC.view];
    _currectVC = _downVC;
}

- (void)changeControl:(UISegmentedControl *)control {
    NSInteger index = control.selectedSegmentIndex;
    UIViewController *oldVC = _currectVC;
    switch (index) {
        case 0:
        {
            __weak typeof (self) wself = self;
            [self transitionFromViewController:_currectVC toViewController:_downVC duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                
            } completion:^(BOOL finished) {
                 __strong typeof (wself) self = wself;
                self.currectVC = finished ? self.downVC : oldVC;
            }];
        }
            break;
        case 1:
        {
            __weak typeof (self) wself = self;
            [self transitionFromViewController:_currectVC toViewController:self.ingVC duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                
            } completion:^(BOOL finished) {
                __strong typeof (wself) self = wself;
                self.currectVC = finished ? self.ingVC : oldVC;
            }];
        }
            break;
            
    }
}




@end
