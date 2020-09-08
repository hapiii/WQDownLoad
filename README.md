# WQDownLoad

[![CI Status](https://img.shields.io/travis/hapiii/WQDownLoad.svg?style=flat)](https://travis-ci.org/hapiii/WQDownLoad)
[![Version](https://img.shields.io/cocoapods/v/WQDownLoad.svg?style=flat)](https://cocoapods.org/pods/WQDownLoad)
[![License](https://img.shields.io/cocoapods/l/WQDownLoad.svg?style=flat)](https://cocoapods.org/pods/WQDownLoad)
[![Platform](https://img.shields.io/cocoapods/p/WQDownLoad.svg?style=flat)](https://cocoapods.org/pods/WQDownLoad)
[![Support](https://img.shields.io/badge/Support-iOS%208%2B-blue.svg?style=flat)](https://www.apple.com/nl/ios/)

## Effect
![效果图](https://github.com/hapiii/WQDownLoad/blob/master/imgs/demo.gif)

## Usage
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

## Architecture

* 视频配套信息存储基于FMDB, 
* 下载实现基于NSURLSessionDataTask
* audio airplay and picture in picture后台播放无声音频

#### WQDownLoadModel

为FMDB实体模型类,包含数据库要存储的数据以及部分getter属性,video_parameter参数用于扩展其他参数
#### WQDownLoadAudioPlayer

后台播放无声音频的管理者

* 内部观察了DidEnterBackground和WillEnterForeground来控制播放暂停

#### WQDownLoadModelDBManager 

* 数据库管理者
* 封装了一些model更新
* 下载数据获取

#### WQDownLoadSessionEngine

下载引擎,核心类

* video下载视频的model信息 
* dataTask(task)下载任务dataTask(downloadTask)
* 外部公开 开始,暂停,取消 三个操作.以及供WQDownLoadSessionManager调用的下载进度和状态
* 内部操作数据库的下载状态,以及将下载信息回调到WQDownLoadManager

#### WQDownLoadSessionManager

NSURLSession管理者

* 创建task
* 将SessionDelegate 分发给各个单独的Engine


#### WQDownLoadManager
任务调度,进度回调,核心类

* 添加listener并将进度回调给listener
* 任务管理(添加,删除,暂停)的单个操作或多个操作
* applicationDidFinishLaunching 进入app下载未完成的任务


## TODO

* downloadTask下载时数据库操作不太理想,做了一半换成了DataTask
* didCompleteWithError之后新建一个task可能会导致无法暂停
* 目前项目没有直接提供下载Url,但是下载时请求的Url是有时效性的,url过期为处理(与后台统一code重新请求)

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
