//
//  WQDownLoadSuccessCell.m
//  ebooksystem
//
//  Created by hapii on 2020/8/18.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadSuccessCell.h"
#import "WQDownLoadModel.h"
#import <YYKit/YYKit.h>

@interface WQDownLoadSuccessCell ()
///课程名字
@property (nonatomic, strong) UILabel *titleLab;
///响应按钮
@property (nonatomic, strong) UIButton *actionBtn;
///
@property (nonatomic, strong) UIView *lineView;
///视频时长
@property (nonatomic, strong) UILabel *videoDurationLab;
///视频大小
@property (nonatomic, strong) UILabel *videoSizeLab;

@end

@implementation WQDownLoadSuccessCell

+ (WQDownLoadSuccessCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath {
    
    WQDownLoadSuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WQDownLoadSuccessCell.class)];
    if (cell == nil) {
        cell = [[WQDownLoadSuccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(WQDownLoadSuccessCell.class)];
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
    
    self.actionBtn = [[UIButton alloc] init];
    
    self.videoSizeLab = [[UILabel alloc] init];
    self.videoSizeLab.font = [UIFont systemFontOfSize:12.0f];
    self.videoSizeLab.textColor = [UIColor grayColor];
    
    [self.actionBtn addTarget:self action:@selector(actionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.actionBtn];
    [self.contentView addSubview:self.videoSizeLab];
    [self.contentView addSubview:self.videoDurationLab];
    
    self.titleLab.frame = CGRectMake(15, 15, kScreenWidth - 80, 20);
    self.videoDurationLab.frame = CGRectMake(self.titleLab.left, self.titleLab.bottom + 5, kScreenWidth - self.titleLab.left -100, 15);
    self.videoSizeLab.frame = CGRectMake(self.titleLab.left, self.videoDurationLab.bottom + 5, 200, 15);
    self.lineView.frame = CGRectMake(self.titleLab.left, 94, kScreenWidth - self.titleLab.left - 15, 0.5);
    self.actionBtn.frame = CGRectMake(kScreenWidth - 50 - 15, self.titleLab.top, 50, 50);
    
}

- (id)transformedValue:(int64_t)value {
    
    double convertedValue = value * 1.0f;
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

- (void)setVideo:(WQDownLoadModel *)video {
    
    _video = video;
    self.titleLab.text = [NSString stringWithFormat:@"%@",video.video_title];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd"];
    self.videoDurationLab.text = [NSString stringWithFormat:@"下载时间:%@",[dateFormatter stringFromDate:video.create_time]];
    self.videoSizeLab.text = [NSString stringWithFormat:@"视频大小:%@",[self transformedValue:video.completed_size]];
    [self.actionBtn setImage:[UIImage imageNamed:@"download_play"] forState:UIControlStateNormal];
   
}

- (void)actionBtnClick {
    if (_downLoadCellActionHandle) {
        _downLoadCellActionHandle(self.video);
    }
}

@end
