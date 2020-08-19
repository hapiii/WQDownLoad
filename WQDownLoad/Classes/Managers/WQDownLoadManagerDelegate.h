//
//  WQDownLoadManagerDelegate.h
//  MKEducation
//
//  Created by hapii on 2020/6/23.
//  Copyright © 2020 Muke. All rights reserved.
//

@class WQDownLoadModel;

@protocol WQDownLoadManagerDelegate <NSObject>

@optional

/**
 * @brief 下载过程中触发的失败回调
 * @param downloadTaskModel 任务downloadTaskModel
 * @param error 错误
 */
- (void)downloadManagerDidError:(WQDownLoadModel *)downloadTaskModel Error:(NSError *)error;

/**
 * @brief 下载任务开始的回调
 * @param downloadTaskModel 任务model
 */
- (void)downloadManagerDidStart:(WQDownLoadModel *)downloadTaskModel;

/**
 * @brief 下载进度的回调，UI层用该回调来刷新进度条，进度值需要通过DownloadVideo对象来计算
 * @param downloadTaskModel   任务model
 */
- (void)downloadManagerDidReceiveBytes:(WQDownLoadModel *)downloadTaskModel;

/**
 * @brief 整个任务下载完成的回调
 * @param downloadTaskModel   任务model
 */
- (void)downloadManagerDidFinish:(WQDownLoadModel *)downloadTaskModel;

/**
 * @brief 单个任务暂停的回调
 * @param downloadTaskModel 任务model
 */
- (void)downloadManagerDidPause:(WQDownLoadModel *)downloadTaskModel;

/**
 * @brief 单个任务添加到任务池中的回调
 * @param downloadTaskModel 任务model
 */
- (void)downloadManagerDidAddTask:(WQDownLoadModel *)downloadTaskModel;

/**
 * @brief 任务集合添加的任务池中的回调 注意:由于下载地址请求,数据库未插入下载信息
 * @param array 任务集合
 */
- (void)downloadManagerDidAddTasks:(NSArray <WQDownLoadModel *>*)array;

/**
 * @brief 下载任务集合已经移除的回调
 * @param deleteArray 移除的下载任务DownloadTaskModel集合
 */
- (void)downloadManagerDidRemoveArray:(NSArray *)deleteArray;

/**
 * @brief  暂停全部任务
 * @param array 任务数组
 */
- (void)downloadManagerDidPauseAll:(NSArray *)array;



@end
