//
//  ChatViewController.m
//  ChatD
//
//  Created by wanghuaiyou on 16/9/7.
//  Copyright © 2016年 wanghuaiyou. All rights reserved.
//

#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "EMMessage.h"
#import "EMCDDeviceManager.h"
#import "EMChatVoice.h"
#import "EMChatVideo.h"
#import "ChatLeftCell.h"
#import "EaseMob.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "EMImageMessageBody.h"
#import "UIImageView+WebCache.h"




#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

@interface ChatViewController () <DXMessageToolBarDelegate, DXChatBarMoreViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,EMChatManagerDelegate>
// 底部工具条
@property (nonatomic, strong) DXMessageToolBar *bottomToolBar;
// 相机/相册
@property (strong, nonatomic) UIImagePickerController *imagePicker;
// 聊天列表
@property (strong, nonatomic) UITableView *tableView;
// 数据数组
@property (nonatomic, strong) NSMutableArray *dataAry;

// 计算cell高度的管理类
@property (nonatomic, strong) ChatLeftCell *chatCellTool;

// 大图
@property (nonatomic, strong) UIImageView *cellImage;

@end

@implementation ChatViewController

- (NSMutableArray *)dataAry {
    if (_dataAry == nil) {
        _dataAry = [NSMutableArray array];
    }
    return _dataAry;
}

- (UIImageView *)cellImage {
    if (_cellImage == nil) {
        _cellImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _cellImage.userInteractionEnabled = YES;
        UILabel *load = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, _cellImage.frame.size.width, 100)];
        load.text = @"加载中...";
        load.font = [UIFont systemFontOfSize:30];
        load.textAlignment = NSTextAlignmentCenter;
        if (_cellImage.image) {
            
            [_cellImage addSubview:load];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFousuperView)];
        
        [_cellImage addGestureRecognizer:tap];
    }
    return _cellImage;
}

- (void)removeFousuperView {
    self.navigationController.navigationBar.hidden = NO;
    [_cellImage removeFromSuperview];
}

- (void)collocate {

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< 返回" style:(UIBarButtonItemStylePlain) target:self action:@selector(pop)];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self collocate];
    self.title = self.userName;
    
    // 加载本地数据库聊天记录（MessageV1）
    [self loadLocalChatRecords];
    
    // 设置聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];

    self.view.backgroundColor = RGBACOLOR(248, 248, 248, 1);
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.bottomToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.bottomToolBar.moreView setDelegate:self];
    }
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomToolBar];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    // 给计算高度的cell工具 赋值
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:right];
    if (self.chatCellTool == nil) {
        self.chatCellTool = [[NSBundle mainBundle] loadNibNamed:@"ChatLeftCell" owner:nil options:nil].lastObject;
    }
    
    
}


/** 加载本地聊天记录 */
- (void)loadLocalChatRecords {
    
    // 要获取本地聊天记录使用 会话对象
    EMConversation *converstion = [[EaseMob sharedInstance].chatManager conversationForChatter:self.userName conversationType:(eConversationTypeChat)];
    
    [converstion markAllMessagesAsRead:YES];
    
    // 加载与当前好友所有聊天记录
    NSArray *ary = [converstion loadAllMessages];
    
    [self.dataAry addObjectsFromArray:ary];
    
}

#pragma mark 接收好友回复消息
-(void)didReceiveMessage:(EMMessage *)message{
    if ([message.from isEqualToString:self.userName]) {
        //1.把接收的消息添加到数据源
        [self.dataAry addObject:message];
        
        //2.刷新表格
        [self.tableView reloadData];
        
        //3.显示数据到底部
        [self scrollToBottom];
    }
}

// 懒加载聊天列表
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.bottomToolBar.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGBACOLOR(248, 248, 248, 1);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 获取消息模型 取出数据
    //1.先获取消息模型
    EMMessage *message = self.dataAry[indexPath.row];
    //    EMMessage
    
    ChatLeftCell *cell = nil;
    if ([message.from isEqualToString:self.userName]) {
        // 好友发送
        cell = [tableView dequeueReusableCellWithIdentifier:left];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"ChatLeftCell" owner:nil options:nil].firstObject;
        }
    }else {
        // 自己发送
        cell = [tableView dequeueReusableCellWithIdentifier:right];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"ChatLeftCell" owner:nil options:nil].lastObject;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.message = message;
    
    __weak typeof(self) weakSelf = self;
    cell.tapImage = ^(){
        [weakSelf tableView:tableView didSelectRowAtIndexPath:indexPath];
        
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.chatCellTool.message = self.dataAry[indexPath.row];
    return [self.chatCellTool cellForHeight];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.navigationController.navigationBar.hidden = YES;
    EMMessage *msg = self.dataAry[indexPath.row];
    EMImageMessageBody *body = msg.messageBodies[0];
    
    // 大图的服务器地址
    body.remotePath;
    // 大图的本地路径
    body.localPath;
    NSLog(@"%@", body.localPath);
    // 获取图片消息体
    if([body isKindOfClass:[EMImageMessageBody class]]){//图片消息{
        NSFileManager *manager = [NSFileManager defaultManager];
        
        // 如果本地图片存在，直接从本地显示图片
        if ([manager fileExistsAtPath:body.localPath]) {
      
            [self.view addSubview:self.cellImage];
            [self.cellImage sd_setImageWithURL:[NSURL fileURLWithPath:body.localPath] placeholderImage:nil];
            
//            [self.view addSubview:imageV];
            
        }else{
            // 如果本地图片不存，从网络加载图片
//             UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:self.cellImage];
            [self.cellImage sd_setImageWithURL:[NSURL URLWithString:body.remotePath] placeholderImage:nil];
         
//            [self.view addSubview:imageV];
        }
    }
}

// 输入框懒加载
- (DXMessageToolBar *)bottomToolBar {
    if (_bottomToolBar == nil) {
        _bottomToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _bottomToolBar.delegate = self;
        _bottomToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _bottomToolBar.frame.size.width, 80) type:ChatMoreTypeChat];
        _bottomToolBar.moreView.backgroundColor = RGBACOLOR(240, 242, 247, 1);
        _bottomToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _bottomToolBar;
}

#pragma mark - DXMessageToolBarDelegate
// 改变了输入框的位置
- (void)didChangeFrameToHeight:(CGFloat)toHeight {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:NO];
}

- (void)scrollViewToBottom:(BOOL)animated {
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}


// 发送消息(表情或文字)
- (void)didSendText:(NSString *)text {
    //消息 ＝ 消息头 + 消息体
    //    EMTextMessageBody 文本消息体
    //    EMVoiceMessageBody 录音消息体
    //    EMVideoMessageBody 视频消息体
    //    EMLocationMessageBody 位置消息体
    //    EMImageMessageBody 图片消息体
    
    //    return;
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    //创建一个文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    //1.创建一个消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.userName bodies:@[textBody]];
    
    // 2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"完成消息发送 %@",error);
    } onQueue:nil];
    
    [self.dataAry addObject:msgObj];
    [self.tableView reloadData];
    [self scrollToBottom];
    
}

-(void)scrollToBottom{
    //1.获取最后一行
    if (self.dataAry.count == 0) {
        return;
    }
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataAry.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/**按下录音按钮开始录音*/
- (void)didStartRecordingVoiceAction:(UIView *)recordView {
    if ([self canRecord]) {
        DXRecordView *tmpView = (DXRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
                                                                 completion:^(NSError *error)
         {
             if (error) {
                 NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
             }
         }];
    }
}

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}

/**手指向上滑动松开 取消录音*/
- (void)didCancelRecordingVoiceAction:(UIView *)recordView {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**松开手指完成录音*/
- (void)didFinishRecoingVoiceAction:(UIView *)recordView {
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
                                                       displayName:@"audio"];
            voice.duration = aDuration;
            [weakSelf sendAudioMessage:voice];
        }else {
            weakSelf.bottomToolBar.recordButton.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.bottomToolBar.recordButton.enabled = YES;
            });
        }
    }];
    
    
}

// 发送语音消息
-(void)sendAudioMessage:(EMChatVoice *)voice {
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    voiceBody.duration = voice.duration;
    
    // 2.构造一个消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.userName bodies:@[voiceBody]];
    //聊天的类型 单聊
    msgObj.messageType = eMessageTypeChat;
    
    // 3.发送
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送语音");
        
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"语音发送成功");
        }else{
            NSLog(@"语音发送失败");
        }
    } onQueue:nil];
    
    // 3.把消息添加到数据源，然后再刷新表格
    [self.dataAry addObject:msgObj];
    [self.tableView reloadData];
    // 4.把消息显示在顶部
    [self scrollToBottom];


}





// 相册/相机懒加载
- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}
#pragma mark - EMChatBarMoreViewDelegate
// 打开相册
- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView {
    // 隐藏键盘
    [self keyBoardHidden];
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}

//  打开相机
- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView {
    // 隐藏键盘
    [self keyBoardHidden];
    if (!SIMULATOR) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        NSURL *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
        [self sendVideoMessage:chatVideo];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
        }];
        [self sendImageMessage:orgImage];
    }
}

#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {

            wait = nil;
        }
    }
    
    return mp4Url;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendImageMessage:(UIImage *)image {
    //1.构造图片消息体
    /*
     * 第一个参数：原始大小的图片对象 1000 * 1000
     * 第二个参数: 缩略图的图片对象  120 * 120
     */
    EMChatImage *orginalChatImg = [[EMChatImage alloc] initWithUIImage:image displayName:@"图片"];
    
    EMImageMessageBody *imgBody = [[EMImageMessageBody alloc] initWithImage:orginalChatImg thumbnailImage:nil];
    
    
    //1.构造消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.userName bodies:@[imgBody]];
    msgObj.messageType = eMessageTypeChat;

    //2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送图片");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"图片发送成功 %@",error);
    } onQueue:nil];
    
    // 3.把消息添加到数据源，然后再刷新表格
    [self.dataAry addObject:msgObj];
    [self.tableView reloadData];
    // 4.把消息显示在顶部
    [self scrollToBottom];
    
}

-(void)sendVideoMessage:(EMChatVideo *)video {
    
    
}






// 点击背景隐藏
-(void)keyBoardHidden {
    [self.bottomToolBar endEditing:YES];
}

- (BOOL)requestBeforeJudgeConnect {
        struct sockaddr zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sa_len = sizeof(zeroAddress);
        zeroAddress.sa_family = AF_INET;
        SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
        SCNetworkReachabilityFlags flags;
        BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
        CFRelease(defaultRouteReachability);
        if (!didRetrieveFlags) {
            printf("Error. Count not recover network reachability flags\n");
            return NO;
        }
        BOOL isReachable = flags & kSCNetworkFlagsReachable;
        BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
        BOOL isNetworkEnable  =(isReachable && !needsConnection) ? YES : NO;
        return isNetworkEnable;
}

- (void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

@end
