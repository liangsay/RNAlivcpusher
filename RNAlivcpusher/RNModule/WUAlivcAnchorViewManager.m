//
//  WUAlivcAnchorViewManager.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/1.
//

#import "WUAlivcAnchorViewManager.h"
#import <MJExtension/MJExtension.h>
#import <React/RCTUIManager.h>
#import "AUIRoomLiveModel.h"
#import "AUIRoomUser.h"
#import "AUILiveManager.h"
#import "AUIRoomSDKHeader.h"

@interface WUAlivcAnchorViewManager()
@property(nonatomic, weak) WUAlivcAnchorView *alivcView;
@property (nonatomic, strong) QueenEngine *beautyEngine;
@property (nonatomic, assign) BOOL isEnableBeauty; //是否开启美颜
@end

@implementation WUAlivcAnchorViewManager
// 标记宏（必要）
RCT_EXPORT_MODULE(WUAlivcAnchorViewManager)
RCT_EXPORT_VIEW_PROPERTY(roomLiveInfo, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(onExitLive,RCTBubblingEventBlock) //结束退出直播
RCT_EXPORT_VIEW_PROPERTY(onReceivedPV,RCTBubblingEventBlock)//直播间观看数更新回调
RCT_EXPORT_VIEW_PROPERTY(onReceivedLike,RCTBubblingEventBlock) //观众点赞数
RCT_EXPORT_VIEW_PROPERTY(onLinkMicAgreeBtnClick,RCTBubblingEventBlock) //同意连麦
RCT_EXPORT_VIEW_PROPERTY(onLinkMicRejectBtnClick,RCTBubblingEventBlock) //拒绝连麦
RCT_EXPORT_VIEW_PROPERTY(onLinkMicLeaveBtnClick,RCTBubblingEventBlock) //离开连麦（下麦）
RCT_EXPORT_VIEW_PROPERTY(onLinkMicMicBtnClick,RCTBubblingEventBlock) //开关语音
RCT_EXPORT_VIEW_PROPERTY(onLinkMicCameraBtnClick,RCTBubblingEventBlock) //开关摄像头
RCT_EXPORT_VIEW_PROPERTY(onReceivedMuteAll,RCTBubblingEventBlock) //全员禁言
RCT_EXPORT_VIEW_PROPERTY(onReceivedComment,RCTBubblingEventBlock) //收到评论内容
RCT_EXPORT_VIEW_PROPERTY(onApplyListChangedBlock,RCTBubblingEventBlock) //连麦事件
RCT_EXPORT_VIEW_PROPERTY(onReceivedMicOpened,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板
RCT_EXPORT_VIEW_PROPERTY(onReceivedCameraOpened,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板
RCT_EXPORT_VIEW_PROPERTY(onReceivedApplyLinkMic,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板
RCT_EXPORT_VIEW_PROPERTY(onReceivedCancelApplyLinkMic,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板
RCT_EXPORT_VIEW_PROPERTY(onReceivedJoinLinkMic,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板
RCT_EXPORT_VIEW_PROPERTY(onReceivedLeaveLinkMic,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板
RCT_EXPORT_VIEW_PROPERTY(onStartedBlock,RCTBubblingEventBlock) ////主播端有连麦进来则通知打开连麦面板

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}


- (UIView *)view
{
  WUAlivcAnchorView *view = [[WUAlivcAnchorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  return view;
}

/// 拿到当前View
- (WUAlivcAnchorView *) getViewWithTag:(NSNumber *)tag {
  NSLog(@"%@", [NSThread currentThread]);
  
  UIView *view = [self.bridge.uiManager viewForReactTag:tag];
  return [view isKindOfClass:[WUAlivcAnchorView class]] ? (WUAlivcAnchorView *)view : nil;
}


RCT_EXPORT_METHOD(setupConfig:(nonnull NSNumber *)reactTag) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  self.alivcView = anchorView;
  
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

///MARK: 创建直播管理
RCT_EXPORT_METHOD(createLiveManager:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic withJoinList:(NSArray *)joins resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  __weak typeof(self) weakSelf = self;
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  AUIRoomLiveInfoModel *liveInfoModel = [AUIRoomLiveInfoModel mj_objectWithKeyValues:dic];
  NSMutableArray *joinList = [AUIRoomLiveLinkMicJoinInfoModel mj_objectArrayWithKeyValuesArray:joins];
  if (liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
    //互动直播
    anchorView.liveManager = [[AUIRoomInteractionLiveManagerAnchor alloc] initWithModel:liveInfoModel withJoinList:joinList];
  }
  else {
    anchorView.liveManager = [[AUIRoomBaseLiveManagerAnchor alloc] initWithModel:liveInfoModel];
  }
  anchorView.onSetupBeautyBlock = ^(QueenEngine * beautyEngine) {
    weakSelf.beautyEngine = beautyEngine;
  };
  [anchorView setupBackground];
  [anchorView setupLiveManager];
  //    [self setupRoomUI];
  [anchorView.liveManager enterRoom:^(BOOL success) {
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

/// MARK: 开始直播
RCT_EXPORT_METHOD(startLive:(nonnull NSNumber *)reactTag resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  [anchorView.liveManager startLive:^(BOOL success) {
    NSLog(@"开始直播：%@", success ? @"成功" : @"失败");
    if (success) {
      resolve(@(success));
    }else{
      reject(@"401",@"开始直播失败了",nil);
    }
    //      [AVToastView show:@"开始直播失败了" view:weakSelf position:AVToastViewPositionMid];
  }];
}


/// MARK: 获取组内的用户id集合
RCT_EXPORT_METHOD(queryListGroupUser:(nonnull NSNumber *)reactTag groupId:(NSString *)groupId resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  [anchorView.liveManager queryListGroupUserWithGroupID:groupId sortType:1 pageNum:1 pageSize:100 onSuccess:^(int32_t total, BOOL hasMore, NSArray<AVCIInteractionGroupUser *> * _Nonnull users) {
    id data = [users mj_JSONObject];
    if ([data isKindOfClass:[NSArray class]]) {
      NSMutableArray *userArr = [NSMutableArray array];
      for (AVCIInteractionGroupUser *user in users) {
        [userArr addObject:@{@"userId":user.userId,@"joinTime": @(user.joinTime)}];
      }
      resolve(userArr);
    }else{
      resolve(@[]);
    }
    
  } onFailure:^(AVCIInteractionError * _Nonnull error) {
    reject(@"401",@"获取观众列表数据失败",nil);
  }];
}

/// MARK: 根据用户id集合获取用户信息集合
RCT_EXPORT_METHOD(queryGroupUserByIdList:(nonnull NSNumber *)reactTag groupId:(NSString *)groupId userIdList:(NSArray<NSString*>*)userIdList resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  [anchorView.liveManager queryGroupUserByIdListWithGroupID:groupId userIdList:userIdList onSuccess:^(NSArray<AVCIInteractionGroupUserDetail *> * _Nonnull users) {
    id data = [users mj_JSONObject];
    if ([data isKindOfClass:[NSArray class]]) {
      NSMutableArray *userArr = [NSMutableArray array];
      for (AVCIInteractionGroupUserDetail *user in users) {
        /**
         * NSString * userId用户id NSString * userNick用户昵称 NSString * userAvatar用户头像 NSString * userExtension用户扩展信息 用户的加入时间 NSArray<NSString *> * muteBy 被禁言的原因["group","user"]
         */
        if ([AUILiveManager liveManager].currentUser.userId != user.userId) {
          [userArr addObject:@{@"userId":user.userId,@"nickName":user.userNick,@"avatar":user.userAvatar,@"userExtension":user.userExtension,@"isMute": @(user.isMute),@"muteBy":user.muteBy}];
        }
      }
      resolve(userArr);
    }else{
      resolve(@[]);
    }
  } onFailure:^(AVCIInteractionError * _Nonnull error) {
    reject(@"401",@"获取观众列表数据失败",nil);
  }];
}


/// MARK: 结束直播
RCT_EXPORT_METHOD(onExitLive:(nonnull NSNumber *)reactTag) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  NSString *tips = @"还有观众正在路上，确定要结束直播吗？";
  if (anchorView.liveManager.liveInfoModel.status == AUIRoomLiveStatusFinished) {
    tips = @"确定要离开吗？";
  }
  anchorView.onExitLive(@{@"title":tips,@"liveInfoModelStatus":@(anchorView.liveManager.liveInfoModel.status)});
}

/// MARK: 翻转摄像头
RCT_EXPORT_METHOD(onSwitchCamera:(nonnull NSNumber *)reactTag){
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  [anchorView.liveManager switchLivePusherCamera];
}


/// MARK: 确认结束后离开直播
/// - Parameter callback: callback description
RCT_EXPORT_METHOD(onLeaveRoom:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
  __weak typeof(self) weakSelf = self;
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  [anchorView.liveManager leaveRoom:^(BOOL result) {
    // 清理操作
    if (weakSelf.beautyEngine) {
      [weakSelf.beautyEngine destroyEngine];
      weakSelf.beautyEngine = nil;
    }
    [anchorView releaseResource];
    //    [weakSelf.bridge invalidate];
    //    weakSelf.bridge = nil;
    callback(@[@(1)]);
  }];
  
}

/// MARK: 同意连麦申请
RCT_EXPORT_METHOD(onLinkMicAgreeBtnClick:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  BOOL result = [anchorView.linkMicManager checkCanLinkMic];
  if (!result) {
    reject(@"401",@"当前连麦人数已经超过最大限制",nil);
  }else{
    AUIRoomUser *roomUser = [AUIRoomUser mj_objectWithKeyValues:dic];
    [anchorView.linkMicManager responseApplyLinkMic:roomUser agree:YES force:NO completed:^(BOOL success) {
      if (success) {
        NSDictionary *dic = [anchorView getLinkMicInfo:anchorView.linkMicManager];
        resolve(dic);
      }
      else {
        reject(@"401",@"失败了，请稍后重试",nil);
      }
    }];
  }
}

/// MARK: 拒绝连麦申请
RCT_EXPORT_METHOD(onLinkMicRejectBtnClick:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  AUIRoomUser *roomUser = [AUIRoomUser mj_objectWithKeyValues:dic];
  [anchorView.linkMicManager responseApplyLinkMic:roomUser agree:NO force:NO completed:^(BOOL success) {
    if (success) {
      NSDictionary *dic = [anchorView getLinkMicInfo:anchorView.linkMicManager];
      resolve(dic);
    }
    else {
      reject(@"401",@"失败了，请稍后重试",nil);
    }
  }];
}

/// MARK: 离开连麦（下麦）
RCT_EXPORT_METHOD(onLinkMicLeaveBtnClick:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  AUIRoomLiveRtcPlayer *roomUser = [AUIRoomLiveRtcPlayer mj_objectWithKeyValues:dic];
  [anchorView.linkMicManager kickoutLinkMic:[roomUser joinInfo].userId completed:^(BOOL success) {
    if (success) {
      NSDictionary *dic = [anchorView getLinkMicInfo:anchorView.linkMicManager];
      resolve(dic);
    }
    else {
      reject(@"401",@"失败了，请稍后重试",nil);
    }
  }];
}


/// MARK: 连麦开关
RCT_EXPORT_METHOD(onMicBtnClick:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [AUIRoomLiveLinkMicJoinInfoModel mj_objectWithKeyValues:dic];
  [anchorView.linkMicManager openMic:joinInfo.userId needOpen:!joinInfo.micOpened completed:^(BOOL success) {
    if (success) {
      NSDictionary *dic = [anchorView getLinkMicInfo:anchorView.linkMicManager];
      resolve(dic);
    }
    else {
      reject(@"401",@"失败了，请稍后重试",nil);
    }
  }];
}

/// MARK: 摄像头开关
RCT_EXPORT_METHOD(onCameraBtnClick:(nonnull NSNumber *)reactTag dic:(NSDictionary *)dic resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  __weak typeof(self) weakSelf = self;
  AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [[AUIRoomLiveRtcPlayer mj_objectWithKeyValues:dic] joinInfo];
  [anchorView.linkMicManager openCamera:joinInfo.userId needOpen:!joinInfo.cameraOpened completed:^(BOOL success) {
    if (success) {
      NSDictionary *dic = [anchorView getLinkMicInfo:anchorView.linkMicManager];
      resolve(dic);
    }
    else {
      reject(@"401",@"失败了，请稍后重试",nil);
    }
  }];
}

/// MARK: 更多设置面板事件处理
RCT_EXPORT_METHOD(onMorePanelClickedAction:(nonnull NSNumber *)reactTag type:(int)type selected:(BOOL)selected callBack:(RCTResponseSenderBlock)callBack){
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  BOOL ret = selected;
  switch (type) {
    case 0:
    {
      [anchorView.liveManager openLivePusherMic:selected];
      ret = !anchorView.liveManager.isMicOpened;
      callBack(@[@(type),@(ret)]);
    }
      break;
    case 1:
    {
      [anchorView.liveManager openLivePusherCamera:selected];
      ret = !anchorView.liveManager.isCameraOpened;
      callBack(@[@(type),@(ret)]);
    }
      break;
      
    case 2:
    {
      if (selected) {
        //              AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
        [anchorView.liveManager cancelMuteAll:^(BOOL result) {
          callBack(@[@(type),@(1)]);
          //          completedBlock(result, @"已取消全员禁言", @"取消全员禁言失败，请稍后再试", loading);
        }];
      }
      else {
        [anchorView.liveManager muteAll:^(BOOL result) {
          callBack(@[@(type),@(0)]);
          //          completedBlock(result, @"已全员禁言", @"全员禁言失败，请稍后再试", loading);
        }];
      }
    }
      break;
    case 3:
    {
      [anchorView.liveManager openLivePusherMirror:!selected];
      ret = anchorView.liveManager.isMirror;
      callBack(@[@(type),@(ret)]);
    }
      break;
    default:
      callBack(@[@(type),@(ret)]);
      break;
  }
  
}

/// MARK: 发送互动消息
RCT_EXPORT_METHOD(sendComment:(nonnull NSNumber *)reactTag comment:(NSString *)comment){
  WUAlivcAnchorView *anchorView = [self getViewWithTag:reactTag];
  [anchorView.liveManager sendComment:comment completed:nil];
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


- (void)onQueenBeautyType:(BOOL)enable {
  self.isEnableBeauty = enable;
  // 打开磨皮锐化功能开关
  // 第三个参数为基础美颜的模式，设置为kBMSkinBuffing_Natural，则美颜的效果更自然，细节保留更多；设置为kQueenBeautyFilterModeSkinBuffing_Strong，则效果更夸张，细节去除更多。
  [self.beautyEngine setQueenBeautyType:kQueenBeautyTypeSkinBuffing enable:enable mode:kQueenBeautyFilterModeSkinBuffing_Natural];
  // 打开美白功能开关
  [self.beautyEngine setQueenBeautyType:kQueenBeautyTypeSkinWhiting enable:enable];
}

///MARK: 禁用美颜效果
RCT_EXPORT_METHOD(onQueenBeautyOff) {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [weakSelf onQueenBeautyType:NO];
  });
}

///MARK: 美颜系数
RCT_EXPORT_METHOD(onQueenBeautySkinWhiting:(float)value) {
  if (!self.isEnableBeauty) {
    [self onQueenBeautyType:YES];
  }
  // 设置美白系数
  [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsWhitening value:value];
}

///MARK: 红润系数
RCT_EXPORT_METHOD(onQueenBeautySkinRed:(float)value) {
  if (!self.isEnableBeauty) {
    [self onQueenBeautyType:YES];
  }
  // 设置红润系数
  [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsSkinRed value:value];
}

///MARK: 磨皮系数
RCT_EXPORT_METHOD(onQueenBeautySkinBuffing:(float)value) {
  if (!self.isEnableBeauty) {
    [self onQueenBeautyType:YES];
  }
  // 设置磨皮系数
  [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsSkinBuffing value:value];
}

///MARK: 锐化系数
RCT_EXPORT_METHOD(onQueenBeautySkinSharpen:(float)value) {
  if (!self.isEnableBeauty) {
    [self onQueenBeautyType:YES];
  }
  // 设置锐化系数
  [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsSharpen value:value];
}


- (void)dealloc {
  
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

@end
