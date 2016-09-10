//
//  EaseMobManger.m
//  ChatD
//
//  Created by wanghuaiyou on 16/9/9.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "EaseMobManger.h"

@interface EaseMobManger ()<EMChatManagerDelegate>



@end

@implementation EaseMobManger

+ (void)registerSDKWithAppKey:(NSString *)key application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    // 1.初始化SDK，并隐藏环信SDK的日志输入
    [[EaseMob sharedInstance] registerSDKWithAppKey:key apnsCertName:nil otherConfig:@{kSDKConfigEnableConsoleLogger:@(NO)}];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // 2.监听自动登录的状态
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

#pragma mark 自动登录的回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    if (!error) {
        NSLog(@"自动登录成功 %@",loginInfo);
        self.LoginSucceed(loginInfo);
        
    }else{
        NSLog(@"自动登录失败 %@",error);
        self.LoginFail(error);
    }
    
}

+ (void)loginWithUserName:(NSString *)userName password:(NSString *)password {
 
    // 登录
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userName password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        // 登录请求完成后的block回调
        if (!error) {
        
            NSLog(@"登录成功 %@",loginInfo);
            // 设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            
        }else{
            
            NSLog(@"登录失败 %@",error);
        }
        
    } onQueue:dispatch_get_main_queue()];

}

// App进入后台
+ (void)mangerApplicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
+ (void)mangerApplicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
+ (void)mangerApplicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}



@end
