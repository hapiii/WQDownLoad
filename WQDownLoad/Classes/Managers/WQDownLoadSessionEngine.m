//
//  WQDownLoadSessionEngine.m
//  MKEducation
//
//  Created by hapii on 2020/6/24.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadSessionEngine.h"
#import "WQDownLoadModel.h"
#import "WQDownLoadModelDBManager.h"
#import "WQDownLoadSessionManager.h"

@interface WQDownLoadSessionEngine ()

@property (nonatomic, assign) NSTimeInterval receiveDataTime;
@property (nonatomic, assign) NSTimeInterval recordTime;
@property (nonatomic, assign) int64_t recordSize;

@property (nonatomic, strong) NSOutputStream *stream;

@end

@implementation WQDownLoadSessionEngine


#pragma mark -  task 状态操作数据库
///开始下载 或者继续下载
- (void)startDownLoad {
    
    self.video.download_state = WQDownLoadVideoStateDownloading;
    NSLog(@"download_Engine_%@任务开始下载",self.video.video_title);
    [self.task resume];
    [self.dataTask resume];
    if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:willStartDownload:)]) {
        [_taskDelegate downloadEngine:self willStartDownload:self.video];
    }
}

///暂停下载
- (void)suspendDownLoad {
    
    self.video.download_state = WQDownLoadVideoStateSuspended;
    NSLog(@"download_Engine_%@任务暂停下载",self.video.video_title);
    [self.task suspend];
    [self.dataTask suspend];
    [[WQDownLoadModelDBManager shareMnager] updateVideo:self.video];
    if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:suspendedDownload:)]) {
        [_taskDelegate downloadEngine:self suspendedDownload:self.video];
    }
}

///取消下载
- (void)cancelDownLoad {
    
    self.video.download_state = WQDownLoadVideoStateReadying;
    NSLog(@"download_Engine_%@任务取消下载",self.video.video_title);
    [self.task cancel];
    [self.dataTask cancel];
    [[WQDownLoadModelDBManager shareMnager] updateVideo:self.video];
    if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:suspendedDownload:)]) {
        [_taskDelegate downloadEngine:self suspendedDownload:self.video];
    }
}

///下载中
- (void)engineTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    self.video.download_state = WQDownLoadVideoStateDownloading;
    self.video.total_size = totalBytesExpectedToWrite;
    self.video.completed_size = totalBytesWritten;
    self.video.video_percent = [NSNumber numberWithFloat:self.video.completed_size*1.0f / self.video.total_size];
    ///下载速度
    NSTimeInterval t = [[NSDate date]timeIntervalSince1970];
    self.receiveDataTime = t;
    self.recordSize += bytesWritten;
    if (self.recordTime == 0) {
        self.recordTime = t;
        return;
    }
    if ((t - self.recordTime) >= 1) {
        float speed = (self.recordSize) / 1024 / (t - self.recordTime);
        self.recordSize = 0;
        self.recordTime = [[NSDate date]timeIntervalSince1970];
        if (speed > 0) {
            self.video.speed = [NSNumber numberWithFloat:speed];
        }
    }
    
    if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:didReceiveBytes:)]) {
        [_taskDelegate downloadEngine:self didReceiveBytes:self.video];
    }
}

///下载完成
- (void)engineTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *fullPath = _video.document_local_path;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    NSLog(@"download_Engine_%@任务下载完成",self.video.video_title);
    self.video.download_state = WQDownLoadVideoStateCompleted;
    self.video.completed_size = self.video.total_size;
    self.video.video_percent = @(1);
    [[WQDownLoadModelDBManager shareMnager] updateVideo:self.video];
    if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:didFinishDownload:)]) {
        [_taskDelegate downloadEngine:self didFinishDownload:self.video];
    }
}

///下载失败
- (void)engineTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        self.video.download_state = WQDownLoadVideoStateError;
        NSLog(@"download_Engine_%@任务下载失败",self.video.video_title);
        NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if (resumeData) {
            self.video.resume_data = resumeData;
            self.video.download_state = WQDownLoadVideoStateSuspended;
            [[WQDownLoadModelDBManager shareMnager] updateVideo:self.video];
        }
        
        if (error && _taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:handleEngineErrorWithDownloadModel:downloadError:)]) {
            [_taskDelegate downloadEngine:self handleEngineErrorWithDownloadModel:self.video downloadError:error];
        }
    }
}

///后台下载完成
- (void)engineTaskDidFinishEventsForBackgroundURLSession {
    
}

#pragma mark - NSURLSessionDataDelegate>

- (void)engineTask:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    self.video.total_size = response.expectedContentLength + self.video.completed_size;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:_video.document_local_path]) {
        [manager createFileAtPath:_video.document_local_path contents:nil attributes:nil];
    }
    
    self.stream = [[NSOutputStream alloc] initToFileAtPath:_video.document_local_path append:YES];
    [_stream open];

    completionHandler(NSURLSessionResponseAllow);
}

///把数据写入沙盒文件中
- (void)engineTask:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    [self.stream write:data.bytes maxLength:data.length];
    // 拼接文件总长度
    self.video.completed_size += data.length;
    
    self.video.download_state = WQDownLoadVideoStateDownloading;
    
    self.video.video_percent = [NSNumber numberWithFloat:self.video.completed_size*1.0f / self.video.total_size];
    ///下载速度
    NSTimeInterval t = [[NSDate date]timeIntervalSince1970];
    self.receiveDataTime = t;
    self.recordSize += data.length;
    if (self.recordTime == 0) {
        self.recordTime = t;
        return;
    }
    if ((t - self.recordTime) >= 1) {
        float speed = (self.recordSize) / 1024 / (t - self.recordTime);
        self.recordSize = 0;
        self.recordTime = [[NSDate date]timeIntervalSince1970];
        if (speed > 0) {
            self.video.speed = [NSNumber numberWithFloat:speed];
        }
    }
    
    if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:didReceiveBytes:)]) {
        [_taskDelegate downloadEngine:self didReceiveBytes:self.video];
    }
    
    
}

- (void)engineTask:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        self.video.download_state = WQDownLoadVideoStateCompleted;
        [[WQDownLoadModelDBManager shareMnager] updateVideo:self.video];
        if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:didFinishDownload:)]) {
            [_taskDelegate downloadEngine:self didFinishDownload:self.video];
        }
        [self.stream close];
       
    }else {//NSURLErrorDomain Code=-997 "Lost connection to background transfer service"
        self.video.download_state = WQDownLoadVideoStateError;
        [[WQDownLoadModelDBManager shareMnager] updateVideo:self.video];
        if (_taskDelegate && [_taskDelegate respondsToSelector:@selector(downloadEngine:handleEngineErrorWithDownloadModel:downloadError:)]) {
            [_taskDelegate downloadEngine:self handleEngineErrorWithDownloadModel:self.video downloadError:error];
        }
    }
}

@end

