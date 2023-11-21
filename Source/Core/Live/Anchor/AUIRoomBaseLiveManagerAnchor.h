//
//  AUIRoomBaseLiveManagerAnchor.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/4.
//

#import <Foundation/Foundation.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomUser.h"
#import "AUIRoomLiveModel.h"
#import "AUIRoomLiveService.h"
#import "AUIRoomSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN


@protocol AUIRoomLiveManagerAnchorProtocol <NSObject>

@property (strong, nonatomic, readonly) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) AUIRoomDisplayLayoutView *displayLayoutView;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (nonatomic, strong) QueenEngine *beautyEngine;
@property (weak, nonatomic) UIView *roomV;


@property (copy, nonatomic) void(^onStartedBlock)(void);
@property (copy, nonatomic) void(^onPausedBlock)(void);
@property (copy, nonatomic) void(^onResumedBlock)(void);
@property (copy, nonatomic) void(^onRestartBlock)(void);
@property (copy, nonatomic) void(^onConnectionPoorBlock)(void);
@property (copy, nonatomic) void(^onConnectionLostBlock)(void);
@property (copy, nonatomic) void(^onConnectionRecoveryBlock)(void);
@property (copy, nonatomic) void(^onConnectErrorBlock)(void);
@property (copy, nonatomic) void(^onReconnectStartBlock)(void);
@property (copy, nonatomic) void(^onReconnectSuccessBlock)(void);
@property (copy, nonatomic) void(^onReconnectErrorBlock)(void);
@property (copy, nonatomic) void(^onSetupBeautyBlock)(QueenEngine *);
- (void)setupLivePusher;
- (void)setupBeauty;

- (void)enterRoom:(nullable void(^)(BOOL))completed;
- (void)leaveRoom:(nullable void (^)(BOOL))completed;
//- (void)playStatu:(nullable void(^)(BOOL))completed;

- (void)startLive:(nullable void(^)(BOOL))completed;
- (void)finishLive:(nullable void(^)(BOOL))completed;

// 获取group内成员列表
- (void)queryListGroupUserWithGroupID:(NSString *)groupId sortType:(NSInteger)sortype pageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize
                onSuccess:(void (^)(int32_t total, BOOL hasMore, NSArray<AVCIInteractionGroupUser*>* users))onSuccess
              onFailure:(void (^)(AVCIInteractionError* error))onFailure;
//MARK: ——————————————————查询group内部分用户的详情——————————————————
- (void)queryGroupUserByIdListWithGroupID:(NSString *)groupId userIdList:(NSArray<NSString*>*)userIdList
                                onSuccess:(void (^)(NSArray<AVCIInteractionGroupUserDetail*>*))onSuccess
                                onFailure:(void (^)(AVCIInteractionError* error))onFailure;

// 全局禁言
@property (copy, nonatomic) void (^onReceivedMuteAll)(BOOL isMuteAll);
@property (assign, nonatomic, readonly) BOOL isMuteAll;
- (void)muteAll:(nullable void(^)(BOOL))completed;
- (void)cancelMuteAll:(nullable void(^)(BOOL))completed;

// 弹幕
@property (copy, nonatomic) void (^onReceivedComment)(AUIRoomUser *sender, NSString *content);
- (void)sendComment:(NSString *)comment completed:(nullable void(^)(BOOL))completed;

// 点赞
@property (copy, nonatomic) void (^onReceivedLike)(AUIRoomUser *sender, NSInteger likeCount);
@property (copy, nonatomic) void (^onReceivedCustomLike)(AUIRoomUser *sender, AUIRoomCustomLikeModel *like);

// PV
@property (copy, nonatomic) void (^onReceivedPV)(NSInteger pv);
@property (assign, nonatomic, readonly) NSInteger pv;

// 公告
@property (copy, nonatomic, readonly) NSString *notice;
- (void)updateNotice:(NSString *)notice completed:(nullable void(^)(BOOL))completed;

// Gift
@property (copy, nonatomic) void (^onReceivedGift)(AUIRoomUser *sender, AUIRoomGiftModel *gift);


@property (assign, nonatomic, readonly) BOOL isMicOpened;
@property (assign, nonatomic, readonly) BOOL isCameraOpened;
@property (assign, nonatomic, readonly) BOOL isBackCamera;
@property (assign, nonatomic, readonly) BOOL isMirror;
- (void)openLivePusherMic:(BOOL)open;
- (void)openLivePusherCamera:(BOOL)open;
- (void)switchLivePusherCamera;
- (void)openLivePusherMirror:(BOOL)mirror;

- (void)openBeautyPanel;

@end



@interface AUIRoomBaseLiveManagerAnchor : NSObject<AUIRoomLiveManagerAnchorProtocol>

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel;

@end

NS_ASSUME_NONNULL_END
