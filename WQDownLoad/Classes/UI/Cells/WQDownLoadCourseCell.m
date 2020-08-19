//
//  WQDownLoadCourseCell.m
//  ebooksystem
//
//  Created by hapii on 2020/8/17.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadCourseCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WQDownLoadCourseCell ()

@property (nonatomic, strong) UIImageView *courseImg;

@property (nonatomic, strong) UILabel *courseLab;

@end

@implementation WQDownLoadCourseCell

+ (WQDownLoadCourseCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath {
    WQDownLoadCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WQDownLoadCourseCell.class)];
    if (cell == nil) {
        cell = [[WQDownLoadCourseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(WQDownLoadCourseCell.class)];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    
    [self.contentView addSubview:self.courseImg];
    [self.contentView addSubview:self.courseLab];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.courseImg.frame = CGRectMake(15, 18, 100, 64);
    self.courseLab.frame = CGRectMake(125, 18, self.contentView.frame.size.width - 45, 64);
}

- (UIImageView *)courseImg {
    if (!_courseImg) {
        _courseImg = [[UIImageView alloc] init];
        _courseImg.layer.cornerRadius = 4.0f;
        _courseImg.layer.masksToBounds = YES;
    }
    return _courseImg;
}

- (UILabel *)courseLab {
    if (!_courseLab) {
        _courseLab = [[UILabel alloc] init];
        if (@available(iOS 8.2, *)) {
            _courseLab.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
        } else {
             _courseLab.font = [UIFont systemFontOfSize:14.0f ];
        }
    }
    return _courseLab;
}

- (void)setDownLoadModel:(WQDownLoadModel *)downLoadModel {

    _downLoadModel = downLoadModel;
    self.courseLab.text = downLoadModel.video_title;
   [self.courseImg sd_setImageWithURL:[NSURL URLWithString:downLoadModel.cover_img_url]];
    
}
@end
