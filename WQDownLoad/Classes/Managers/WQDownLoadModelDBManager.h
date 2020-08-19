//
//  WQDownLoadModelDBManager.h
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WQDownLoadModel.h"

typedef NS_ENUM(NSInteger ,WQDownLoadGetDataType){
    ///未下载成功
    WQDownLoadGetDataUnSuccess = 0,
    ///已下载成功
    WQDownLoadGetDataSuccess = 1,
    ///全部
    WQDownLoadGetDataAll = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadModelDBManager : NSObject

+ (WQDownLoadModelDBManager *)shareMnager;
///初始化
- (BOOL)insertVideo:(WQDownLoadModel *)videoInfo;
///更新视频状态
- (BOOL)updateVideo:(WQDownLoadModel *)model;
///删除视频
- (BOOL)deleteVideo:(WQDownLoadModel *)video;
///获取未成功的下载任务
- (nullable NSArray < WQDownLoadModel *> *)downLoadFailedModels;
///已下载成功
- (nullable NSArray < WQDownLoadModel *> *)downLoadSuccessModels;
///全部本地下载
- (nullable NSArray < WQDownLoadModel *> *)downLoadAllModels;
///指定课程下数据
- (nullable NSArray < WQDownLoadModel *> *)getDownLoadModelsWithType:(WQDownLoadGetDataType )type courseID:(nullable NSString *)courseId;

- (nullable WQDownLoadModel *)downLoadModelWithKey:(NSString *)engineHash;

@end

NS_ASSUME_NONNULL_END
