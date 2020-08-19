//
//  WQDownLoadCell.m
//  ebooksystem
//
//  Created by hapii on 2020/6/28.
//  Copyright © 2020 sanweishuku. All rights reserved.
//

#import "WQDownLoadCell.h"
#import "WQDownLoadModel.h"
#import <YYKit/YYKit.h>

@interface WQDownLoadCell ()
///课程名字
@property (nonatomic, strong) UILabel *titleLab;
///响应按钮
@property (nonatomic, strong) UIButton *actionBtn;
///进度条
@property (nonatomic, strong) UIProgressView *progress;
///速度
@property (nonatomic, strong) UILabel *speedLab;
///视频时长
@property (nonatomic, strong) UILabel *videoDurationLab;
///视频大小
@property (nonatomic, strong) UILabel *videoSizeLab;
///头图
@property (nonatomic, strong) UIImageView *headImg;

@end

@implementation WQDownLoadCell

+ (WQDownLoadCell *)cellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath {
    WQDownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(WQDownLoadCell.class)];
    if (cell == nil) {
        cell = [[WQDownLoadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(WQDownLoadCell.class)];
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
    
    self.headImg = [[UIImageView alloc] init];
    self.headImg.image = [UIImage imageNamed:@"download_play"];
    self.titleLab = [[UILabel alloc] init];
    self.videoDurationLab = [[UILabel alloc] init];
    self.videoDurationLab.font = [UIFont systemFontOfSize:12.5f];
    self.videoDurationLab.textColor = [UIColor grayColor];
    
    self.progress = [[UIProgressView alloc] init];
    self.progress.tintColor = [UIColor colorWithHexString:kDownLoadColor];
    
    self.speedLab = [[UILabel alloc] init];
    self.speedLab.font = [UIFont systemFontOfSize:11.0f];
    self.speedLab.textColor = [UIColor grayColor];
    self.speedLab.textAlignment = NSTextAlignmentRight;
    self.actionBtn = [[UIButton alloc] init];
    
    self.videoSizeLab = [[UILabel alloc] init];
    self.videoSizeLab.font = [UIFont systemFontOfSize:11.0f];
    self.videoSizeLab.textColor = [UIColor grayColor];
    
    [self.actionBtn.titleLabel setFont:[UIFont systemFontOfSize:9.0f]];
    [self.actionBtn addTarget:self action:@selector(actionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.headImg];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.progress];
    [self.contentView addSubview:self.speedLab];
    [self.contentView addSubview:self.actionBtn];
    [self.contentView addSubview:self.videoSizeLab];
    [self.contentView addSubview:self.videoDurationLab];
}

- (void)layoutSubviews {
    
    self.headImg.frame = CGRectMake(10, 15, 20, 20);
    self.titleLab.frame = CGRectMake(40, 15, kScreenWidth - 100, 20);
    self.videoDurationLab.frame = CGRectMake(self.titleLab.left, self.titleLab.bottom + 5, kScreenWidth - self.titleLab.left -100, 15);
    self.videoSizeLab.frame = CGRectMake(self.titleLab.left, self.videoDurationLab.bottom + 5, 200, 15);
    self.progress.frame = CGRectMake(self.titleLab.left, self.videoSizeLab.bottom + 5, kScreenWidth - self.titleLab.left - 15, 10);
    self.actionBtn.frame = CGRectMake(kScreenWidth - 30 - 15, self.titleLab.top, 30, 30);
    self.speedLab.frame =  CGRectMake(kScreenWidth - 165, self.videoSizeLab.top , 150, 15);
    
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
    self.titleLab.text = [NSString stringWithFormat:@"%@-%@",video.course_name,video.video_title];
    self.progress.progress = [video.video_percent floatValue];
    self.speedLab.text = video.speedText;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd"];
    self.videoDurationLab.text = [dateFormatter stringFromDate:video.create_time];
    self.videoSizeLab.text = [NSString stringWithFormat:@"%@/%@",[self transformedValue:video.completed_size],[self transformedValue:video.total_size]];
    
    switch (video.download_state) {
        case WQDownLoadVideoStatePrepare:
        case WQDownLoadVideoStateReadying:{
            [self.actionBtn setImage:[UIImage imageNamed:@"download_wait"] forState:UIControlStateNormal];
        }break;
        case WQDownLoadVideoStateError:{
            [self.actionBtn setImage:[UIImage imageNamed:@"download_error"] forState:UIControlStateNormal];
        }break;
        case WQDownLoadVideoStateSuspended:{
            [self.actionBtn setImage:[UIImage imageNamed:@"download_begin"] forState:UIControlStateNormal];
        }break;
        case WQDownLoadVideoStateCompleted:{
            [self.actionBtn setImage:[UIImage imageNamed:@"download_play"] forState:UIControlStateNormal];
        }break;
        case WQDownLoadVideoStateDownloading:{
            [self.actionBtn setImage:[UIImage imageNamed:@"download_suspended"] forState:UIControlStateNormal];
            
        }break;
            
    }
}

- (void)actionBtnClick {
    if (_downLoadCellActionHandle) {
        _downLoadCellActionHandle(self.video);
    }
}


@end
