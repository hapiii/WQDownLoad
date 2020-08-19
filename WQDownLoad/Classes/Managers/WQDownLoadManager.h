//
//  WQDownLoadManager.h
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WQDownLoadModel.h"
#import "WQDownLoadManagerDelegate.h"
#import "WQDownLoadSessionEngine.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "WQDownLoadModelDBManager.h"
#import "WQDownLoadSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadManager : NSObject

@property (nonatomic, strong ,readonly) NSMutableDictionary <NSString *, WQDownLoadSessionEngine *> *allEngineHash;

@property (nonatomic, strong ,readonly) NSMutableArray <WQDownLoadSessionEngine *> *allEngines;
///是否打开后台下载功能,默认YES
@property (nonatomic, assign) BOOL isOpenBackgroundModel;
//能否使用流量
@property (nonatomic, assign) BOOL canUseWWAN;

///单例
+ (WQDownLoadManager *)shareInstance;

- (void)applicationDidFinishLaunching;

///监听
- (void)addListener:(id<WQDownLoadManagerDelegate>)listener;
- (void)removeListener:(id<WQDownLoadManagerDelegate>)listener;
- (void)removeAllListeners;

///添加下载任务
- (void)addDownloadTaskWithTask:(WQDownLoadModel *)videoInfo errorHandle:(nullable void(^)(BOOL success, NSString *errorMsg))errorHandle;
///添加多个下载任务
- (void)addDownloadTaskWithTasks:(NSArray<WQDownLoadModel *> *)videos errorHandle:(void(^)(BOOL success,  NSString *errorMsg))errorHandle;
///删除下载任务
- (void)removeDownloadTask:(WQDownLoadModel *)video;
///删除多个下载任务
- (void)removeDownloadTasks:(NSArray <WQDownLoadModel *>*)videos;
///暂停所有下载并修改所有状态为暂停(仅正在缓存页－全部暂停按钮点击时调用)
- (void)pauseAllDownload;
///开始下载所有视频,所有状态的视频变为等待(仅正在缓存页－全部开始按钮点击时调用)
- (void)startAllDownload;
///暂停下载任务
- (void)pauseDownloadTask:(WQDownLoadModel *)downloadTaskModel;
///开始下载任务
- (void)startDownloadTask:(WQDownLoadModel *)downloadTaskModel;

@end

NS_ASSUME_NONNULL_END
