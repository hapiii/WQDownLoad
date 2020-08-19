//
//  WQDownLoadCourseController.m
//  MKEducation
//
//  Created by hapii on 2020/8/10.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadCourseController.h"
#import "WQDownLoadManager.h"
#import "WQDownLoadSuccessCell.h"
#import <YYKit/UIColor+YYAdd.h>

//#import "MKPlayerController.h"

@interface WQDownLoadCourseController ()<WQDownLoadManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *selectAllBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

 
@end

@implementation WQDownLoadCourseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI {
    
    self.title = self.datas.firstObject.course_name;
    CGFloat navHeight =  0;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = window.safeAreaInsets;
        navHeight = safeAreaInsets.bottom > 0 ? self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height : 0;
    }
    CGFloat btnHeight = 60;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navHeight - btnHeight ) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = NO;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    //[self.tableView setEditing:YES animated:YES];
    [self.view addSubview:self.tableView];
    
    self.selectAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - navHeight - btnHeight, self.view.frame.size.width/2, btnHeight)];
    [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_selectAllBtn setTitle:@"取消全选" forState:UIControlStateSelected];
    [_selectAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_selectAllBtn addTarget:self action:@selector(allChooseSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selectAllBtn];
    _selectAllBtn.hidden = YES;
    self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2 , self.view.frame.size.height - navHeight - btnHeight, self.view.frame.size.width/2, btnHeight)];
    [_deleteBtn setBackgroundColor:[UIColor colorWithHexString:kDownLoadColor]];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    _deleteBtn.hidden = YES;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:@"编辑" forState:UIControlStateNormal];
    [btn setTitle:@"取消" forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
}

#pragma mark -  action
- (void)allChooseSelect:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self selectAll];
    }else {
        [self cancelSelectAll];
    }
    
}

- (void)selectAll {
    [self.datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

- (void)cancelSelectAll {
    [self.tableView reloadData];
}

- (void)deleteAction {
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        [[WQDownLoadManager shareInstance] removeDownloadTask:_datas[indexPath.row]];
        [set addIndex:indexPath.row];
    }
    [_datas removeObjectsAtIndexes:set];
    [self.tableView reloadData];
    
}

- (void)editAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    self.selectAllBtn.hidden = !btn.selected;
    self.deleteBtn.hidden = !btn.selected;
    [self.tableView setEditing:btn.selected];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[WQDownLoadManager shareInstance] addListener:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WQDownLoadManager shareInstance] removeListener:self];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WQDownLoadSuccessCell *cell = [WQDownLoadSuccessCell cellWithTableView:tableView cellForRowAtIndexPath:indexPath];
    cell.video = _datas[indexPath.row];
    
    __weak typeof (self) wself = self;
    
    cell.downLoadCellActionHandle = ^(WQDownLoadModel * _Nonnull model) {
        __strong typeof (wself) self = wself;
        WQDownLoadSessionEngine *engine =  [WQDownLoadManager shareInstance].allEngineHash[model.engineKey];
        if (engine) {
            if (engine.video.download_state == WQDownLoadVideoStateDownloading) {//暂停下载
                [[WQDownLoadManager shareInstance] pauseDownloadTask:model];
            }else if (engine.video.download_state == WQDownLoadVideoStateSuspended || engine.video.download_state == WQDownLoadVideoStateReadying || engine.video.download_state == WQDownLoadVideoStateError) {///开始下载
                [[WQDownLoadManager shareInstance] startDownloadTask:model];
            }
        }else {
            
            NSDictionary *hash = @{
                @"url":model.document_local_path,
                @"title":model.video_title
            };
            [self gotoLocalPlay:hash];
            
        }
    };
    return cell;
}

- (void)gotoLocalPlay:(NSDictionary *)playInfo {
//    MKPlayerController *vc = [[MKPlayerController alloc] init];
//    vc.localHash = playInfo;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        
        if (indexPath.row < _datas.count) {
            
            [[WQDownLoadManager shareInstance] removeDownloadTask:_datas[indexPath.row]];
            [_datas removeObject:_datas[indexPath.row]];
            [self.tableView reloadData];
        }
    }
}

//downLoadDelegate

- (void)downloadManagerDidFinish:(WQDownLoadModel *)downloadTaskModel {
    if ([downloadTaskModel.course_id isEqualToString:self.datas.firstObject.course_id]) {
        [_datas addObject:downloadTaskModel];
        [self.tableView reloadData];
    }
   
}

@end

