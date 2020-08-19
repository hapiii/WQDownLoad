//
//  WQDownLoadSessionManager.h
//  ebooksystem
//
//  Created by hapii on 2020/6/24.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WQDownLoadModel;
@class WQDownLoadSessionEngine;

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadSessionManager : NSObject


@property (nonatomic, strong , readonly) NSURLSession *session;
+ (WQDownLoadSessionManager *)shareManager;

- (WQDownLoadSessionEngine *)createEngineWithDownLoadModel:(WQDownLoadModel *)videoInfo;

@end

NS_ASSUME_NONNULL_END
