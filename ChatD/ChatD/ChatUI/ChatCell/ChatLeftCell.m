//
//  ChatLeftCell.m
//  ChatD
//
//  Created by wanghuaiyou on 16/9/7.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "ChatLeftCell.h"
#import "EMTextMessageBody.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "EMVoiceMessageBody.h"
#import "EMImageMessageBody.h"
#import "ChatAudioPlayTool.h"
#import "UIImageView+WebCache.h"


#define Width [UIScreen mainScreen].bounds.size.width
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@implementation ChatLeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.messageLabel.preferredMaxLayoutWidth = Width-130;
    self.backgroundColor = RGBACOLOR(248, 248, 248, 1);
    self.messageLabel.userInteractionEnabled = YES;
    self.messageLabel.userInteractionEnabled = YES;
    
    // 1.给label添加敲击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];

}

#pragma mark messagelabel 点击的触发方法
-(void)messageLabelTap:(UITapGestureRecognizer *)recognizer{
    //播放语音
    //只有当前的类型是为语音的时候才播放
    //1.获取消息体
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        NSLog(@"播放语音");
        BOOL receiver = [self.reuseIdentifier isEqualToString:left];
        [ChatAudioPlayTool playWithMessage:self.message msgLabel:self.messageLabel receiver:receiver];
        
    }
    
}



// 控件赋值
- (void)setMessage:(EMMessage *)message {
    
    _message = message;
    // 1.获取消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {//文本消息
        for(UIView *view in [self.messageLabel subviews]){
            [view removeFromSuperview];
        }
        EMTextMessageBody *textBody = body;
        self.messageLabel.text = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:textBody.text];
    }else if([body isKindOfClass:[EMVoiceMessageBody class]]){//语音消息
        for(UIView *view in [self.messageLabel subviews]){
            [view removeFromSuperview];
        }
        self.messageLabel.attributedText = [self voiceAtt];
        
    }else if([body isKindOfClass:[EMImageMessageBody class]]){//图片消息{
        for(UIView *view in [self.messageLabel subviews]){
            [view removeFromSuperview];
        }
        [self showImage];
    }else {
        for(UIView *view in [self.messageLabel subviews]){
            [view removeFromSuperview];
        }
        self.messageLabel.text = @"未知类型";
    }

}

#pragma mark 返回语音富文本
-(NSAttributedString *)voiceAtt{
    // 创建一个可变的富文本
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc] init];
    
    // 1.接收方： 富文本 ＝ 图片 + 时间
    if ([self.reuseIdentifier isEqualToString:left]) {
        // 1.1接收方的语音图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        
        // 1.2创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -9, 30, 30);
        // 1.3图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
        // 1.4.创建时间富文本
        // 获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
    }else{
        // 2.发送方：富文本 ＝ 时间 + 图片
        // 2.1 拼接时间
        // 获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
        
        // 2.1拼接图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        
        // 创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -9, 30, 30);
        // 图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
    }
    
    return [voiceAttM copy];
    
}



-(void)showImage{
    
    // 获取图片消息体
    EMImageMessageBody *imgBody = self.message.messageBodies[0];
    CGRect thumbnailFrm = (CGRect){0,0,imgBody.thumbnailSize};
    
    // 设置Label的尺寸足够显示UIImageView
    NSTextAttachment *imgAttach = [[NSTextAttachment alloc] init];
    imgAttach.bounds = thumbnailFrm;
    NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttach];
    self.messageLabel.attributedText = imgAtt;
    
    //1.cell里添加一个UIImageView
    UIImageView *chatImgView = [[UIImageView alloc] init];
    chatImgView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCellImage)];
    [chatImgView addGestureRecognizer:tapImage];
    
    [self.messageLabel addSubview:chatImgView];
    chatImgView.backgroundColor = [UIColor redColor];
    
    //2.设置图片控件为缩略图的尺寸
    chatImgView.frame = thumbnailFrm;
    
    //3.下载图片
//    NSLog(@"thumbnailLocalPath %@",imgBody.thumbnailLocalPath);
//    NSLog(@"thumbnailRemotePath %@",imgBody.thumbnailRemotePath);
    //    UIImage *palceImg = [UIImage imageNamed:@"downloading"];
//    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 如果本地图片存在，直接从本地显示图片
    if ([manager fileExistsAtPath:imgBody.thumbnailLocalPath]) {
        [chatImgView sd_setImageWithURL:[NSURL fileURLWithPath:imgBody.thumbnailLocalPath] placeholderImage:nil];
    }else{
        // 如果本地图片不存，从网络加载图片
        [chatImgView sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath] placeholderImage:nil];
    }
    
    
}

- (void)tapCellImage {
    self.tapImage();
}


// 计算cell 高度
- (CGFloat)cellForHeight {
    // 重新布局子控件
    [self layoutIfNeeded];
    return 5+10+self.messageLabel.bounds.size.height+10+10;
}

@end
