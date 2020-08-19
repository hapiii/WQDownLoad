//
//  WQDownLoadChooseCell.m
//  ebooksystem
//
//  Created by hapii on 2020/8/18.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadChooseCell.h"
#import <YYKit/YYKit.h>

@interface WQDownLoadChooseCell ()
///课程名字
@property (nonatomic, strong) UILabel *titleLab;
///
@property (nonatomic, strong) UIView *lineView;
///视频时长
@property (nonatomic, strong) UILabel *videoDurationLab;
///视频大小
@property (nonatomic, strong) UILabel *videoSizeLab;

@end

@implementation WQDownLoadChooseCell

+ (WQDownLoadChooseCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath {
    
    WQDownLoadChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WQDownLoadChooseCell.class)];
    if (cell == nil) {
        cell = [[WQDownLoadChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(WQDownLoadChooseCell.class)];
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
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.numberOfLines = 2;
    self.videoDurationLab = [[UILabel alloc] init];
    self.videoDurationLab.font = [UIFont systemFontOfSize:12.0f];
    self.videoDurationLab.textColor = [UIColor grayColor];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor lightGrayColor];
    
    
    self.videoSizeLab = [[UILabel alloc] init];
    self.videoSizeLab.font = [UIFont systemFontOfSize:12.0f];
    self.videoSizeLab.textColor = [UIColor grayColor];
    
    
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.lineView];

    [self.contentView addSubview:self.videoSizeLab];
    [self.contentView addSubview:self.videoDurationLab];
    
    self.titleLab.frame = CGRectMake(15, 15, kScreenWidth - 80, 20);
    self.videoDurationLab.frame = CGRectMake(self.titleLab.left, self.titleLab.bottom + 5, kScreenWidth - self.titleLab.left -100, 15);
    self.videoSizeLab.frame = CGRectMake(self.titleLab.left, self.videoDurationLab.bottom + 5, 200, 15);
    self.lineView.frame = CGRectMake(self.titleLab.left, 94, kScreenWidth - self.titleLab.left - 15, 0.5);
    
}

- (void)setVideo:(WQDownLoadModel *)video {
    
    _video = video;
    self.titleLab.text = [NSString stringWithFormat:@"%@",video.video_title];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd"];
    self.videoDurationLab.text = video.course_name;
    self.videoSizeLab.text = video.download_state ? @"下载任务已存在":@"可加入下载";
}


@end
