//
//  WQDownLoadCourseCell.h
//  ebooksystem
//
//  Created by hapii on 2020/8/17.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WQDownLoadModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadCourseCell : UITableViewCell

+ (WQDownLoadCourseCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath;
@property (nonatomic, strong) WQDownLoadModel *downLoadModel;

@end

NS_ASSUME_NONNULL_END
