#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WQDownLoadAudioPlayer.h"
#import "WQDownLoadManager.h"
#import "WQDownLoadManagerDelegate.h"
#import "WQDownLoadModelDBManager.h"
#import "WQDownLoadSessionEngine.h"
#import "WQDownLoadSessionManager.h"
#import "WQURLSessionDownloadTaskDelegate.h"
#import "WQDownLoadModel.h"
#import "WQDownLoadCell.h"
#import "WQDownLoadChooseCell.h"
#import "WQDownLoadCourseCell.h"
#import "WQDownLoadSuccessCell.h"
#import "WQDownLoadChooseController.h"
#import "WQDownLoadCourseController.h"
#import "WQDownLoadDownController.h"
#import "WQDownLoadDownloadController.h"
#import "WQDownLoadViewController.h"

FOUNDATION_EXPORT double WQDownLoadVersionNumber;
FOUNDATION_EXPORT const unsigned char WQDownLoadVersionString[];

