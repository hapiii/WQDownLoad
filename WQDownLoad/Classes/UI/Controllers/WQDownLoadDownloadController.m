//
//  WQDownLoadDownloadController.m
//  MKEducation
//
//  Created by hapii on 2020/8/14.
//  Copyright © 2020 Muke. All rights reserved.
// 正在下载

#import "WQDownLoadDownloadController.h"
#import "WQDownLoadManager.h"
#import "WQDownLoadCell.h"
//#import "MKPlayerController.h"
#import "WQDownLoadCourseController.h"
#import "WQDownLoadCourseCell.h"

@interface WQDownLoadDownloadController ()<WQDownLoadManagerDelegate>

///hash:indexPath
@property (nonatomic, strong) NSMutableDictionary *videohash;
@property (nonatomic, strong) NSMutableArray <WQDownLoadModel *> *datas;

@end

@implementation WQDownLoadDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = NO;
    _videohash = [[NSMutableDictionary alloc] init];
    
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
    
    NSArray <WQDownLoadModel *> *models = [[WQDownLoadModelDBManager shareMnager] downLoadFailedModels];
    self.datas = models.mutableCopy;
    [_videohash removeAllObjects];
    for (int i = 0; i < _datas.count; i++) {
        WQDownLoadModel *video = _datas[i];
        [_videohash setObject:[NSIndexPath indexPathForRow:i inSection:0] forKey:video.engineKey];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WQDownLoadCell *cell = [WQDownLoadCell cellWithTableView:tableView cellForRowAtIndexPath:indexPath];
    cell.video = _datas[indexPath.row];
    
    __weak typeof (self) wself = self;
    
    cell.downLoadCellActionHandle = ^(WQDownLoadModel * _Nonnull model) {
        __strong typeof (wself) self = wself;
        NSDictionary *allEngineHash = [WQDownLoadManager shareInstance].allEngineHash;
        WQDownLoadSessionEngine *engine =  allEngineHash[model.engineKey];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
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
            [self reloadData];
        }
    }
}

//downLoadDelegate
- (void)downloadManagerDidPause:(WQDownLoadModel *)downloadTaskModel {
    [self reloadCellWithVideo:downloadTaskModel];
}

- (void)downloadManagerDidStart:(WQDownLoadModel *)downloadTaskModel {
    [self reloadCellWithVideo:downloadTaskModel];
}

- (void)downloadManagerDidReceiveBytes:(WQDownLoadModel *)downloadTaskModel {
    [self reloadCellWithVideo:downloadTaskModel];
}

- (void)downloadManagerDidFinish:(WQDownLoadModel *)downloadTaskModel {
    [self reloadCellWithVideo:downloadTaskModel];
    [self reloadData];
}

- (void)downloadManagerDidError:(WQDownLoadModel *)downloadTaskModel Error:(NSError *)error {
    [self reloadCellWithVideo:downloadTaskModel];
}

- (void)reloadCellWithVideo:(WQDownLoadModel *)video {
    WQDownLoadCell *cell = [self.tableView cellForRowAtIndexPath:self.videohash[video.engineKey]];
    cell.video = video;
}

@end
