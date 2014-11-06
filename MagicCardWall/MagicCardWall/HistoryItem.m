//
//  HistoryItem.m
//  MagicCardWall
//
//  Created by Simon Cook on 7/11/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _taskId = dictionary[@"Id"];
        _title = dictionary[@"Title"];
        _timestamp = dictionary[@"Timestamp"];
        _status = dictionary[@"Status"];
        _avatarUrl = dictionary[@"AvatarUrl"];
        _username = dictionary[@"Username"];
    }
    
    return self;
}

@end
