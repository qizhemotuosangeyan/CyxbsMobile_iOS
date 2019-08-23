//
//  ActivityItem.m
//  CQUPT_Mobile
//
//  Created by 方昱恒 on 2019/8/6.
//  Copyright © 2019 方昱恒. All rights reserved.
//

#import "ActivityItem.h"

@implementation ActivityItem

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        
        self.name = dict[@"name"];
        self.photo = [NSString stringWithFormat:@"http://129.28.185.138:8080/zsqy/image/%@", dict[@"photo"]];
        self.message = dict[@"message"];
        self.QRCode = [NSString stringWithFormat:@"http://129.28.185.138:8080/zsqy/image/%@", dict[@"QR"]];
    }
    return self;
}

@end