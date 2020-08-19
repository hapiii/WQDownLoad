//
//  WQDownLoadCell.h
//  ebooksystem
//
//  Created by hapii on 2020/6/28.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WQDownLoadModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadCell : UITableViewCell

+ (WQDownLoadCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath;

@property (nonatomic, strong) WQDownLoadModel *video;

@property (nonatomic, copy) void (^downLoadCellActionHandle)(WQDownLoadModel *model);

@end

NS_ASSUME_NONNULL_END
