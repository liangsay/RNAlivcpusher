//
//  AUIInteractionLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import "AUIInteractionLiveManager.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomMessageService.h"
#import "AUIRoomBeautyManager.h"

#import "AUILiveRoomAnchorViewController.h"
#import "AUILiveRoomAudienceViewController.h"

#import "AUIRoomTheme.h"
#import "AUIFoundation.h"
#import "AUIRoomSDKHeader.h"


@interface AUIInteractionLiveManager ()

@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@end

@implementation AUIInteractionLiveManager

+ (instancetype)defaultManager {
    static AUIInteractionLiveManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIInteractionLiveManager new];
    }
    return _instance;
}

- (void)setup:(NSString *)host {
    // 设置bundle资源名称
    AUIRoomTheme.resourceName = @"AUIInteractionLive";
    
    // 设置AppServer地址
    [AUIRoomAppServer setServiceUrl:host];
    
    // 初始化SDK
    [AlivcBase setIntegrationWay:@"aui-live-interaction"];
    [AlivcLiveBase registerSDK];
    
    // 初始化美颜
    [AUIRoomBeautyManager registerBeautyEngine];
    
    [AliPlayer setEnableLog:NO];
    [AliPlayer setLogCallbackInfo:LOG_LEVEL_NONE callbackBlock:nil];
    
#if DEBUG
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase setLogPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject maxPartFileSizeInKB:1024*100];
#endif
}

- (void)setCurrentUser:(AUIRoomUser *)user {
    AUIRoomAccount.me.userId = user.userId ?: @"";
    AUIRoomAccount.me.avatar = user.avatar ?: @"";
    AUIRoomAccount.me.nickName = user.nickName ?: @"";
    AUIRoomAccount.me.token = user.token ?: @"";
}

- (AUIRoomUser *)currentUser {
    return AUIRoomAccount.me;
}

- (void)login:(void(^)(BOOL success))completedBlock {
    [AUIRoomMessage.currentService login:completedBlock];
}

- (void)logout {
    [AUIRoomMessage.currentService logout];
}

- (void)createLiveCore:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString *)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success, AUIRoomLiveInfoModel *model))completedBlock {
    [self login:^(BOOL success) {
        if (!success) {
            //            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            if (completedBlock) {
                NSDictionary *dic = @{@"code":@(401),@"message":@"直播间登入失败"};
                AUIRoomLiveInfoModel *_model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:@{@"extends": [dic av_jsonString]}];
                completedBlock(NO, _model);
            }
            return;
        }
        
        [AUIRoomAppServer createLive:nil mode:mode title:title ?: [NSString stringWithFormat:@"%@的直播", AUIRoomAccount.me.nickName] notice:notice extend:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                //                [AVAlertController show:@"创建直播间失败" vc:currentVC];
                if (completedBlock) {
                    NSDictionary *dic = @{@"code":@(401),@"message":@"创建直播间失败"};
                    AUIRoomLiveInfoModel *_model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:@{@"extends": [dic av_jsonString]}];
                    completedBlock(NO, nil);
                }
                return;
            }
            
            //            AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithModel:model withJoinList:nil];
            //            [currentVC.navigationController pushViewController:vc animated:YES];
            
            if (completedBlock) {
                completedBlock(YES, model);
            }
        }];
    }];
}

- (void)createLive:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString *)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success, AUIRoomLiveInfoModel *model))completedBlock {
    [self createLiveCore:mode title:title notice:notice currentVC:currentVC completed:^(BOOL success, AUIRoomLiveInfoModel * _Nullable model) {
        if (completedBlock) {
            completedBlock(success, model);
        }
    }];
}

- (void)fetchLinkMicJoinList:(AUIRoomLiveInfoModel *)model completed:(void(^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList, NSError *error))completed {
    if (model.mode == AUIRoomLiveModeLinkMic) {
        [AUIRoomAppServer queryLinkMicJoinList:model.live_id completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
            if (completed) {
                completed(models, error);
            }
        }];
        return;
    }
    if (completed) {
        completed(nil, nil);
    }
}

- (void)joinLiveWithLiveId:(NSString *)liveId currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success,AUIRoomLiveInfoModel *model, NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList))completedBlock {
    __weak typeof(self) weakSelf = self;
    //    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    //    loading.labelText = @"正在加入直播间，请等待";
    // 登录IM
    [AUIRoomMessage.currentService login:^(BOOL success) {
        if (!success) {
            //            [loading hideAnimated:YES];
            //            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            if (completedBlock) {
                NSDictionary *dic = @{@"code":@(401),@"message":@"直播间登入失败"};
                AUIRoomLiveInfoModel *_model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:@{@"extends": [dic av_jsonString]}];
                completedBlock(NO,_model,nil);
            }
            return;
        }
        
        // 获取最新直播信息
        [AUIRoomAppServer fetchLive:liveId userId:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                //                [loading hideAnimated:YES];
                //                [AVAlertController show:@"直播间刷新失败" vc:currentVC];
                if (completedBlock) {
                    NSDictionary *dic = @{@"code":@(401),@"message":@"直播间刷新失败"};
                    AUIRoomLiveInfoModel *_model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:@{@"extends": [dic av_jsonString]}];
                    completedBlock(NO,_model,nil);
                }
                return;
            }
            
            // 获取上麦信息
            [weakSelf fetchLinkMicJoinList:model completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList, NSError *error) {
                
                //                [loading hideAnimated:YES];
                if (error) {
                    //                    [AVAlertController show:@"获取上麦列表失败" vc:currentVC];
                    if (completedBlock) {
                        NSDictionary *dic = @{@"code":@(401),@"message":@"获取上麦列表失败"};
                        AUIRoomLiveInfoModel *_model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:@{@"extends": [dic av_jsonString]}];
                        completedBlock(NO,_model,nil);
                    }
                    return;
                }
                
                //                if ([model.anchor_id isEqualToString:AUIRoomAccount.me.userId]) {
                //                    AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithModel:model withJoinList:joinList];
                //                    [currentVC.navigationController pushViewController:vc animated:YES];
                //                }
                //                else {
                //                    AUILiveRoomAudienceViewController *vc = [[AUILiveRoomAudienceViewController alloc] initWithModel:model withJoinList:joinList];
                //                    [currentVC.navigationController pushViewController:vc animated:YES];
                //                }
                if (completedBlock) {
                    completedBlock(YES,model,joinList);
                }
            }];
        }];
    }];
}

- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success,AUIRoomLiveInfoModel *model,NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList))completedBlock {
    [self joinLiveWithLiveId:model.live_id currentVC:currentVC completed:completedBlock];
}

@end
