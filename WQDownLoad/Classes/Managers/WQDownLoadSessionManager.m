//
//  WQDownLoadSessionManager.m
//  ebooksystem
//
//  Created by hapii on 2020/6/24.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadSessionManager.h"
#import "WQDownLoadSessionEngine.h"
#import "WQDownLoadModelDBManager.h"
#import "WQDownLoadManager.h"

@interface WQDownLoadSessionManager ()<NSURLSessionDownloadDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSData *> *resumeDataHash;
@property (nonatomic, assign) BOOL isDataTask;
@end

@implementation WQDownLoadSessionManager

static WQDownLoadSessionManager *manager;

+ (void)load {
    [super load];
    [WQDownLoadSessionManager shareManager];
}

+ (WQDownLoadSessionManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WQDownLoadSessionManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kVideoDownLoadIdentifier];
        configuration.allowsCellularAccess = YES;
        configuration.sessionSendsLaunchEvents = YES;
        configuration.HTTPMaximumConnectionsPerHost = 100;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _resumeDataHash = [[NSMutableDictionary alloc] init];
        _isDataTask = YES;
    }
    return self;
}

///新加任务
- (WQDownLoadSessionEngine *)createEngineWithDownLoadModel:(WQDownLoadModel *)video {
    
    WQDownLoadSessionEngine *engine = [[WQDownLoadSessionEngine alloc] init];
    engine.maxRetryCount = 0;
    
    if (_isDataTask) {
        NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:video.download_url]];
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", video.completed_size];
        [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
        engine.dataTask = [self.session dataTaskWithRequest:mutableURLRequest];
        engine.dataTask.taskDescription = video.engineKey;
    }else {
        NSData *resumeData = [_resumeDataHash objectForKey:video.engineKey];
        if (resumeData) {
            
            engine.task = [self.session downloadTaskWithResumeData:resumeData];
            engine.video.resume_data = [_resumeDataHash objectForKey:video.engineKey];
        }else {
            NSURL *URL = [NSURL URLWithString:video.download_url];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            engine.task = [self.session downloadTaskWithRequest:request];
        }
        engine.task.taskDescription = video.engineKey;
    }
    video.download_state = WQDownLoadVideoStateReadying;
    engine.video = video;
    return engine;
}

#pragma mark - <NSURLSessionDataDelegate> 实现方法
/**
 * 接收到响应的时候：创建一个空的沙盒文件
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSString *key = dataTask.taskDescription;
    WQDownLoadSessionEngine *engine = [[WQDownLoadManager shareInstance].allEngineHash objectForKey:key];
    if (engine) {
        [engine engineTask:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
}

/**
 * 接收到具体数据：把数据写入沙盒文件中
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSString *key = dataTask.taskDescription;
    WQDownLoadSessionEngine *engine = [[WQDownLoadManager shareInstance].allEngineHash objectForKey:key];
       if (engine) {
           [engine engineTask:session dataTask:dataTask didReceiveData:data];
       }
}

#pragma mark -  downloadDelegate
///下载中
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSString *key = downloadTask.taskDescription;
    WQDownLoadSessionEngine *engine = [[WQDownLoadManager shareInstance].allEngineHash objectForKey:key];
    if (engine) {
        [engine engineTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

///下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *key = downloadTask.taskDescription;
    WQDownLoadSessionEngine *engine = [[WQDownLoadManager shareInstance].allEngineHash objectForKey:key];
    if (engine) {
        [engine engineTask:downloadTask didFinishDownloadingToURL:location];
    }
}

///4
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"后台下载完成");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    NSString *key = task.taskDescription;
    NSData *data = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
    if ( [task isKindOfClass:NSURLSessionDownloadTask.class] && data) {
        [_resumeDataHash setValue:data forKey:key];
    }
    WQDownLoadSessionEngine *engine = [[WQDownLoadManager shareInstance].allEngineHash objectForKey:key];
    if (engine) {
        if ( [task isKindOfClass:NSURLSessionDownloadTask.class] && data){
            [engine engineTask:task didCompleteWithError:error];
        } else {
            if (error) {
                NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:engine.video.download_url]];
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", engine.video.completed_size];
                [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
                engine.dataTask = [self.session dataTaskWithRequest:mutableURLRequest];
                engine.dataTask.taskDescription = engine.video.engineKey;
            }
            [engine engineTask:session task:task didCompleteWithError:error];
        }
    }

}


@end
