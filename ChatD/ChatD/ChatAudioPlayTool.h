//
//  ChatAudioPlayTool.h
//  ChatD
//
//  Created by wanghuaiyou on 16/9/8.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "EMMessage.h"
#import <UIKit/UIKit.h>

@interface ChatAudioPlayTool : NSObject

+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver;

@end
