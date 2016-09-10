//
//  EaseMobManger.h
//  ChatD
//
//  Created by wanghuaiyou on 16/9/9.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMob.h"

// 登录回调的block(成功&失败)
typedef void(^LoginStatus)(id obj);

@interface EaseMobManger : NSObject

// 初始化sdk
+ (void)registerSDKWithAppKey:(NSString *)key application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

// 自动登录成功
@property (nonatomic, strong) LoginStatus LoginSucceed;
// 自动登录失败
@property (nonatomic, strong) LoginStatus LoginFail;

// 登录 并设置自动登录
+ (void)loginWithUserName:(NSString *)userName password:(NSString *)password;

// App进入后台
+ (void)mangerApplicationDidEnterBackground:(UIApplication *)application;
//{
//    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
//}

// App将要从后台返回
+ (void)mangerApplicationWillEnterForeground:(UIApplication *)application;
//{
//    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
//}

// 申请处理时间
+ (void)mangerApplicationWillTerminate:(UIApplication *)application;
//{
//    [[EaseMob sharedInstance] applicationWillTerminate:application];
//}



@end
