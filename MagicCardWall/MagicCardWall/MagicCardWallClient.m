//
//  MagicCardWallClient.m
//  MagicCardWall
//
//  Created by Simon Cook on 6/11/14.
//  Copyright (c) 2014 Trade Me. All rights reserved.
//

#import "MagicCardWallClient.h"

#import "Lockbox.h"

@implementation MagicCardWallClient

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MagicCardWallClient *instance;
    dispatch_once(&onceToken, ^{
        instance = [[MagicCardWallClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://tmlt218.trademe.local:8888"]];
    });
    
    return instance;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:
                                   @[[AFJSONResponseSerializer serializer],[AFHTTPResponseSerializer serializer]]];
    }
    
    return self;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL success, NSError *error))completion {
    
    [self.requestSerializer setValue:[Lockbox stringForKey:@"Token"] forHTTPHeaderField:@"Cookie"];
    
    [self POST:@"/api/Login" parameters:@{@"Username" : username, @"Password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        BOOL success = [dictionary[@"Success"] boolValue];
        
        if (success) {
            NSString *token = dictionary[@"Token"];
            [Lockbox setString:token forKey:@"Token"];
            completion(YES, nil);
        }
        else {
            NSString *errorMessage = dictionary[@"ErrorMessage"];
            completion(NO, [NSError errorWithDomain:@"MCW" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(NO, error);
    }];
}

- (void)incrementStateForTask:(NSString *)taskIdentifier undo:(BOOL)undo completion:(void (^)(BOOL success, NSError *error))completion {
    
    [self.requestSerializer setValue:[Lockbox stringForKey:@"Token"] forHTTPHeaderField:@"Cookie"];
        
    [self POST:[NSString stringWithFormat:@"/api/Status?issueId=%@&undo=%@", [taskIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], undo ? @"true" : @"false"] parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSLog(@"%i", [responseString boolValue]);
        
        completion([responseString boolValue], nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        completion(NO, error);
    }];
}


@end
