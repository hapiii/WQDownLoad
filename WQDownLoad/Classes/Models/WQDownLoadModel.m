
//
//  WQDownLoadModel.m
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadModel.h"
#import <YYKit/NSString+YYAdd.h>

@implementation WQDownLoadModel

- (NSString *)local_path {
    
    if (!_local_path) {
       
        NSString *absolutePath = [NSString stringWithFormat:@"%@.mp4",self.video_title];
        _local_path = absolutePath;
    }
    return _local_path;
}

- (NSString *)document_local_path {
    
    if (!_document_local_path) {
        
       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        
         NSString *coursePath = [NSString stringWithFormat:@"%@/video/%@",documentsPath,self.course_id];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL isDir = NO;
                BOOL existed = [fileManager fileExistsAtPath:coursePath isDirectory:&isDir];
                if (!(isDir && existed)) {
                    [fileManager createDirectoryAtPath:coursePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
        _document_local_path =[NSString stringWithFormat:@"%@/%@",coursePath,self.local_path];
    }
    return _document_local_path;
}

- (NSString *)statesText {
    
    switch (self.download_state) {
        case WQDownLoadVideoStatePrepare:
            _statesText = @"预下载";
            break;
        case WQDownLoadVideoStateReadying:
            _statesText = @"等待下载";
            break;
        case WQDownLoadVideoStateSuspended:
            _statesText = @"下载暂停";
            break;
        case WQDownLoadVideoStateDownloading:
            _statesText = @"下载中";
            break;
        case WQDownLoadVideoStateCompleted:
            _statesText = @"下载完成";
            break;
        case WQDownLoadVideoStateError:
            _statesText = @"下载出错";
            break;
    }
    
    return _statesText;
}

- (NSString *)speedText {
    return [NSString stringWithFormat:@"%.1f kb/s",self.speed.floatValue];
}

- (NSString *)engineKey {
    if (!_engineKey) {
        
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@",kVideoDownLoadIdentifier , self.course_id,self.video_id];
        _engineKey = key.md5String;
    }
    return _engineKey;
}

@end
