//
//  WQViewController.m
//  WQDownLoad
//
//  Created by hapiii on 08/19/2020.
//  Copyright (c) 2020 hapiii. All rights reserved.
//

#import "WQViewController.h"
#import "WQVideoModel.h"
#import <NSObject+YYModel.h>
#import <WQDownLoadManager.h>
#import <WQDownLoadViewController.h>
#import <WQDownLoadChooseController.h>

@interface WQViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tb;

@property (nonatomic, copy) NSArray <WQVideoModel *> *videos;

@end

@implementation WQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self.view addSubview:self.tb];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width/2 , 50)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"下载中心" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(gotoDowonload) forControlEvents:UIControlEventTouchUpInside];
	
    UIButton *allbtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height - 50, self.view.frame.size.width/2 , 50)];
    allbtn.backgroundColor = [UIColor purpleColor];
    [allbtn setTitle:@"选择下载" forState:UIControlStateNormal];
    [self.view addSubview:allbtn];
    [allbtn addTarget:self action:@selector(allDownLoad) forControlEvents:UIControlEventTouchUpInside];
}

- (void)gotoDowonload {
     WQDownLoadViewController *vc = [[WQDownLoadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)allDownLoad {
    WQDownLoadChooseController *choose = [[WQDownLoadChooseController alloc] init];
    NSMutableArray *mArr = @[].mutableCopy;
    for (WQVideoModel *info in _videos) {
        WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
        model.video_title = info.title;
        model.video_id = info.video_id;
        //    model.chapter_id = self.courseInfo.lessonID;
        //    model.course_id = self.courseInfo.courseId;
        //    model.user_id = @"userid12223";
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[info modelToJSONData]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        model.video_parameter = dic;
        model.create_time = [NSDate date];
        model.cover_img_url = [info.img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        model.course_name = info.country;
        ///这个根据实际情况调整
        model.download_url = [info.video stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [mArr addObject:model];
    }
    choose.datas = mArr.copy;
    choose.title = @"选择视频";
    [self.navigationController pushViewController:choose animated:YES];
}

- (void)loadData {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"\n%@", [error localizedDescription]);
    _videos = [NSArray modelArrayWithClass:WQVideoModel.class json:result[@"result"]];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wqdownload"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wqdownload"];
    }
    cell.textLabel.text = _videos[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WQVideoModel *info = _videos[indexPath.row];
    WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
    model.video_title = info.title;
    model.video_id = info.video_id;
//    model.chapter_id = self.courseInfo.lessonID;
//    model.course_id = self.courseInfo.courseId;
//    model.user_id = @"userid12223";
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[info modelToJSONData]
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    model.video_parameter = dic;
    model.create_time = [NSDate date];
    model.cover_img_url = [info.img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    model.course_name = info.country;
    ///这个根据实际情况调整
    model.download_url = [info.video stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[WQDownLoadManager shareInstance] addDownloadTaskWithTask:model errorHandle:^(BOOL success, NSString * _Nonnull errorMsg) {
       if (success) {
           NSLog(@"加入下载成功!");
          }else {
              NSLog(@"%@",errorMsg);
          }
    }];
}

- (UITableView *)tb {
    if (!_tb) {
        _tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
        _tb.delegate = self;
        _tb.dataSource = self;
    }
    return _tb;
}


@end
