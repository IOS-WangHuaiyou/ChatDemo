//
//  ViewController.m
//  ChatD
//
//  Created by wanghuaiyou on 16/9/7.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "ViewController.h"
#import "EaseMob.h"
#import "ChatListController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    label.text = @"登录中....";
    label.backgroundColor = [UIColor yellowColor];
    label.textColor= [UIColor redColor];
    label.font = [UIFont systemFontOfSize:22];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    
    // 登录
    [self login];
    
}


- (void)login {
    // 登录
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:@"qq" password:@"qq" completion:^(NSDictionary *loginInfo, EMError *error) {
        // 登录请求完成后的block回调
        if (!error) {
            /*
             {
             LastLoginTime = 1443083631296;
             jid = "vgios#xmg1chat_xmgtest1@easemob.com";
             password = 123456;
             resource = mobile;
             token = "YWMt-2kmTmKWEeWhivny1t_c6gAAAVEzekiFP9xOO0dqxYGGu4uI5CZNNCoaV0Y";
             username = xmgtest1;
             }
             */
            NSLog(@"登录成功 %@",loginInfo);
            // 设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            
            [self.navigationController pushViewController:[ChatListController new] animated:YES];
            
            
        }else{
            NSLog(@"登录失败 %@",error);
        }
        
        
        
    } onQueue:dispatch_get_main_queue()];
}

@end
