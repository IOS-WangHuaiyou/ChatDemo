//
//  ChatListController.m
//  ChatD
//
//  Created by wanghuaiyou on 16/9/7.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "ChatListController.h"
#import "ChatViewController.h"

@interface ChatListController ()

@end

@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)chatClickBlue:(UIButton *)sender {
    
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.userName = @"q";
    [self.navigationController pushViewController:chatVC animated:YES];
}


- (IBAction)chatClickRead:(UIButton *)sender {
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    [self.navigationController pushViewController:chatVC animated:YES];
}



@end
