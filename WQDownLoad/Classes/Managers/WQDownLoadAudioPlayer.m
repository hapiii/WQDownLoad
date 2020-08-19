//
//  WQDownLoadAudioPlayer.m
//  MKEducation
//
//  Created by hapii on 2020/8/13.
//  Copyright © 2020 Muke. All rights reserved.
//

#import "WQDownLoadAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface WQDownLoadAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation WQDownLoadAudioPlayer
+ (void)load {
    [WQDownLoadAudioPlayer shareManager];
}

+ (instancetype)shareManager {
    static WQDownLoadAudioPlayer *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WQDownLoadAudioPlayer alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(appDidEnterBackgroundNotif:)
                                                       name:UIApplicationDidEnterBackgroundNotification
                                                     object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(appWillEnterForeground:)
                                                       name:UIApplicationWillEnterForegroundNotification
                                                     object:nil];
    }
    return self;
}

///要进入后台
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif {
    [self beginPlay];
}

///要进入前台
- (void)appWillEnterForeground:(NSNotification*)notif {
    [self pausePlay];
}

- (void)beginPlay {
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)pausePlay {
     [self.audioPlayer pause];
}
- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
         NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"slice" ofType:@"m4a"];
        NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
        _audioPlayer.volume = 0.01;//范围为（0到1）；
        _audioPlayer.numberOfLoops =-1;
       
        _audioPlayer.currentTime = 0;
    }
    return _audioPlayer;
}

@end
