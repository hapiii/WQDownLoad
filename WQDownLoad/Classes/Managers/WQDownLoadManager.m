//
//  WQDownLoadManager.m
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadManager.h"

static NSInteger maxDownLoadNum = 3;

@interface WQDownLoadManager ()<WQURLSessionDownloadTaskDelegate>

@property (nonatomic, strong) NSMutableArray <WQDownLoadSessionEngine *> *allEngines;
@property (nonatomic, strong) NSMutableSet <WQDownLoadSessionEngine *> *currectEngines;

@property (nonatomic, strong) NSMutableDictionary <NSString *, WQDownLoadSessionEngine *> *currectEnginesHash;
@property (nonatomic, strong) NSMutableDictionary <NSString *, WQDownLoadSessionEngine *> *allEngineHash;

@property (nonatomic, strong) NSMutableArray *listeners;
@property (nonatomic, strong) AFNetworkReachabilityManager *netMonitor;

@end

@implementation WQDownLoadManager

static WQDownLoadManager *manager;

+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WQDownLoadManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        
        _allEngines = [[NSMutableArray alloc] init];
        _currectEngines = [[NSMutableSet alloc] initWithCapacity:3];
        
        _currectEnginesHash = [[NSMutableDictionary alloc] init];
        _allEngineHash = [[NSMutableDictionary alloc] init];
        
        _listeners = [[NSMutableArray alloc] init];
        _canUseWWAN = NO;
        //_enableAutoStartDownlaod = YES;
        _netMonitor = [AFNetworkReachabilityManager sharedManager];
        [_netMonitor startMonitoring];
        
        __weak typeof (self) wself = self;
        [_netMonitor setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            __strong typeof (wself) self = wself;
            [self netStateChange:status];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminateNotification:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark -  applife
///网络状态发生变化
- (void)netStateChange:(AFNetworkReachabilityStatus)status {
    if (status != AFNetworkReachabilityStatusReachableViaWiFi && _canUseWWAN == NO ) {
        [self pauseAllDownload];
    }
}

///启动app
- (void)applicationDidFinishLaunching {
    /*延迟3秒的原因:
    app启动时task请求不成功,多次循环 创建task->请求->didCompleteWithError 直到didReceiveData成功
    造成的后果是同一个任务创建了多个task,后期暂停某个任务时,其他task仍会走didReceiveData ,造成任务无法暂停
    */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray <WQDownLoadModel *>*models =  [[WQDownLoadModelDBManager shareMnager] downLoadFailedModels];
        for (WQDownLoadModel *video in models) {
            [self createEngineWithVideoModel:video];
        }
    });
    
}

///将要回到前台
- (void)applicationWillEnterForeground:(NSNotification *)note{
    
}
///进入后台
- (void)applicationDidEnterBackground:(NSNotification *)note{
    
}

///将要被杀掉
- (void)applicationWillTerminateNotification:(NSNotification *)note{
    for (WQDownLoadSessionEngine *engine in self.currectEngines) {
        [engine suspendDownLoad];
    }
}

#pragma mark -  addDownloadTask
- (void)addDownloadTaskWithTasks:(NSArray<WQDownLoadModel *> *)videos errorHandle:(void(^)(BOOL success,  NSString *errorMsg))errorHandle {
    
    for (WQDownLoadModel *video in videos) {
        [self addDownloadTaskWithTask:video errorHandle:^(BOOL success, NSString * _Nonnull errorMsg) {
            
        }];
        for (id listenerObj in self.listeners) {
            if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidAddTasks:)]) {
                [listenerObj downloadManagerDidAddTasks:videos];
            }
        }
    }
}

- (void)addDownloadTaskWithTask:(WQDownLoadModel *)videoInfo errorHandle:(void(^)(BOOL success,  NSString *errorMsg))errorHandle {
    
    if (!videoInfo) {
        errorHandle(NO,@"未找到下载信息");
        return;
    }
    
    if ([[WQDownLoadModelDBManager shareMnager] downLoadModelWithKey:videoInfo.engineKey]) {
        errorHandle(NO,@"已存在该视频的下载任务!");
        return;
    }
    
    videoInfo.download_state = WQDownLoadVideoStatePrepare;
    __weak typeof (self) wself = self;
    
    if (videoInfo.download_url && videoInfo.download_url.length > 0) {
        [self insertVideoInfo:videoInfo errorHandle:errorHandle];
        
    } else {
        [self loadDownLoadUrl:videoInfo.video_id successHaldle:^(NSString *downloadUrl) {
            videoInfo.download_url = downloadUrl;
            __strong typeof (wself) self = wself;
            [self insertVideoInfo:videoInfo errorHandle:errorHandle];
            
        } errorHandle:^(NSString *errorMsg) {
            errorHandle(NO,errorMsg);
        }];
    }
    
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidAddTask:)]) {
            [listenerObj downloadManagerDidAddTask:videoInfo];
        }
    }
}

- (void)insertVideoInfo:(WQDownLoadModel *)videoInfo errorHandle:(void(^)(BOOL success,  NSString *errorMsg))errorHandle {
    if(![[WQDownLoadModelDBManager shareMnager] insertVideo:videoInfo]) {
        errorHandle(NO,@"下载数据初始化失败!");
        return;
    } else {
        videoInfo.download_state = WQDownLoadVideoStateReadying;
        [self createEngineWithVideoModel:videoInfo];
        errorHandle(YES,@"加入下载成功!");
    }
}

///请求下载地址 如果不需要请求则不需要
- (void)loadDownLoadUrl:(NSString *)videoID successHaldle:(void(^)(NSString *downloadUrl))successHandle errorHandle:(void(^)(NSString *errorMsg))errorHandle{
    
    
}

///创建下载Engine
- (WQDownLoadSessionEngine *)createEngineWithVideoModel:(WQDownLoadModel *)videoInfo {
    NSLog(@"download_queue_创建engine");
    WQDownLoadSessionEngine *engine;
    if ([self.allEngineHash objectForKey:videoInfo.engineKey]) {
        engine = [self.allEngineHash objectForKey:videoInfo.engineKey];
    }else {
        engine =  [[WQDownLoadSessionManager shareManager] createEngineWithDownLoadModel:videoInfo];
        engine.taskDelegate = self;
        [self allEngineOperation:engine isAdd:YES];
    }
    
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidAddTask:)]) {
            [listenerObj downloadManagerDidAddTask:videoInfo];
        }
    }
    [self refreshDownLoadTask:NO];
    return engine;
}

#pragma mark -  删除
- (void)removeDownloadTasks:(NSArray<WQDownLoadModel *> *)videos {
    for (WQDownLoadModel *video in videos) {
        [self removeDownloadTask:video];
    }
    
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidRemoveArray:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listenerObj downloadManagerDidRemoveArray:videos];
            });
        }
    }
}

- (void)removeDownloadTask:(WQDownLoadModel *)video {
    [[WQDownLoadModelDBManager shareMnager] deleteVideo:video];
    WQDownLoadSessionEngine *engine = [self.allEngineHash objectForKey:video.engineKey];
    if (engine) {
        [engine cancelDownLoad];
        [self allEngineOperation:engine isAdd:NO];
        [self currectEngineOperation:engine isAdd:NO];
    }
    [self refreshDownLoadTask:NO];
}

#pragma mark - 暂停
- (void)pauseAllDownload {
    
    for (WQDownLoadSessionEngine *engine in self.currectEngines) {
        if (engine.task.state == NSURLSessionTaskStateRunning) {
            [engine suspendDownLoad];
        }
    }
    
    [self.currectEngines removeAllObjects];
    [self.currectEnginesHash removeAllObjects];
    
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidPauseAll:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listenerObj downloadManagerDidPauseAll:self.allEngines];
            });
        }
    }
}

- (void)pauseDownloadTask:(WQDownLoadModel *)downloadTaskModel {
    //allEnginesHash
    WQDownLoadSessionEngine *engine = [self.allEngineHash objectForKey:downloadTaskModel.engineKey];
    if (engine) {
        [engine suspendDownLoad];
        [self currectEngineOperation:engine isAdd:NO];
        [self refreshDownLoadTask:NO];
    }
}


#pragma mark -  开始下载
- (void)startAllDownload {
    [self refreshDownLoadTask:YES];
}

///开始下载
- (void)startDownloadTask:(WQDownLoadModel *)downloadTaskModel {
    WQDownLoadSessionEngine *engine = [self.allEngineHash objectForKey:downloadTaskModel.engineKey];
    if (engine) {
        engine.video.download_state = WQDownLoadVideoStateReadying;
        //[WQDownLoadModelDBManager updateVideo:engine.video];
        [self refreshDownLoadTask:NO];
    }
}

#pragma mark -  任务刷新
- (void)refreshDownLoadTask:(BOOL)loadSuspend{
    
    for (WQDownLoadSessionEngine *engine in self.allEngines) {//等待
        if (self.currectEngines.count < maxDownLoadNum) {
            if (engine.video.download_state == WQDownLoadVideoStateReadying) {
                NSLog(@"download_queue_插入ReadyEngines 目前个数->%lu",(unsigned long)self.currectEngines.count);
                [self currectEngineOperation:engine isAdd:YES];
            }
        }else {
            NSLog(@"download_queue_已超过最大下载量 结束循环");
            break;
        }
    }
    if (loadSuspend) {
        //WQTODO
        for (WQDownLoadSessionEngine *engine in self.allEngines) {//错误
            if (self.currectEngines.count < maxDownLoadNum) {
                if (engine.video.download_state == WQDownLoadVideoStateError) {
                    NSLog(@"download_queue_插入ErrorEngines 目前个数->%lu",(unsigned long)self.currectEngines.count);
                    
                    [self currectEngineOperation:engine isAdd:YES];
                }
            } else {
                NSLog(@"download_queue_已超过最大下载量 结束循环");
                break;
            }
        }
        
        
        for (WQDownLoadSessionEngine *engine in self.allEngines) {//暂停
            if (self.currectEngines.count < maxDownLoadNum) {
                if (engine.video.download_state == WQDownLoadVideoStateSuspended) {
                    NSLog(@"download_queue_插入SuspendedEngines 目前个数->%lu",(unsigned long)self.currectEngines.count);
                    
                    [self currectEngineOperation:engine isAdd:YES];
                }
            } else {
                NSLog(@"download_queue_已超过最大下载量 结束循环");
                break;
            }
        }
    }
    
}

#pragma mark -  listener
- (void)addListener:(id<WQDownLoadManagerDelegate>)listener {
    if(![self.listeners containsObject:listener]){
        [self.listeners addObject:listener];
    }
}

- (void)removeListener:(id<WQDownLoadManagerDelegate>)listener {
    if ([self.listeners containsObject:listener]) {
        [self.listeners removeObject:listener];
    }
}

- (void)removeAllListeners
{
    [self.listeners removeAllObjects];
}

#pragma mark -  回调
///下载进度
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine didReceiveBytes:(WQDownLoadModel *)downloadTaskModel {
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidReceiveBytes:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listenerObj downloadManagerDidReceiveBytes:downloadTaskModel];
            });
        }
    }
}

///下载完成
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine didFinishDownload:(WQDownLoadModel *)downloadTaskModel {
    
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidFinish:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listenerObj downloadManagerDidFinish:downloadTaskModel];
            });
        }
    }
    
    [self showNotificationWithMessage:downloadTaskModel];
    [self currectEngineOperation:engine isAdd:NO];
    [self allEngineOperation:engine isAdd:NO];
    [self refreshDownLoadTask:NO];
    
}

///开始下载
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine willStartDownload:(WQDownLoadModel *)downloadTaskModel {
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidStart:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listenerObj downloadManagerDidStart:downloadTaskModel];
            });
        }
    }
}

///失败
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine handleEngineErrorWithDownloadModel:(WQDownLoadModel *)downloadTaskModel downloadError:(NSError *)error {
    
    
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidError:Error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listenerObj downloadManagerDidError:downloadTaskModel Error:error];
            });
            
        }
    }
    [self currectEngineOperation:engine isAdd:NO];
    [self refreshDownLoadTask:NO];
}

///暂停
- (void)downloadEngine:(WQDownLoadSessionEngine *)engine suspendedDownload:(WQDownLoadModel *)downloadTaskModel {
    for (id listenerObj in self.listeners) {
        if (listenerObj && [listenerObj respondsToSelector:@selector(downloadManagerDidPause:)]) {
            [listenerObj downloadManagerDidPause:downloadTaskModel];
        }
    }
}

///本地推送
- (void)showNotificationWithMessage:(WQDownLoadModel *)video {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.alertBody = [NSString stringWithFormat:@"课程%@ 已下载完成!",video.video_title];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark -  engine 管理
- (void)currectEngineOperation:(WQDownLoadSessionEngine *)engine isAdd:(BOOL)add {
    @synchronized(self){
        if (add) {
            if (![self.currectEngines containsObject:engine]) {
                [self.currectEngines addObject:engine];
            }
            if (![self.currectEnginesHash objectForKey:engine.video.engineKey]) {
                [self.currectEnginesHash setValue:engine forKey:engine.video.engineKey];
            }
            [engine startDownLoad];
            NSLog(@"download_queue_插入成功%@",engine);
        }else {
            if ([self.currectEngines containsObject:engine]) {
                [self.currectEngines removeObject:engine];
            }
            
            if ([self.currectEnginesHash objectForKey:engine.video.engineKey]) {
                [self.currectEnginesHash removeObjectForKey:engine.video.engineKey];
            }
            NSLog(@"download_queue_删除成功%@",engine);
        }
        
    }
}

- (void)allEngineOperation:(WQDownLoadSessionEngine *)engine isAdd:(BOOL)add {
    
    @synchronized(self){
        if (add) {
            if (![self.allEngines containsObject:engine]) {
                [self.allEngines addObject:engine];
            }
            if (![self.allEngineHash objectForKey:engine.video.engineKey]) {
                [self.allEngineHash setValue:engine forKey:engine.video.engineKey];
            }
        }else {
            if ([self.allEngines containsObject:engine]) {
                [self.allEngines removeObject:engine];
            }
            if ([self.allEngineHash objectForKey:engine.video.engineKey]) {
                [self.allEngineHash removeObjectForKey:engine.video.engineKey];
            }
        }
    }
}

@end
