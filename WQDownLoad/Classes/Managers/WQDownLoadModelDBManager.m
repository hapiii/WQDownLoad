//
//  WQDownLoadModelDBManager.m
//  MKEducation
//
//  Created by hapii on 2020/6/22.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadModelDBManager.h"
#import <fmdb/FMDB.h>
#import "WQDownLoadModel.h"
#import <YYKit/YYKit.h>

@interface WQDownLoadModelDBManager ()
///已下载课程
@property (nonatomic, strong) NSMutableDictionary *memoryModels;

@end

@implementation WQDownLoadModelDBManager{
    dispatch_semaphore_t _lock;
}
static FMDatabase *_db;

+ (WQDownLoadModelDBManager *)shareMnager {
    static WQDownLoadModelDBManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WQDownLoadModelDBManager alloc]init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [docPath stringByAppendingPathComponent:@"mkdata.db"];
        _db = [FMDatabase databaseWithPath:path];
        [_db open];
        NSString *createTableSqlString = @"CREATE TABLE IF NOT EXISTS local_video (id integer primary key AUTOINCREMENT,video_hash varchar(64) , video_title varchar(100), video_id varchar(64), chapter_id varchar(64), course_id varchar(64),course_name varchar(64), local_path varchar(200), download_url varchar(200), user_id varchar(64), video_parameter varchar(1000), cover_img_url varchar(64), create_time double ,duration varchar(64) ,total_size varchar(64), completed_size varchar(64),download_state integer, error_type integer ,video_percent float , resume_data blob)";
        if(![_db executeUpdate:createTableSqlString]){
            
        }
        [_db close];
        _memoryModels = [[NSMutableDictionary alloc] init];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}


///视频信息在数据库中初始化 下载状态变为ready
- (BOOL)insertVideo:(WQDownLoadModel *)videoInfo {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_memoryModels setValue:videoInfo forKey:videoInfo.engineKey];
    
    @try {
        [_db open];
        FMResultSet *res = [_db executeQuery:@"SELECT * FROM local_video WHERE video_hash = ?",videoInfo.engineKey];
        
        while ([res next]) {
            [_db close];
            return NO;//防止重复添加
        }
        NSString *sql = @"insert into local_video (video_hash , video_title, video_id, chapter_id, course_id,course_name, local_path, download_url, user_id ,video_parameter ,cover_img_url, create_time, download_state) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        //[res close];
        if (![_db executeUpdate:sql,
              videoInfo.engineKey,videoInfo.video_title, videoInfo.video_id, videoInfo.chapter_id, videoInfo.course_id,videoInfo.course_name, videoInfo.local_path, videoInfo.download_url,videoInfo.user_id,videoInfo.video_parameter,videoInfo.cover_img_url,videoInfo.create_time,[NSNumber numberWithInt:WQDownLoadVideoStateReadying]]) {
            
            [_db close];
            dispatch_semaphore_signal(_lock);
            return NO;
        }
        
    }
    @catch(NSException *exception) {
        
        [_db close];
        dispatch_semaphore_signal(_lock);
        return NO;
    }
    @finally {
        [_db close];
        dispatch_semaphore_signal(_lock);
        return YES;
    }
}

///刷新下载状态
- (BOOL)updateVideo:(WQDownLoadModel *)model {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_memoryModels[model.engineKey]) {
        [_memoryModels setValue:model forKey:model.engineKey];
    }
    @try {
        [_db open];
        NSString *sql = @"UPDATE local_video SET download_state = ? , error_type = ? , total_size = ? , completed_size = ? , video_percent = ?, resume_data = ? WHERE video_id = ?";
        BOOL res = [_db executeUpdate:sql,[NSNumber numberWithInteger:model.download_state], [NSNumber numberWithInteger:model.error_type], [NSString stringWithFormat:@"%lli",model.total_size], [NSString stringWithFormat:@"%lli",model.completed_size], @(model.video_percent.floatValue) ,model.resume_data,model.video_id];
        if (!res) {
            
            [_db close];
            dispatch_semaphore_signal(_lock);
            return NO;
        }
    } @catch (NSException *exception) {
        
        [_db close];
        dispatch_semaphore_signal(_lock);
        return NO;
    } @finally {
        
        dispatch_semaphore_signal(_lock);
        [_db close];
    }
}

- (BOOL)deleteVideo:(WQDownLoadModel *)video {
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_memoryModels removeObjectForKey:video.engineKey];
    @try {
        [_db open];
        NSString *sql = @"delete from local_video where video_hash = ?";
        BOOL res = [_db executeUpdate:sql,video.engineKey];
        if (!res) {
            
            [_db close];
            dispatch_semaphore_signal(_lock);
            return NO;
        }
        if ([[NSFileManager defaultManager] removeItemAtPath:video.document_local_path error:nil]) {
            [_db close];
            dispatch_semaphore_signal(_lock);
            return YES;
        };
    } @catch (NSException *exception) {
        
        dispatch_semaphore_signal(_lock);
        [_db close];
        return NO;
    } @finally {
        
        dispatch_semaphore_signal(_lock);
        [_db close];
    }
}

///查看是否有该视频
- (nullable WQDownLoadModel *)downLoadModelWithKey:(NSString *)engineHash {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (self.memoryModels.count > 0) {
        dispatch_semaphore_signal(_lock);
        return [self.memoryModels objectForKey:engineHash];
        
    }else {
        [_db open];
        
        NSString *sql = @"select id , video_title, video_id, chapter_id, course_id, local_path, download_url, user_id, video_parameter ,cover_img_url ,create_time , duration ,download_state ,error_type, video_percent , resume_data , completed_size video_hash from local_video where video_hash = ?";
        FMResultSet *set = [_db executeQuery:sql,engineHash];
        
        if ([set next]) {
            WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
            //model. = [NSNumber numberWithInt:[set intForColumnIndex:0]];
            model.video_title = [set stringForColumnIndex:1];
            model.video_id = [set stringForColumnIndex:2];
            model.chapter_id = [set stringForColumnIndex:3];
            model.course_id = [set stringForColumnIndex:4];
            model.local_path = [set stringForColumnIndex:5];
            model.download_url = [set stringForColumnIndex:6];
            model.user_id = [set stringForColumnIndex:7];
            
            NSData *jsonData = [[set stringForColumnIndex:8] dataUsingEncoding:NSUTF8StringEncoding];
            if (jsonData) {
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                model.video_parameter = dic;
            }
            
            model.cover_img_url = [set stringForColumnIndex:9];
            model.create_time = [set dateForColumnIndex:10];
            model.duration = [set stringForColumnIndex:11];
            model.download_state = [set intForColumnIndex:12];
            model.error_type = [set intForColumnIndex:13];
            model.video_percent = [NSNumber numberWithString:[set stringForColumnIndex:14]];
            model.resume_data = [set dataForColumnIndex:15];
            model.completed_size = [set intForColumnIndex:16];
            model.engineKey = [set stringForColumnIndex:17];
            [set close];
            [_db close];
            dispatch_semaphore_signal(_lock);
            return model;
        }else {
            [set close];
            [_db close];
            dispatch_semaphore_signal(_lock);
            return nil;
        }
        
        
    }
}

- (nullable NSArray < WQDownLoadModel *> *)downLoadFailedModels {
    
    return [[WQDownLoadModelDBManager shareMnager] getDownLoadModelsWithType:WQDownLoadGetDataUnSuccess];
}

- (nullable NSArray < WQDownLoadModel *> *)downLoadSuccessModels {
    
    return [[WQDownLoadModelDBManager shareMnager] getDownLoadModelsWithType:WQDownLoadGetDataSuccess];
}

- (NSArray<WQDownLoadModel *> *)downLoadAllModels {
    NSArray *arr = [[WQDownLoadModelDBManager shareMnager] getDownLoadModelsWithType:WQDownLoadGetDataAll];
    for (WQDownLoadModel *model in arr) {
        [self.memoryModels setValue:model forKey:model.engineKey];
    }
    return arr;
}

- (nullable NSArray < WQDownLoadModel *> *)getDownLoadModelsWithType:(WQDownLoadGetDataType )type courseID:(nullable NSString *)courseId {
    
    [_db open];
    
    
    NSString *sql;
    switch (type) {
        case WQDownLoadGetDataUnSuccess:
            sql = @"select id , video_title, video_id, chapter_id, course_id, local_path, download_url, user_id, video_parameter ,cover_img_url ,create_time , duration ,download_state ,error_type, video_percent , resume_data ,completed_size , video_hash ,course_name, total_size from local_video where download_state != 4";
            break;
        case WQDownLoadGetDataSuccess:
            sql = @"select id , video_title, video_id, chapter_id, course_id, local_path, download_url, user_id, video_parameter ,cover_img_url ,create_time , duration ,download_state ,error_type, video_percent , resume_data ,completed_size , video_hash ,course_name , total_size from local_video where download_state = 4";
            break;
        case WQDownLoadGetDataAll:
            sql = @"select id , video_title, video_id, chapter_id, course_id, local_path, download_url, user_id, video_parameter ,cover_img_url ,create_time , duration ,download_state ,error_type, video_percent , resume_data ,completed_size , video_hash ,course_name , total_size from local_video";
            break;
            break;
    }
    
    if (courseId) {
        if (type == WQDownLoadGetDataAll) {
            sql = [NSString stringWithFormat:@"%@ where course_id = '%@'",sql, courseId];
        }else {
            sql = [NSString stringWithFormat:@"%@ and course_id = '%@'",sql, courseId];
        }
        
    }
    FMResultSet *set = [_db executeQuery:sql];
    NSArray *arr = [self setToModel:set];
    
    [set close];
    [_db close];
    return arr.count > 0 ? arr.copy : nil;
    
    
}

- (nullable NSArray < WQDownLoadModel *> *)getDownLoadModelsWithType:(WQDownLoadGetDataType )type {
    return [self getDownLoadModelsWithType:type courseID:nil];
}

- (NSArray <WQDownLoadModel *> *)setToModel:(FMResultSet *)set {
    NSMutableArray *arr = @[].mutableCopy;
    while ([set next]) {
        WQDownLoadModel *model = [[WQDownLoadModel alloc] init];
        model.video_title = [set stringForColumnIndex:1];
        model.video_id = [set stringForColumnIndex:2];
        model.chapter_id = [set stringForColumnIndex:3];
        model.course_id = [set stringForColumnIndex:4];
        model.local_path = [set stringForColumnIndex:5];
        model.download_url = [set stringForColumnIndex:6];
        model.user_id = [set stringForColumnIndex:7];
        
        NSData *jsonData = [[set stringForColumnIndex:8] dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            model.video_parameter = dic;
        }
        
        model.cover_img_url = [set stringForColumnIndex:9];
        model.create_time = [set dateForColumnIndex:10];
        model.duration = [set stringForColumnIndex:11];
        model.download_state = [set intForColumnIndex:12];
        model.error_type = [set intForColumnIndex:13];
        model.video_percent = [NSNumber numberWithString:[set stringForColumnIndex:14]];
        model.resume_data = [set dataForColumnIndex:15];
        model.completed_size = [set intForColumnIndex:16];
        model.engineKey = [set stringForColumnIndex:17];
        model.course_name = [set stringForColumnIndex:18];
        model.total_size = [set intForColumnIndex:19];
        [arr addObject:model];
        
    }
    return arr;
}



@end
