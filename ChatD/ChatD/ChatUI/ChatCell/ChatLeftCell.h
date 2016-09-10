//
//  ChatLeftCell.h
//  ChatD
//
//  Created by wanghuaiyou on 16/9/7.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessage.h"
static NSString *left = @"left";
static NSString *right = @"right";

typedef void(^TapImage)();

@interface ChatLeftCell : UITableViewCell



@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

// 数据模型
@property (nonatomic, strong) EMMessage *message;

- (CGFloat)cellForHeight;

@property (nonatomic, strong) TapImage tapImage;

@end
