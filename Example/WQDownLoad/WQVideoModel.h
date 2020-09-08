//
//  WQVideoModel.h
//  WQDownLoad_Example
//
//  Created by hapii on 2020/9/8.
//  Copyright © 2020 hapiii. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WQVideoModel : NSObject

@property (nonatomic, copy) NSString *video_id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *publicTime;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *toStar;

@property (nonatomic, copy) NSString *performer;

@property (nonatomic, copy) NSString *country;

@property (nonatomic, copy) NSString *alias;

@property (nonatomic, copy) NSString *img;

@property (nonatomic, copy) NSString *video;

@property (nonatomic, copy) NSString *episodes;

@end

NS_ASSUME_NONNULL_END
