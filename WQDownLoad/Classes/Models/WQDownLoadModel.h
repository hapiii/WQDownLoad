//
//  WQDownLoadModel.h
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVideoDownLoadIdentifier @"kVideoDownLoadIdentifier"
#define kDownLoadColor @"#F64A4E" 
///下载状态
typedef NS_ENUM(NSInteger, WQDownLoadVideoState) {
    ///预下载  model未存储
    WQDownLoadVideoStatePrepare = 8,
    ///等待下载 model存储,等待下载
    WQDownLoadVideoStateReadying = 1,
    ///正在下载 
    WQDownLoadVideoStateDownloading = 2,
    ///下载暂停
    WQDownLoadVideoStateSuspended = 3,
    ///下载完成
    WQDownLoadVideoStateCompleted = 4,
    ///下载失败
    WQDownLoadVideoStateError = 5
};

///下载错误类型
typedef NS_ENUM(NSUInteger, WQDownLoadVideoError) {
    ///无错误
    WQDownLoadVideoErrorNone = 0,
    ///位置错误
    WQDownLoadVideoErrorUnknow = 1,
    ///空间不足
    WQDownLoadVideoErrorNoSpace = 2,
    ///网络出错
    WQDownLoadVideoErrorNoNet = 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadModel : NSObject

///视频名字
@property (nonatomic, copy) NSString *video_title;
///视频ID
@property (nonatomic, copy) NSString *video_id;
///章节ID
@property (nonatomic, copy) NSString *chapter_id;
///课程名称
@property (nonatomic, copy) NSString *course_name;
///课程ID
@property (nonatomic, copy) NSString *course_id;
///title.mp4 因为非本地url,document地址每次变化,不可存入
@property (nonatomic, copy) NSString *local_path;
///下载地址
@property (nonatomic, copy) NSString *download_url;
///下载用户ID
@property (nonatomic, copy) NSString *user_id;
///其他存储参数
@property (nonatomic, strong) NSDictionary *video_parameter;
///封面图片Data
@property (nonatomic, copy) NSString *cover_img_url;
///下载时间
@property (nonatomic, copy) NSDate *create_time;
///视频时长
@property (nonatomic, copy) NSString *duration;

///下载状态
@property (nonatomic, assign) WQDownLoadVideoState download_state;
///错误类型
@property (nonatomic, assign) WQDownLoadVideoError error_type;
///已下载文件plist信息
@property (nonatomic, strong) NSData *resume_data;
///视频总大小
@property (nonatomic, assign) int64_t total_size;
///已下载大小
@property (nonatomic, assign) int64_t completed_size;
///已下载百分比
@property (nonatomic, strong)NSNumber *video_percent;

#pragma mark -  不存数据库

///下载速度
@property (nonatomic, strong) NSNumber *speed;
///下载状态文字描述
@property (nonatomic, copy) NSString *statesText;
///下载速度文字
@property (nonatomic, copy) NSString *speedText;
///唯一key
@property (nonatomic, copy) NSString *engineKey;
///document 路径下真实视频地址
@property (nonatomic, copy) NSString *document_local_path;

@end

NS_ASSUME_NONNULL_END
