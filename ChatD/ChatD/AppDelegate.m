//
//  AppDelegate.m
//  ChatD
//
//  Created by wanghuaiyou on 16/9/7.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "AppDelegate.h"
#import "EaseMob.h"

#import "ViewController.h"
#import "ChatListController.h"

@interface AppDelegate () <EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 1.初始化SDK，并隐藏环信SDK的日志输入
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"wanghuaiyou#damao" apnsCertName:nil otherConfig:@{kSDKConfigEnableConsoleLogger:@(NO)}];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // 2.监听自动登录的状态
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 3.如果登录过，直接来到主界面
    if ([[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
       
        // 来到聊天界面
        UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:[ChatListController new]];
        self.window.rootViewController = rootNC;
        
    }else {
        // 登录
        UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
        
        self.window.rootViewController = rootNC;
        
    }

    
    
    return YES;
}

#pragma mark 自动登录的回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {
        NSLog(@"自动登录成功 %@",loginInfo);
        
        
    }else{
        NSLog(@"自动登录失败 %@",error);
    }
    
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}


@end
