//
//  WQDownLoadSessionEngineDelegate.h
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//
#import <Foundation/Foundation.h>

@class WQDownLoadSessionEngine;
@class WQDownLoadModel;

@protocol WQURLSessionDownloadTaskDelegate <NSObject>

///视频开始下载
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine willStartDownload:(WQDownLoadModel *)downloadTaskModel;

///错误处理(引擎下载发生错误的回调，有些错误引擎自己就处理了，需要抛给manager的才需要manager处理)
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine handleEngineErrorWithDownloadModel:(WQDownLoadModel *)downloadTaskModel downloadError:(NSError *)error;

///进度回调
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine didReceiveBytes:(WQDownLoadModel *)downloadTaskModel;

///下载任务完成
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine didFinishDownload:(WQDownLoadModel *)downloadTaskModel;

///下载任务暂停
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine suspendedDownload:(WQDownLoadModel *)downloadTaskModel;

@end
