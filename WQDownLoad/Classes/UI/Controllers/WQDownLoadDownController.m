//
//  WQDownLoadDownController.m
//  MKEducation
//
//  Created by hapii on 2020/8/14.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadDownController.h"
#import "WQDownLoadManager.h"
#import "WQDownLoadCell.h"
#import "WQDownLoadCourseController.h"
#import "WQDownLoadCourseCell.h"

@interface WQDownLoadDownController ()<WQDownLoadManagerDelegate>

@property (nonatomic, strong) NSMutableArray <WQDownLoadModel *> *datas;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSMutableArray<WQDownLoadModel *>*>* videoHash;
@property (nonatomic, strong) NSMutableArray <NSString *> *videoArr;
@property (nonatomic, strong) NSMutableArray <NSString *> *imgData;

@end

@implementation WQDownLoadDownController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"已下载";
    self.tableView.separatorStyle = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[WQDownLoadManager shareInstance] addListener:self];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WQDownLoadManager shareInstance] removeListener:self];
}

- (void)reloadData {
    
    NSArray <WQDownLoadModel *> *models = [[WQDownLoadModelDBManager shareMnager] downLoadSuccessModels];
    _videoHash = @{}.mutableCopy;
    _videoArr = @[].mutableCopy;
    _imgData = @[].mutableCopy;
    for (WQDownLoadModel *model in models) {
        if ([_videoHash.allKeys containsObject:model.course_name]) {
            NSMutableArray *arr = [_videoHash valueForKey:model.course_name];
            if (![arr containsObject:model]) {
                [arr addObject:model];
            }
        }else {
            NSMutableArray *arr = @[].mutableCopy;
            [arr addObject:model];
            [_videoHash setValue:arr forKey:model.course_name];
        }
    }
    
    for (NSString *key in _videoHash.allKeys) {
        [_videoArr addObject:key];
        NSMutableArray *arr = _videoHash[key];
        if (arr.count > 0) {
            WQDownLoadModel *model = [arr firstObject];
            [_imgData addObject:model.cover_img_url];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WQDownLoadCourseCell *cell = [WQDownLoadCourseCell cellWithTableView:tableView cellForRowAtIndexPath:indexPath];
    WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
    model.video_title = _videoArr[indexPath.row];
    model.cover_img_url = _imgData[indexPath.row];
    cell.downLoadModel = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _videoArr[indexPath.row];
    WQDownLoadCourseController *vc = [[WQDownLoadCourseController alloc] init];
    vc.datas = _videoHash[key];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)downloadManagerDidFinish:(WQDownLoadModel *)downloadTaskModel {
    [self reloadData];
}

@end
