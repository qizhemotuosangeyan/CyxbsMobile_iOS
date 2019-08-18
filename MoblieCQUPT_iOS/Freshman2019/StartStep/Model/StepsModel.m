//
//  StepsModel.m
//  MoblieCQUPT_iOS
//
//  Created by 方昱恒 on 2019/8/10.
//  Copyright © 2019 Orange-W. All rights reserved.
//

#import "StepsModel.h"
/*
 {
 "title": "报到时间",
 "message": "9月5-6日",
 "photo": "...",
 "detail": ""
 }
 */

@implementation StepsModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.title = dict[@"title"];
        self.message = dict[@"detail"];
        self.photo = [NSString stringWithFormat:@"http://129.28.185.138:8080/zsqy/image/%@", dict[@"photo"]];
        self.detail = dict[@"detail"];
    }
    return self;
}

+ (void)getModelData:(void (^)(NSArray * _Nonnull))success {
    NSString *url = @"http://129.28.185.138:8080/zsqy/json/2";
    
    HttpClient *client = [HttpClient defaultClient];
    [client requestWithPath:url method:HttpRequestGet parameters:nil prepareExecute:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject[@"text"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"start steps request failed" object:nil];
    }];
}

@end
