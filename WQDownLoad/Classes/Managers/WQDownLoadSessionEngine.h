//
//  WQDownLoadSessionEngine.h
//  MKEducation
//
//  Created by hapii on 2020/6/24.
//  Copyright © 2020 Muke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WQURLSessionDownloadTaskDelegate.h"

@class WQDownLoadModel;

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadSessionEngine : NSObject

@property (nonatomic, strong) WQDownLoadModel *video;

@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

///重试次数
@property (nonatomic, assign)  NSInteger maxRetryCount;

@property (nonatomic, weak) id <WQURLSessionDownloadTaskDelegate > taskDelegate;

///开始下载
- (void)startDownLoad;
///暂停下载
- (void)suspendDownLoad;
///取消下载
- (void)cancelDownLoad;

#pragma mark -  NSURLSessionDownloadTask
///下载中
- (void)engineTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
///下载完成
- (void)engineTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
///下载失败
- (void)engineTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
///后台下载任务成功
- (void)engineTaskDidFinishEventsForBackgroundURLSession;


#pragma mark -  NSURLSessionDataTask
- (void)engineTask:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler;

- (void)engineTask:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;

- (void)engineTask:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
