//
//  WUAlivcAnchorView.h
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
#import "AUIRoomBaseLiveManagerAnchor.h"
#import "AUIRoomInteractionLiveManagerAnchor.h"

NS_ASSUME_NONNULL_BEGIN

@interface WUAlivcAnchorView : UIView
@property (strong, nonatomic) id<AUIRoomLiveManagerAnchorProtocol> __nullable liveManager;
@property (nonatomic, strong) AUIRoomInteractionLiveManagerAnchor *__nullable linkMicManager;
// 关闭按钮的block
@property (nonatomic, copy) RCTBubblingEventBlock onExitLive;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedPV;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedLike;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedMuteAll;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedComment;
@property (nonatomic, copy) RCTBubblingEventBlock onApplyListChangedBlock;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedMicOpened;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedCameraOpened;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedApplyLinkMic;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedCancelApplyLinkMic;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedJoinLinkMic;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedLeaveLinkMic;
@property (nonatomic, copy) RCTBubblingEventBlock onStartedBlock;
@property (nonatomic, copy) RCTBubblingEventBlock onReceivedDisagreeToLinkMic;//
@property (nonatomic, copy) RCTBubblingEventBlock onEnterRoomBlock;//进入直播间结果
@property (nonatomic, copy) RCTBubblingEventBlock onStartLiveBlock;//开始直播结果
@property (copy, nonatomic) void(^onSetupBeautyBlock)(QueenEngine *);
///
- (void)setupBackground;
- (void)setupLiveManager;
///MARK: 处理连麦数据结构
- (NSDictionary *)getLinkMicInfo: (AUIRoomInteractionLiveManagerAnchor *)sender;
//- (void)createLiveManager:(AUIRoomLiveInfoModel *)liveInfoModel withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList;
- (void)releaseResource;
@end

NS_ASSUME_NONNULL_END


