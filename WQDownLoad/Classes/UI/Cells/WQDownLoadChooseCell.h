//
//  WQDownLoadChooseCell.h
//  ebooksystem
//
//  Created by hapii on 2020/8/18.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WQDownLoadModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WQDownLoadChooseCell : UITableViewCell

+ (WQDownLoadChooseCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath;

@property (nonatomic, strong) WQDownLoadModel *video;

@end

NS_ASSUME_NONNULL_END
