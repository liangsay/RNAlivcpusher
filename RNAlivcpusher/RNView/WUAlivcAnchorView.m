//
//  WUAlivcAnchorView.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/1.
//

#import "WUAlivcAnchorView.h"
#import "AUILiveRoomAnchorViewController.h"
#import "AUIRoomLiveModel.h"
#import "AUIFoundation.h"
#import "AUIRoomBaseLiveManagerAnchor.h"
#import "AUILiveRoomLivingContainerView.h"
#import "AUILiveRoomAnchorPrestartView.h"
#import "AUIRoomInteractionLiveManagerAnchor.h"
#import "RNAlivcpusher.h"
#import <MJExtension/MJExtension.h>
#import "AUIRoomUser.h"


typedef NS_ENUM(NSInteger, AUILiveRoomPushStatus)
{
  AUILiveRoomPushStatusFluent = 0,
  AUILiveRoomPushStatusStuttering,
  AUILiveRoomPushStatusBrokenOff,
};


@interface WUAlivcAnchorView()
@property (strong, nonatomic) AUIRoomDisplayLayoutView *liveDisplayView;
@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomAnchorPrestartView *livePrestartView;
@end

@implementation WUAlivcAnchorView



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
/**
 *  当事件导出用到 sendInputEventWithName 的方式时，会用到
 */
- (NSArray *) customDirectEventTypes {
  return @[@"onClickTest",@""];
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  return self;
}


- (AUIRoomDisplayLayoutView *)liveDisplayView {
  if (!_liveDisplayView) {
    _liveDisplayView = [[AUIRoomDisplayLayoutView alloc] initWithFrame:self.bounds];
    _liveDisplayView.resolution = CGSizeMake(720, 1280);
    [self addSubview:_liveDisplayView];
  }
  return _liveDisplayView;
}

- (AUILiveRoomLivingContainerView *)livingContainerView {
  if (!_livingContainerView) {
    _livingContainerView = [[AUILiveRoomLivingContainerView alloc] initWithFrame:self.bounds];
    [self addSubview:_livingContainerView];
  }
  return _livingContainerView;
}


- (AUILiveRoomAnchorPrestartView *)livePrestartView {
  if (!_livePrestartView) {
    _livePrestartView = [[AUILiveRoomAnchorPrestartView alloc] initWithFrame:self.bounds withModel:self.liveManager.liveInfoModel];
    _livePrestartView.hidden = YES;
    [self insertSubview:_livePrestartView aboveSubview:self.livingContainerView];
    
    __weak typeof(self) weakSelf = self;
    _livePrestartView.onBeautyBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
      [weakSelf.liveManager openBeautyPanel];
    };
    _livePrestartView.onSwitchCameraBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
      [weakSelf.liveManager switchLivePusherCamera];
    };
    _livePrestartView.onWillStartLiveBlock = ^BOOL(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
      //            weakSelf.exitButton.hidden = YES;
      return YES;
    };
    _livePrestartView.onStartLiveBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
      //            weakSelf.exitButton.hidden = NO;
      //            [weakSelf startLive];
    };
  }
  return _livePrestartView;
}

- (void)setupBackground {
  self.backgroundColor = AUIFoundationColor(@"bg_weak");
  CAGradientLayer *bgLayer = [CAGradientLayer layer];
  bgLayer.frame = self.bounds;
  bgLayer.colors = @[(id)[UIColor colorWithRed:0x39 / 255.0 green:0x1a / 255.0 blue:0x0f / 255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:0x1e / 255.0 green:0x23 / 255.0 blue:0x26 / 255.0 alpha:1.0].CGColor];
  bgLayer.startPoint = CGPointMake(0, 0.5);
  bgLayer.endPoint = CGPointMake(1, 0.5);
  [self.layer addSublayer:bgLayer];
}


///MARK: 处理连麦数据结构
- (NSDictionary *)getLinkMicInfo: (AUIRoomInteractionLiveManagerAnchor *)sender {
  NSArray *currentApplyList = [NSMutableArray arrayWithArray:sender.currentApplyList];//申请连麦列表
  NSArray *currentJoiningList = [NSMutableArray arrayWithArray:sender.currentJoiningList];// 正在上麦列表
  NSMutableArray *currentJoinList = [NSMutableArray arrayWithArray:sender.currentJoinList];// 当前上麦列表
  
  NSMutableArray *applyList = [NSMutableArray array];
  NSMutableArray *joiningList = [NSMutableArray array];
  NSMutableArray *joinList = [NSMutableArray array];
  //申请连麦列表
  if (currentApplyList != nil && [currentApplyList isKindOfClass:[NSArray class]]) {
    for (AUIRoomUser *applyUser in currentApplyList) {
      NSDictionary *dic = [applyUser mj_JSONObject];
      [applyList addObject:dic];
    }
  }
  // 正在上麦列表
  if (currentJoiningList != nil && [currentJoiningList isKindOfClass:[NSArray class]]) {
    for (AUIRoomUser *joiningUser in currentJoiningList) {
      NSDictionary *dic = [joiningUser mj_JSONObject];
      [joiningList addObject:dic];
    }
  }
  // 当前上麦列表
  if (currentJoinList != nil && [currentJoinList isKindOfClass:[NSArray class]]) {
    for (AUIRoomLiveRtcPlayer *joinUser in currentJoinList) {
      NSDictionary *dic = [joinUser.joinInfo mj_JSONObject];
      [joinList addObject:dic];
    }
  }
  return @{@"currentApplyList":applyList,@"currentJoiningList":joiningList,@"currentJoinList":joinList};
}

- (void)setupLiveManager {
  
  __weak typeof(self) weakSelf = self;
  
  self.liveManager.displayLayoutView = self.liveDisplayView;
  self.liveManager.onReceivedComment = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull content) {
    if (content.length > 0 && weakSelf.onReceivedComment) {
      NSString *senderNick = sender.nickName;
      NSString *senderId = sender.userId;
      NSString *senderContent = content;
      NSString *senderAvatar = sender.avatar;
      weakSelf.onReceivedComment(@{@"senderNick":senderNick,@"senderId":senderId,@"senderContent":senderContent,@"senderAvatar":senderAvatar,@"msgType":@(1)});
    }
  };
  
  self.liveManager.onReceivedMuteAll = ^(BOOL isMuteAll) {
    //        weakSelf.bottomView.commentTextField.commentState = isMuteAll ?  AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
    if(weakSelf.onReceivedMuteAll) {
      weakSelf.onReceivedMuteAll(@{@"commentState":@(isMuteAll)});
    }
  };
  
  self.liveManager.onReceivedLike = ^(AUIRoomUser * _Nonnull sender, NSInteger likeCount) {
    NSLog(@"收到来自观众（%@）的点赞，总数：%zd", sender.nickName ?: sender.userId, likeCount);
    if (weakSelf.onReceivedLike) {
      NSDictionary *dic = [sender mj_JSONObject];
      NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
      mutableDic[@"code"] = @"onReceivedLike";
      mutableDic[@"likeCount"] = @(likeCount);
      weakSelf.onReceivedLike(mutableDic);
    }
  };
  
  self.liveManager.onReceivedPV = ^(NSInteger pv) {
    //        [weakSelf.membersButton updateMemberCount:pv];
    if (weakSelf.onReceivedPV) {
      weakSelf.onReceivedPV(@{@"pv":@(pv)});
    }
  };
  
  self.liveManager.onReceivedGift = ^(AUIRoomUser * _Nonnull sender, AUIRoomGiftModel * _Nonnull gift) {
    // 处理接收到的礼物
  };
  self.liveManager.onReceivedCustomLike = ^(AUIRoomUser * _Nonnull sender, AUIRoomCustomLikeModel * _Nonnull like) {
    // 处理接收到的点赞
  };
  //  连麦事件处理
  [self linkMicManager].applyListChangedBlock = ^(AUIRoomInteractionLiveManagerAnchor * _Nonnull sender) {
    //      [weakSelf.bottomView updateLinkMicNumber:sender.currentApplyList.count];
    if (weakSelf.onApplyListChangedBlock) {
      weakSelf.onApplyListChangedBlock([self getLinkMicInfo:sender]);
    }
  };
  
  [self linkMicManager].onReceivedMicOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
    //      [weakSelf openLinkMicPanel:NO needJump:NO onApplyTab:NO];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
    [dic setValuesForKeysWithDictionary:@{@"openLinkMicPanel":@(NO),@"needJump":@(NO),@"onApplyTab":@(NO)}];
    if (weakSelf.onReceivedMicOpened) {
      weakSelf.onReceivedMicOpened(dic);
    }
  };
  
  [self linkMicManager].onReceivedCameraOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
    //      [weakSelf openLinkMicPanel:NO needJump:NO onApplyTab:NO];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
    [dic setValuesForKeysWithDictionary:@{@"openLinkMicPanel":@(NO),@"needJump":@(NO),@"onApplyTab":@(NO)}];
    if (weakSelf.onReceivedCameraOpened) {
      weakSelf.onReceivedCameraOpened(dic);
    }
  };
  
  [self linkMicManager].onReceivedApplyLinkMic = ^(AUIRoomUser * _Nonnull sender) {
    //      [weakSelf openLinkMicPanel:YES needJump:YES onApplyTab:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
    [dic setValuesForKeysWithDictionary:@{@"openLinkMicPanel":@(YES),@"needJump":@(YES),@"onApplyTab":@(YES)}];
    if (weakSelf.onReceivedApplyLinkMic) {
      weakSelf.onReceivedApplyLinkMic(dic);
    }
  };
  
  [self linkMicManager].onReceivedCancelApplyLinkMic = ^(AUIRoomUser * _Nonnull sender) {
    //      [weakSelf.linkMicPanel reload];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
    dic[@"isData"] = @(YES);
    if (weakSelf.onReceivedCancelApplyLinkMic) {
      weakSelf.onReceivedCancelApplyLinkMic(dic);
    }
  };
  
  [self linkMicManager].onReceivedJoinLinkMic = ^(AUIRoomUser * _Nonnull sender) {
    //      [weakSelf.linkMicPanel reload];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
    dic[@"isData"] = @(YES);
    if (weakSelf.onReceivedJoinLinkMic) {
      weakSelf.onReceivedJoinLinkMic(dic);
    }
  };
  
  [self linkMicManager].onReceivedLeaveLinkMic = ^(NSString * _Nonnull userId) {
    //      [weakSelf.linkMicPanel reload];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
    dic[@"isData"] = @(YES);
    if (weakSelf.onReceivedLeaveLinkMic) {
      weakSelf.onReceivedLeaveLinkMic(dic);
    }
    //    [RNAlivcpusher sendEvent:kRNAlivc_onReceived_ApplyLinkMic params:dic];
  };
  //直播部分网络状态
  self.liveManager.onStartedBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusFluent)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onRestartBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusFluent)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusFluent)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onConnectionPoorBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusStuttering;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusStuttering)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusStuttering)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onConnectionLostBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onConnectionRecoveryBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusFluent)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusFluent)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onConnectErrorBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onReconnectStartBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onReconnectSuccessBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusFluent)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusFluent)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onReconnectErrorBlock = ^{
    //weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    //    [RNAlivcpusher sendEvent:kRNAlivc_Pusher_Push_Status params:@{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)}];
    NSDictionary *dic = @{@"pushStatus":@(AUILiveRoomPushStatusBrokenOff)};
    if (weakSelf.onStartedBlock) {
      weakSelf.onStartedBlock(dic);
    }
  };
  self.liveManager.onSetupBeautyBlock = self.onSetupBeautyBlock;
  
  self.liveManager.roomV = self;
  [self.liveManager setupLivePusher];
}

#pragma mark - link mic
- (AUIRoomInteractionLiveManagerAnchor *__nullable)linkMicManager {
  if ([self.liveManager isKindOfClass:AUIRoomInteractionLiveManagerAnchor.class]) {
    return self.liveManager;
  }
  return nil;
}

// 导出枚举常量，给js定义样式用

- (NSDictionary *)constantsToExport

{
  
  return @{
    @"AUILiveRoomPushStatus": @{
      @"fluent": @(AUILiveRoomPushStatusFluent),
      @"stuttering": @(AUILiveRoomPushStatusStuttering),
      @"brokenOff":@(AUILiveRoomPushStatusBrokenOff)
    }
  };
  
}

- (void)releaseResource {
  [self.liveManager.displayLayoutView removeFromSuperview];
  [self.livingContainerView removeFromSuperview];
  [self.livePrestartView removeFromSuperview];
  [self.liveDisplayView removeFromSuperview];
  self.liveManager = nil;
  self.linkMicManager = nil;
  [self removeFromSuperview];
}

- (void)dealloc {
  
}

@end
