//
//  WUAlivcAudienceView.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/1.
//

#import "WUAlivcAudienceView.h"
#import "AUILiveRoomAnchorViewController.h"
#import "AUIRoomLiveModel.h"
#import "AUIFoundation.h"
#import "AUIRoomBaseLiveManagerAnchor.h"
#import "AUILiveRoomLivingContainerView.h"
#import "AUILiveRoomAnchorPrestartView.h"
#import "AUIRoomInteractionLiveManagerAnchor.h"
#import <MJExtension/MJExtension.h>
#import "AUIRoomUser.h"
#import "AUIRoomAccount.h"


typedef NS_ENUM(NSInteger, AUILiveRoomPushStatus)
{
  AUILiveRoomPushStatusFluent = 0,
  AUILiveRoomPushStatusStuttering,
  AUILiveRoomPushStatusBrokenOff,
};


@interface WUAlivcAudienceView()
@property (strong, nonatomic) AUIRoomDisplayLayoutView *liveDisplayView;
@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomAnchorPrestartView *livePrestartView;
@end

@implementation WUAlivcAudienceView



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
  
  self.liveManager.onReceivedStartLive = ^{
    //      [weakSelf showLivingUI];
  };
  self.liveManager.onReceivedStopLive = ^{
    //      [weakSelf showFinishUI];
  };
  
  self.liveManager.onReceivedComment = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull content) {
    if (content.length == 0) {
      return;
    }
    if (content.length > 0 && weakSelf.onReceivedComment) {
      NSString *senderNick = sender.nickName;
      NSString *senderId = sender.userId;
      NSString *senderContent = content;
      NSString *senderAvatar = sender.avatar;
      weakSelf.onReceivedComment(@{@"senderNick":senderNick,@"senderId":senderId,@"senderContent":senderContent,@"senderAvatar":senderAvatar,@"msgType":@(1)});
    }
  };
  
  self.liveManager.onReceivedMuteAll = ^(BOOL isMuteAll) {
    //      weakSelf.bottomView.commentTextField.commentState = isMuteAll ?  AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
    if(weakSelf.onReceivedMuteAll) {
      weakSelf.onReceivedMuteAll(@{@"commentState":@(isMuteAll)});
    }
  };
  
  self.liveManager.onReceivedLike = ^(AUIRoomUser * _Nonnull sender, NSInteger likeCount) {
    if (weakSelf.onReceivedLike) {
      NSDictionary *dic = [sender mj_JSONObject];
      NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
      mutableDic[@"code"] = @"onReceivedLike";
      mutableDic[@"likeCount"] = @(likeCount);
      weakSelf.onReceivedLike(mutableDic);
    }
  };
  
  self.liveManager.onReceivedPV = ^(NSInteger pv) {
    //      [weakSelf.membersButton updateMemberCount:pv];
    if (weakSelf.onReceivedPV) {
      weakSelf.onReceivedPV(@{@"pv":@(pv)});
    }
  };
  
  self.liveManager.onReceivedNoticeUpdate = ^(NSString * _Nonnull notice) {
    //      weakSelf.noticeButton.noticeContent = notice;
    //      [AVToastView show:@"公告已更新" view:weakSelf.view position:AVToastViewPositionMid];
    if (weakSelf.onReceivedNoticeUpdate) {
      weakSelf.onReceivedNoticeUpdate(@{@"notice":notice});
    }
  };
  
  [self linkMicManager].onReceivedResponseApplyLinkMic = ^(AUIRoomUser * _Nonnull sender, BOOL agree, NSString *pullUrl) {
    //连麦申请处理
    [weakSelf receivedApplyResult:sender.userId agree:agree];
  };
  
  [self linkMicManager].onReceivedJoinLinkMic = ^(AUIRoomUser * _Nonnull sender) {
    if (weakSelf.onReceivedJoinLinkMic) {
      NSDictionary *dic = [sender mj_JSONObject];
      weakSelf.onReceivedJoinLinkMic(dic);
    }
  };
  
  [self linkMicManager].onReceivedLeaveLinkMic = ^(NSString * _Nonnull userId) {
    if (weakSelf.onReceivedLeaveLinkMic && [userId isEqual:AUIRoomAccount.me.userId]) {
      weakSelf.onReceivedLeaveLinkMic(@{@"userId":userId,@"state":@(0),@"message":@"您已被主播下麦"});
    }
//    if ([userId isEqualToString:AUIRoomAccount.me.userId]) {
//      weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
//      [AVToastView show:@"您已被主播下麦" view:weakSelf.view position:AVToastViewPositionMid];
//    }
  };
  
  [self linkMicManager].onReceivedOpenMic = ^(AUIRoomUser * _Nonnull sender, BOOL needOpen) {
//    [weakSelf switchAudio:needOpen];
    if (![self linkMicManager].isLiving) {
        return;
    }
    
    [[self linkMicManager] openLivePusherMic:needOpen];
    BOOL micOpened = [self linkMicManager].isMicOpened;
    if (weakSelf.onReceivedOpenMic) {
      weakSelf.onReceivedOpenMic(@{@"micOpened":@(micOpened),@"user":[sender mj_JSONObject]});
    }
//    self.linkMicButton.audioOff = !micOpened;
  };
  [self linkMicManager].onReceivedOpenCamera = ^(AUIRoomUser * _Nonnull sender, BOOL needOpen) {
//    [weakSelf switchVideo:needOpen];
    if (![self linkMicManager].isLiving) {
        return;
    }

    [[self linkMicManager] openLivePusherCamera:needOpen];
    BOOL cameraOpened = [self linkMicManager].isCameraOpened;
//    self.linkMicButton.videoOff = !cameraOpened;
    if (weakSelf.onReceivedOpenCamera) {
      weakSelf.onReceivedOpenCamera(@{@"cameraOpened":@(cameraOpened),@"user":[sender mj_JSONObject]});
    }
  };
  
  [self linkMicManager].onNotifyApplyNotResponse = ^(AUIRoomInteractionLiveManagerAudience * _Nonnull sender) {
//    [AVToastView show:@"主播未响应" view:weakSelf.view position:AVToastViewPositionMid];
    if (weakSelf.onNotifyApplyNotResponse) {
      weakSelf.onNotifyApplyNotResponse(@{@"state":@(0),@"message":@"主播未响应"});
    }
  };
  //  self.liveManager.roomVC = self;
  [self.liveManager setupPullPlayer:NO];
  
  [[self liveManager] onPlayErrorBlock:^(NSString * _Nonnull result) {
    if (weakSelf.onPlayErrorBlock) {
      weakSelf.onPlayErrorBlock(@{@"state":@(501),@"message":@"直播中断，您可尝试再次拉流"});
    }
  }];
}

/**
 RN处理完交互调用该方法进行连麦
 */
- (void)receivedAgreeToLinkMic:(NSString *)userId isCanced:(BOOL)isCanced {
  __weak typeof(self) weakSelf = self;
  [[self linkMicManager] receivedAgreeToLinkMic:userId willGiveUp:isCanced completed:^(BOOL success, BOOL giveUp, NSString *message) {
      if (giveUp && weakSelf.onReceivedDisagreeToLinkMic) {
//          weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
        weakSelf.onReceivedDisagreeToLinkMic(@{@"state":@(0), @"message":@"取消连麦申请"});
          return;
      }
      if (success && weakSelf.onReceivedDisagreeToLinkMic) {
//          weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateJoin;
//          weakSelf.linkMicButton.audioOff = ![weakSelf linkMicManager].isMicOpened;
//          weakSelf.linkMicButton.videoOff = ![weakSelf linkMicManager].isCameraOpened;
//          [AVToastView show:@"连麦成功" view:weakSelf.view position:AVToastViewPositionMid];
        weakSelf.onReceivedDisagreeToLinkMic(@{@"state":@(1), @"message":@"连麦成功"});
      }
      else {
//          weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
        if (weakSelf.onReceivedDisagreeToLinkMic) {
          weakSelf.onReceivedDisagreeToLinkMic(@{@"state":@(0), @"message":@"连麦失败"});
        }
//          [AVToastView show:message ?: @"连麦失败" view:weakSelf.view position:AVToastViewPositionMid];
      }
  }];
}

- (void)receivedApplyResult:(NSString *)uid agree:(BOOL)agree {
    __weak typeof(self) weakSelf = self;
    
    if (![self linkMicManager].isApplyingLinkMic) {
        return;
    }
    
    if (!agree) {
        [[self linkMicManager] receivedDisagreeToLinkMic:uid completed:^(BOOL success) {
            if (success && weakSelf.onReceivedDisagreeToLinkMic) {
              weakSelf.onReceivedDisagreeToLinkMic(@{@"state":@(0), @"message":@"主播拒绝了您的连麦申请"});
//                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
//                [AVToastView show:@"主播拒绝了您的连麦申请" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
        return;
    }
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getLinkMicInfo:[self linkMicManager]]];
  [dic setValuesForKeysWithDictionary:@{@"uid":uid,@"agree":@(agree)}];
  if (weakSelf.onReceivedResponseApplyLinkMic) {
      weakSelf.onReceivedResponseApplyLinkMic(dic);
  }
    /**
     [AVAlertController showWithTitle:nil message:@"连麦申请通过，是否开始连麦？" needCancel:YES onCompleted:^(BOOL isCanced) {
         [[weakSelf linkMicManager] receivedAgreeToLinkMic:uid willGiveUp:isCanced completed:^(BOOL success, BOOL giveUp, NSString *message) {
             if (giveUp) {
                 weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                 return;
             }
             if (success) {
                 weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateJoin;
                 weakSelf.linkMicButton.audioOff = ![weakSelf linkMicManager].isMicOpened;
                 weakSelf.linkMicButton.videoOff = ![weakSelf linkMicManager].isCameraOpened;
                 [AVToastView show:@"连麦成功" view:weakSelf.view position:AVToastViewPositionMid];
             }
             else {
                 weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                 [AVToastView show:message ?: @"连麦失败" view:weakSelf.view position:AVToastViewPositionMid];
             }
         }];
     }];
     */
}


#pragma mark - link mic

- (AUIRoomInteractionLiveManagerAudience *__nullable)linkMicManager {
  if ([self.liveManager isKindOfClass:AUIRoomInteractionLiveManagerAudience.class]) {
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


//- (void)setRoomLiveInfo:(NSDictionary *)dic {
////  AUIRoomLiveInfoModel *model;
////  if (dic && [dic isKindOfClass:NSDictionary.class]) {
////      model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:dic];
////    AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithModel:model withJoinList:nil];
////    vc.view.frame = self.bounds;
////    [self insertSubview:vc.view aboveSubview:self];
////  }
////
//
//}


@end
