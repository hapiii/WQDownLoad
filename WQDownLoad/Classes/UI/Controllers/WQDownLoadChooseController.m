//
//  WQDownLoadChooseController.m
//  ebooksystem
//
//  Created by hapii on 2020/8/18.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadChooseController.h"
#import "WQDownLoadChooseCell.h"
#import "WQDownLoadManager.h"
#import <YYKit/UIColor+YYAdd.h>

@interface WQDownLoadChooseController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *dbContainerData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectDatas;
@property (nonatomic, strong) UIButton *downLoadBtn;
@end

@implementation WQDownLoadChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dbContainerData = @{}.mutableCopy;
    [self loadDBData];
    [self configUI];
}

- (void)configUI {
    
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
    [self.tableView setEditing:YES animated:YES];
    [self.view addSubview:self.tableView];
    
    self.downLoadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - navHeight - btnHeight, self.view.frame.size.width, btnHeight)];
    [_downLoadBtn setBackgroundColor:[UIColor colorWithHexString:kDownLoadColor]];
    [_downLoadBtn setTitle:@"开始下载" forState:UIControlStateNormal];
    [_downLoadBtn addTarget:self action:@selector(downLoadClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downLoadBtn];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:@"全选" forState:UIControlStateNormal];
    [btn setTitle:@"取消" forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(allChooseSelect:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)loadDBData {
    NSArray *dbdatas = [[WQDownLoadModelDBManager shareMnager] getDownLoadModelsWithType:WQDownLoadGetDataAll courseID:_datas.firstObject.course_id];
    for (WQDownLoadModel *model in dbdatas) {
        [_dbContainerData setValue:model forKey:model.engineKey];
    }
}

- (void)downLoadClick {
    NSMutableArray *arr = @[].mutableCopy;
    for (NSIndexPath *indexpath in self.tableView.indexPathsForSelectedRows) {
        WQDownLoadModel *model = _datas[indexpath.row];
        [arr addObject:model];
        [_dbContainerData setValue:model forKey:model.engineKey];
    }
    [[WQDownLoadManager shareInstance] addDownloadTaskWithTasks:arr.copy errorHandle:^(BOOL success, NSString * _Nonnull errorMsg) {
        
    }];
    
    [self.tableView reloadData];
}

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
    /** 遍历反选
    [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView deselectRowAtIndexPath:obj animated:NO];
    }];
     */
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WQDownLoadChooseCell *cell = [WQDownLoadChooseCell cellWithTableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *engineKey = _datas[indexPath.row].engineKey;
    if (_dbContainerData[engineKey]) {
        cell.video = _dbContainerData[engineKey];
        cell.userInteractionEnabled = NO;
    }else {
        cell.video = _datas[indexPath.row];
        cell.userInteractionEnabled = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *engineKey = _datas[indexPath.row].engineKey;
    if (!_dbContainerData[engineKey]) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }else {
        return UITableViewCellEditingStyleNone;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
