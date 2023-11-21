//
//  WUAlivcAudienceView.h
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/1.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <React/RCTComponent.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "AUILiveRoomAnchorViewController.h"
#import "AUIRoomBaseLiveManagerAudience.h"
#import "AUIRoomInteractionLiveManagerAudience.h"

NS_ASSUME_NONNULL_BEGIN

@interface WUAlivcAudienceView : UIView
@property (strong, nonatomic) id<AUIRoomLiveManagerAudienceProtocol> __nullable liveManager;
@property (nonatomic, strong) AUIRoomInteractionLiveManagerAudience *__nullable linkMicManager;
// 关闭按钮的block
@property (nonatomic, copy) RCTBubblingEventBlock onExitLive;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedStartLive;//开始直播拉流回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedStopLive;//结束直播拉流回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedComment;//收到互动消息回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedMuteAll;//收到禁言消息回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedLike;//收到点赞消息回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedPV;//直播间观看数更新回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedNoticeUpdate;//直播间公告更新回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedResponseApplyLinkMic;//收到请求连麦申请结果回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedJoinLinkMic;//收到连麦回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedLeaveLinkMic;//收到被主播结束连麦回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedOpenMic;//收到开关麦克风回调
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedOpenCamera;//收到开关摄像头回调
@property (nonatomic, copy) RCTBubblingEventBlock onNotifyApplyNotResponse;//主播未响应连麦申请
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedDisagreeToLinkMic;//主播拒绝了您的连麦申请
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedAgreeToLinkMic;//连麦申请通过，是否开始连麦？
@property (nonatomic, copy) RCTBubblingEventBlock onPlayErrorBlock;//直播中断，您可尝试再次拉流
@property (nonatomic, copy) RCTBubblingEventBlock onApplyBlock;//员工申请连麦
@property (nonatomic, copy) RCTBubblingEventBlock onCancelApplyLinkMic;//员工取消连麦
@property (nonatomic, copy) RCTBubblingEventBlock onLeaveLinkMic;//员工结束连麦
@property (nonatomic, copy) RCTBubblingEventBlock onSwitchCamera;//员工切换摄像头
@property (nonatomic, copy) RCTBubblingEventBlock onSwitchVideo;//员工开关自己的麦克风
@property (nonatomic, copy) RCTBubblingEventBlock onSwitchAudio;//员工开关自己的摄像头
- (void)setupBackground;
- (void)setupLiveManager;
///MARK: 处理连麦数据结构
- (NSDictionary *)getLinkMicInfo: (AUIRoomInteractionLiveManagerAudience *)sender;
//- (void)createLiveManager:(AUIRoomLiveInfoModel *)liveInfoModel withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList;
- (void)receivedAgreeToLinkMic:(NSString *)userId isCanced:(BOOL)isCanced;
- (void)releaseResource;
@end

NS_ASSUME_NONNULL_END


