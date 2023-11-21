//
//  WUAlivcAudienceViewManager.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/1.
//

#import "WUAlivcAudienceViewManager.h"
#import <MJExtension/MJExtension.h>
#import <React/RCTUIManager.h>
#import "AUIRoomLiveModel.h"
#import "AUIRoomUser.h"
#import "AUILiveManager.h"
#import "AUIRoomBaseLiveManagerAudience+Private.h"
#import "AUIRoomDeviceAuth.h"

@interface WUAlivcAudienceViewManager()
@property(nonatomic, weak) WUAlivcAudienceView *alivcView;
@end

@implementation WUAlivcAudienceViewManager
// 标记宏（必要）
RCT_EXPORT_MODULE(WUAlivcAudienceViewManager)
RCT_EXPORT_VIEW_PROPERTY(roomLiveInfo, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(onExitLive,RCTBubblingEventBlock) //结束退出直播
RCT_EXPORT_VIEW_PROPERTY(onReceivedStartLive,RCTBubblingEventBlock)//开始直播拉流回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedStopLive,RCTBubblingEventBlock);//结束直播拉流回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedComment,RCTBubblingEventBlock);//收到互动消息回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedMuteAll,RCTBubblingEventBlock);//收到禁言消息回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedLike,RCTBubblingEventBlock);//收到点赞消息回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedPV,RCTBubblingEventBlock);//直播间观看数更新回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedNoticeUpdate,RCTBubblingEventBlock);//直播间公告更新回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedResponseApplyLinkMic,RCTBubblingEventBlock);//收到请求连麦申请结果回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedJoinLinkMic,RCTBubblingEventBlock);//收到连麦回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedLeaveLinkMic,RCTBubblingEventBlock);//收到被主播结束连麦回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedOpenMic,RCTBubblingEventBlock);//收到开关麦克风回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedOpenCamera,RCTBubblingEventBlock);//收到开关摄像头回调
RCT_EXPORT_VIEW_PROPERTY(onNotifyApplyNotResponse,RCTBubblingEventBlock);//主播未响应连麦申请
RCT_EXPORT_VIEW_PROPERTY(onReceivedDisagreeToLinkMic,RCTBubblingEventBlock);//主播拒绝了您的连麦申请
RCT_EXPORT_VIEW_PROPERTY(onReceivedAgreeToLinkMic,RCTBubblingEventBlock);//连麦申请通过，是否开始连麦？
RCT_EXPORT_VIEW_PROPERTY(onPlayErrorBlock,RCTBubblingEventBlock);//直播中断，您可尝试再次拉流
RCT_EXPORT_VIEW_PROPERTY(onApplyBlock,RCTBubblingEventBlock);//员工申请连麦
RCT_EXPORT_VIEW_PROPERTY(onCancelApplyLinkMic,RCTBubblingEventBlock);//员工取消连麦
RCT_EXPORT_VIEW_PROPERTY(onLeaveLinkMic,RCTBubblingEventBlock);//员工结束连麦
RCT_EXPORT_VIEW_PROPERTY(onSwitchCamera,RCTBubblingEventBlock);//员工员工切换摄像头
RCT_EXPORT_VIEW_PROPERTY(onSwitchVideo,RCTBubblingEventBlock);//员工开关自己的麦克风
RCT_EXPORT_VIEW_PROPERTY(onSwitchAudio,RCTBubblingEventBlock);//员工开关自己的摄像头

- (UIView *)view
{
  WUAlivcAudienceView *view = [[WUAlivcAudienceView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  return view;
}


/// 拿到当前View
- (WUAlivcAudienceView *) getViewWithTag:(NSNumber *)tag {
  NSLog(@"%@", [NSThread currentThread]);
  
  UIView *view = [self.bridge.uiManager viewForReactTag:tag];
  return [view isKindOfClass:[WUAlivcAudienceView class]] ? (WUAlivcAudienceView *)view : nil;
}


///MARK: 创建直播管理
RCT_EXPORT_METHOD(textMethodFunc:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic withJoinList:(NSArray *)joins resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  if (dic ==nil) {
    reject(@"401",@"进入直播间失败，请稍后重试~",nil);
    //      [AVAlertController showWithTitle:nil message:@"进入直播间失败，请稍后重试~" needCancel:NO onCompleted:^(BOOL isCanced) {
    //        //                [weakSelf.navigationController popViewControllerAnimated:YES];
    //      }];
  }else{
    resolve(@(1));
  }
}

RCT_EXPORT_METHOD(setupConfig:(nonnull NSNumber *)reactTag) {
  WUAlivcAudienceView *anchorView = [self getViewWithTag:reactTag];
  self.alivcView = anchorView;
}

///MARK: 创建直播管理
RCT_EXPORT_METHOD(createLiveManager:(NSDictionary *)dic withJoinList:(NSArray *)joins resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AUIRoomLiveInfoModel *liveInfoModel = [AUIRoomLiveInfoModel mj_objectWithKeyValues:dic];
  NSMutableArray *joinList = [AUIRoomLiveLinkMicJoinInfoModel mj_objectArrayWithKeyValuesArray:joins];
  if (liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
    //互动直播
    self.alivcView.liveManager = [[AUIRoomInteractionLiveManagerAudience alloc] initWithModel:liveInfoModel withJoinList:joinList];
  }
  else {
    self.alivcView.liveManager = [[AUIRoomBaseLiveManagerAudience alloc] initWithModel:liveInfoModel];
  }
  [self.alivcView setupBackground];
  [self.alivcView setupLiveManager];
  //    [self setupRoomUI];
  [self.alivcView.liveManager enterRoom:^(BOOL success) {
    if (!success) {
      reject(@"401",@"进入直播间失败，请稍后重试~",nil);
      //      [AVAlertController showWithTitle:nil message:@"进入直播间失败，请稍后重试~" needCancel:NO onCompleted:^(BOOL isCanced) {
      //        //                [weakSelf.navigationController popViewControllerAnimated:YES];
      //      }];
    }else{
      resolve(@(success));
    }
  }];
}

///MARK: 直播中断，尝试再次拉流
RCT_EXPORT_METHOD(retryRoomLiveCdnPlay) {
  [self.alivcView.liveManager retryRoomLivePlay];
}


/// MARK: 确认结束后离开直播
RCT_EXPORT_METHOD(onLeaveRoom:(RCTResponseSenderBlock)callback) {
  __weak typeof(self) weakSelf = self;
  [self.alivcView.liveManager leaveRoom:^(BOOL result) {
    // 清理操作
    [weakSelf.alivcView releaseResource];
    callback(@[@(1)]);
  }];
  
}

/// MARK: 发送互动消息
RCT_EXPORT_METHOD(sendComment:(NSString *)comment){
  [self.alivcView.liveManager sendComment:comment completed:nil];
}

///MARK: 检查麦克风摄像头权限
RCT_EXPORT_METHOD(deviceAuth:(RCTResponseSenderBlock)callback) {
  __weak typeof(self) weakSelf = self;
  
  BOOL ret = NO;
  ret = [AUIRoomDeviceAuth checkCameraAuth:^(BOOL auth) {
    if (auth) {
      [weakSelf applyLinkMicAction];
    }
  }];
  if (!ret) {
    return;
  }
  
  ret = [AUIRoomDeviceAuth checkMicAuth:^(BOOL auth) {
    if (auth) {
      [weakSelf applyLinkMicAction];
    }
  }];
  if (!ret) {
    return;
  }
  //授权通过，执行弹窗确认
  callback(@[@(ret)]);
}

- (void)applyLinkMicAction {
  __weak typeof(self) weakSelf = self;
  [[self.alivcView linkMicManager] applyLinkMic:^(BOOL success) {
    //    completionBlock(success);
    if (weakSelf.alivcView.onApplyBlock) {
      weakSelf.alivcView.onApplyBlock(@{@"code":@(success ? 1 : 0),@"message":success ? @"已发送连麦申请，等待主播操作" : @"申请连麦失败！"});
    }
  }];
}

///MARK: 员工发送连麦申请
RCT_EXPORT_METHOD(applyLinkMic:(RCTResponseSenderBlock)callback) {
  [self applyLinkMicAction];
}

///MARK: 员工取消连麦申请
RCT_EXPORT_METHOD(cancelApplyLinkMicAction) {
  __weak typeof(self) weakSelf = self;
  [[self.alivcView linkMicManager] cancelApplyLinkMic:^(BOOL success) {
    if (weakSelf.alivcView.onCancelApplyLinkMic) {
      weakSelf.alivcView.onCancelApplyLinkMic(@{@"code":@(success ? 1 : 0), @"message": success ? @"取消连麦成功" : @"取消连麦失败"});
      //      weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
      //      [AVToastView show:@"取消连麦成功" view:weakSelf.view position:AVToastViewPositionMid];
    }
  }];
  //  [AVAlertController showWithTitle:nil message:@"是否取消连麦？" needCancel:YES onCompleted:^(BOOL isCanced) {
  //    if (isCanced) {
  //      return;
  //    }
  //    [[weakSelf linkMicManager] cancelApplyLinkMic:^(BOOL success) {
  //      if (success) {
  //        weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
  //        [AVToastView show:@"取消连麦成功" view:weakSelf.view position:AVToastViewPositionMid];
  //      }
  //    }];
  //  }];
}

///MARK: 员工结束连麦申请
RCT_EXPORT_METHOD(leaveLinkMic) {
  __weak typeof(self) weakSelf = self;
  [[self.alivcView linkMicManager] leaveLinkMic:^(BOOL success) {
    if (self.alivcView.onLeaveLinkMic) {
      weakSelf.alivcView.onLeaveLinkMic(@{@"code":@(success ? 1 : 0), @"message": success ? @"连麦已结束" : @"连麦结束失败"});
    }
    //    if (success) {
    //      weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
    //      [AVToastView show:@"连麦已结束" view:weakSelf.view position:AVToastViewPositionMid];
    //    }
  }];
  
  //  [AVAlertController showWithTitle:nil message:@"是否结束与主播连麦？" needCancel:YES onCompleted:^(BOOL isCanced) {
  //    if (isCanced) {
  //      return;
  //    }
  //    [[weakSelf linkMicManager] leaveLinkMic:^(BOOL success) {
  //      if (success) {
  //        weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
  //        [AVToastView show:@"连麦已结束" view:weakSelf.view position:AVToastViewPositionMid];
  //      }
  //    }];
  //  }];
}
///MARK: 员工切换摄像头
RCT_EXPORT_METHOD(switchCamera) {
  if (![self.alivcView linkMicManager].isLiving) {
    return;
  }
  [[self.alivcView linkMicManager] switchLivePusherCamera];
  
}

///MARK: 员工开关自己的麦克风
RCT_EXPORT_METHOD(switchVideo:(BOOL)isOn) {
  if (![self.alivcView linkMicManager].isLiving) {
    return;
  }
  
  [[self.alivcView linkMicManager] openLivePusherCamera:isOn];
  BOOL cameraOpened = [self.alivcView linkMicManager].isCameraOpened;
  //  self.linkMicButton.videoOff = !cameraOpened;
  if (self.alivcView.onSwitchVideo) {
    self.alivcView.onSwitchVideo(@{@"cameraOpened":@(cameraOpened)});
  }
}

///MARK: 员工开关自己的麦克风
RCT_EXPORT_METHOD(switchAudio:(BOOL)isOn) {
  if (![self.alivcView linkMicManager].isLiving) {
    return;
  }
  
  [[self.alivcView linkMicManager] openLivePusherMic:isOn];
  BOOL micOpened = [self.alivcView linkMicManager].isMicOpened;
  //  self.linkMicButton.audioOff = !micOpened;
  if (self.alivcView.onSwitchAudio) {
    self.alivcView.onSwitchAudio(@{@"micOpened":@(micOpened)});
  }
}

/// 解决释放问题
/// @param reactTag reactTag description
RCT_EXPORT_METHOD(invalidate:(nonnull NSNumber *)reactTag) {
  __weak typeof(self) weakSelf = self;
  RCTExecuteOnMainQueue(^{
    NSDictionary *viewRegistry = [weakSelf.bridge.uiManager valueForKey:@"viewRegistry"];
    NSArray *alivcViews = [[viewRegistry allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      return [evaluatedObject isKindOfClass:NSClassFromString(@"WUAlivcAudienceView")];
    }]];
    for (id<RCTInvalidating> alivcView in alivcViews) {
      [alivcView invalidate];
    }
  });
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (void)dealloc {
  
}
@end
