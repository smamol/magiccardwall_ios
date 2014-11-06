//
//  MagicCardWallClient.h
//  MagicCardWall
//
//  Created by Simon Cook on 6/11/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface MagicCardWallClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL success, NSError *error))completion;

- (void)incrementStateForTask:(NSString *)taskIdentifier completion:(void (^)(BOOL success, NSError *error))completion;

- (void)decrementStateForTask:(NSString *)taskIdentifier completion:(void (^)(BOOL success, NSError *error))completion;

@end
