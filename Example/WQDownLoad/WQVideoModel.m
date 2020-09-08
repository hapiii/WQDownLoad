//
//  WQVideoModel.m
//  WQDownLoad_Example
//
//  Created by hapii on 2020/9/8.
//  Copyright © 2020 hapiii. All rights reserved.
//

#import "WQVideoModel.h"

@implementation WQVideoModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"video_id" : @"id"};
}
@end
