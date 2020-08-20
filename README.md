# WQDownLoad

[![CI Status](https://img.shields.io/travis/hapiii/WQDownLoad.svg?style=flat)](https://travis-ci.org/hapiii/WQDownLoad)
[![Version](https://img.shields.io/cocoapods/v/WQDownLoad.svg?style=flat)](https://cocoapods.org/pods/WQDownLoad)
[![License](https://img.shields.io/cocoapods/l/WQDownLoad.svg?style=flat)](https://cocoapods.org/pods/WQDownLoad)
[![Platform](https://img.shields.io/cocoapods/p/WQDownLoad.svg?style=flat)](https://cocoapods.org/pods/WQDownLoad)

## Desc
1. AppDelegate 里 在didFinishLaunchingWithOptions里实现:

```objc
[[WQDownLoadManager shareInstance] applicationDidFinishLaunching];
```

2. 下载单个信息:

```objc
WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
model.video_title = self.courseInfo.title;
model.video_id = self.courseInfo.video_id;
model.chapter_id = self.courseInfo.lessonID;
model.course_id = self.courseInfo.courseId;
model.user_id = @"userid12223";
model.video_parameter = @{};
model.create_time = [NSDate date];
model.cover_img_url = self.courseInfo.courseImgUrl;
model.course_name = self.courseInfo.courseTitle;
[[WQDownLoadManager shareInstance] addDownloadTaskWithTask:model errorHandle:^(BOOL success, NSString * _Nonnull errorMsg) {
    if (success) {
        [MBProgressHUD showSuccess:@"加入下载成功!" toView:self.viewController.view];
    }else {
        [MBProgressHUD showError:errorMsg toView:self.viewController.view];
    }
}];
```

3. 配置多选下载数据

```objc
WQDownLoadChooseController *vc = [[WQDownLoadChooseController alloc] init];
NSString *sectionKey = self.couseInfo.IndexArr[section];
NSArray *arr = self.couseInfo.courses[sectionKey];
NSMutableArray *marr = @[].mutableCopy;
for (NSString *rowkey in arr) {
    WQCourseListInfoModel *lessionInfo = self.couseInfo.courseListPool[rowkey];
    WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
    model.video_title = lessionInfo.title;
    model.video_id = lessionInfo.video_id;
    model.chapter_id = lessionInfo.lessonID;
    model.course_id = self.couseInfo.course_basic_info.global_id;
    model.user_id = @"userid12223";
    model.video_parameter = @{};
    model.create_time = [NSDate date];
    model.cover_img_url = self.couseInfo.course_basic_info.img_src;
    model.course_name = self.couseInfo.course_basic_info.title;
    [marr addObject:model];
}
vc.datas = marr.copy;
vc.title = sectionModel.title;
[self.viewController.navigationController pushViewController:vc animated:YES];
```

4. WQDownLoadManagerDelegate 下载进度及情况回调
添加代理:

```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[WQDownLoadManager shareInstance] addListener:self];
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WQDownLoadManager shareInstance] removeListener:self];
}
```

代理方法:


```objc
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
```

cellHash配置,key为engineKey,value为index,便于reloadCell UI,如果tableView数据刷新,要再次重新配置

```objc
for (int i = 0; i < _datas.count; i++) {
    WQDownLoadModel *video = _datas[i];
    [_videohash setObject:[NSIndexPath indexPathForRow:i inSection:0] forKey:video.engineKey];
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WQDownLoad is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WQDownLoad'
```

## Author

hapiii, 869932084@qq.com

## License

WQDownLoad is available under the MIT license. See the LICENSE file for more info.
