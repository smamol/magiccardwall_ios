//
//  HistoryItem.h
//  MagicCardWall
//
//  Created by Simon Cook on 7/11/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryItem : NSObject

@property (strong, nonatomic) NSString *taskId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *username;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
