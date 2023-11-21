//
//  AUIRoomBaseLiveManagerAudience.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import <Foundation/Foundation.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomUser.h"
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

// 定义块类型
typedef void (^OnPlayErrorBlock)(NSString *result);
@protocol AUIRoomLiveManagerAudienceProtocol <NSObject>

@property (strong, nonatomic, readonly) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) AUIRoomDisplayLayoutView *displayLayoutView;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (weak, nonatomic) UIViewController *roomVC;
- (void)setupPullPlayer:(BOOL)scaleAspectFit;

//尝试再次拉流
- (void)retryRoomLivePlay;

- (BOOL)pause:(BOOL)pause;

- (void)enterRoom:(nullable void(^)(BOOL))completed;
- (void)leaveRoom:(nullable void (^)(BOOL))completed;
- (void)onPlayErrorBlock:(OnPlayErrorBlock)completed;


@property (nonatomic, copy) void (^onReceivedStartLive)(void);
@property (nonatomic, copy) void (^onReceivedStopLive)(void);

// 全局禁言
@property (copy, nonatomic) void (^onReceivedMuteAll)(BOOL isMuteAll);
@property (assign, nonatomic, readonly) BOOL isMuteAll;

// 弹幕
@property (copy, nonatomic) void (^onReceivedComment)(AUIRoomUser *sender, NSString *content);
- (void)sendComment:(NSString *)comment completed:(nullable void(^)(BOOL))completed;

// 点赞
@property (copy, nonatomic) void (^onReceivedLike)(AUIRoomUser *sender, NSInteger likeCount);
- (void)sendLike;

// PV
@property (copy, nonatomic) void (^onReceivedPV)(NSInteger pv);
@property (assign, nonatomic, readonly) NSInteger pv;

// 公告
@property (nonatomic, copy) void (^onReceivedNoticeUpdate)(NSString *notice);
@property (copy, nonatomic, readonly) NSString *notice;


@property (copy, nonatomic) OnPlayErrorBlock onPlayErrorBlock;//直播中断
@end


@interface AUIRoomBaseLiveManagerAudience : NSObject<AUIRoomLiveManagerAudienceProtocol>

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel;
////直播状况
//@property (copy, nonatomic) void(^onPlayErrorBlock)(BOOL);//直播中断
////尝试再次拉流
//- (void)retryRoomLivePlay;

@end

NS_ASSUME_NONNULL_END
