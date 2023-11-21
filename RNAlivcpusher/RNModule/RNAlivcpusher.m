//
//  RNAlivcpusher.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/2.
//

#import "RNAlivcpusher.h"

#import "AUIRoomAppServer.h"
#import "AUILiveManager.h"
#import "AUIRoomUser.h"
#import "AUIRoomDeviceAuth.h"
#import "AUIRoomLiveModel.h"
#import "AUIRoomAccount.h"
#import <MJExtension/MJExtension.h>
#import "AUIRoomItem.h"

@implementation RNAlivcpusher
{
  bool hasListeners;
}

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
  return @[];
}


// 在添加第一个监听函数时触发
-(void)startObserving {
  hasListeners = YES;
  // Set up any upstream listeners or background tasks as necessary
  for (NSString *notifiName in [self supportedEvents]) {
    SEL selector = nil;
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notifiName object:nil];
  }
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
  hasListeners = NO;
  // Remove upstream listeners, stop unnecessary background tasks
}


+(void)sendEvent:(NSString *)eventName params:(NSDictionary *)params {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:params userInfo:nil];
}

- (NSDictionary *)constantsToExport
{
  AUIRoomUser *me = [[AUILiveManager liveManager] currentUser];
  return @{
    @"isLogin": [NSNumber numberWithBool:me.userId.length > 0]
  };
}

/// MARK: 初始化配置
RCT_EXPORT_METHOD(onSetup:(NSString *) host) {
  [[AUILiveManager liveManager] setup:host];
}


/// MARK: 直播登录
RCT_EXPORT_METHOD(onLiveLogin:(NSDictionary *) params resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *uid = params[@"uid"];
  [AUIRoomAppServer requestWithPath:@"/api/v1/live/login" bodyDic:@{@"password":uid, @"username":uid} completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
    if (error) {
      reject(@"401",@"登录直播失败",nil);
    }else{
      AUIRoomUser *me = [AUIRoomUser new];
      me.userId = uid;
      me.avatar = @"https://img.alicdn.com/imgextra/i4/O1CN01ES6H0u21ObLta9mAF_!!6000000006975-2-tps-80-80.png";
      me.nickName = uid;
      me.token = [responseObject objectForKey:@"token"];
      [[AUILiveManager liveManager] setCurrentUser:me];
      
      [[NSUserDefaults standardUserDefaults] setObject:me.userId forKey:@"my_user_id"];
      [[NSUserDefaults standardUserDefaults] setObject:me.token forKey:@"my_user_token"];
      [[NSUserDefaults standardUserDefaults] setObject:me.nickName forKey:@"my_user_name"];
      
      [[NSUserDefaults standardUserDefaults] setObject:me.nickName forKey:@"last_login_name"];
      
      [[NSUserDefaults standardUserDefaults] synchronize];
      NSDictionary *dic = [me mj_JSONObject];
      resolve(@{@"user":dic});
    }
  }];
}

/// MARK: 退出直播登录
RCT_EXPORT_METHOD(onLiveLogout) {
  [[AUILiveManager liveManager] logout];
  [[AUILiveManager liveManager] setCurrentUser:nil];
  //  [self saveCurrentUser];
  AUIRoomUser *me = [[AUILiveManager liveManager] currentUser];
  [[NSUserDefaults standardUserDefaults] setObject:me.userId forKey:@"my_user_id"];
  [[NSUserDefaults standardUserDefaults] setObject:me.token forKey:@"my_user_token"];
  [[NSUserDefaults standardUserDefaults] setObject:me.nickName forKey:@"my_user_name"];
  
  [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"last_login_name"];
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}


///MARK: 获取直播列表
RCT_EXPORT_METHOD(onFetchLiveList:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [AUIRoomAppServer fetchLiveList:1 pageSize:6 completed:^(NSArray<AUIRoomLiveInfoModel *> * _Nullable models, NSError * _Nullable error) {
    NSMutableArray *roomList = [NSMutableArray array];
    if (!error) {
      [models enumerateObjectsUsingBlock:^(AUIRoomLiveInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AUIRoomItem *item = [[AUIRoomItem alloc] initWithRoomModel:obj];
        NSDictionary *dic = [item mj_JSONObject];
        if (dic != nil) {
          [roomList addObject:dic];
        }
      }];
      resolve(roomList);
    }
    else {
      reject(@"401",@"获取直播列表失败",nil);
    }
  }];
}

///MARK: 加入直播间
RCT_EXPORT_METHOD(joinLiveWithLiveId:(NSString *)aiveId resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[AUILiveManager liveManager] joinLiveWithLiveId:aiveId currentVC:[UIViewController new] completed:^(BOOL success, AUIRoomLiveInfoModel * _Nonnull model, NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nonnull joinList) {
      NSMutableArray *joinDatas = [NSMutableArray array];
      if (success) {
        [joinList enumerateObjectsUsingBlock:^(AUIRoomLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          NSDictionary *dic = [obj mj_JSONObject];
          if (dic != nil) {
            [joinDatas addObject:dic];
          }
        }];
        NSMutableDictionary *roomLiveInfoDic = [NSMutableDictionary dictionaryWithDictionary:[model mj_JSONObject]];
        if (model.extends && [model.extends isKindOfClass:[NSDictionary class]]) {
          roomLiveInfoDic[@"extends"] = [model.extends mj_JSONString];
        }
        resolve(@{@"roomLiveInfo": roomLiveInfoDic,@"joinList":joinDatas});
      }
      else {
        reject(@"401",@"加入直播间失败",nil);
      }
    }];
  });
}


- (BOOL)startToCreatLive {
  __weak typeof(self) weakSelf = self;
  BOOL ret = NO;
  ret = [AUIRoomDeviceAuth checkCameraAuth:^(BOOL auth) {
    if (auth) {
      [weakSelf startToCreatLive];
    }
  }];
  if (!ret) {
    return NO;
  }
  
  ret = [AUIRoomDeviceAuth checkMicAuth:^(BOOL auth) {
    if (auth) {
      [weakSelf startToCreatLive];
    }
  }];
  if (!ret) {
    return NO;
  }
  return YES;
}

/// MARK: 创建直播
RCT_EXPORT_METHOD(onCreateLive:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  BOOL result = [self startToCreatLive];
  if (result) {
    NSString *title = params[@"title"];//直播间的标题
    NSString *notice = params[@"notice"]; //直播间公告
    [[AUILiveManager liveManager] createLive:AUIRoomLiveModeLinkMic title:title ? title : [NSString stringWithFormat:@"%@的直播", AUIRoomAccount.me.nickName] notice:notice currentVC:[UIViewController new] completed:^(BOOL success, AUIRoomLiveInfoModel *model) {
      if (!success) {
        NSDictionary *dic = model.extends;
        if (dic != nil) {
          NSString *message = dic[@"message"];
          reject(@"401",message,nil);
        }else{
          reject(@"401",@"创建直播失败",nil);
        }
        
      }else{
        [AUILiveManager saveLastLiveData:model.live_id];
        id result = [model mj_JSONString];
        resolve(result);
      }
    }];
    //        [[AUILiveManager liveManager] createLive:nil mode:AUIRoomLiveModeLinkMic title:title ?: [NSString stringWithFormat:@"%@的直播", AUIRoomAccount.me.nickName] notice:notice extend:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
    //            if (error) {
    //                reject(@"no_events",@"There were no events",error);
    //            }else{
    //                id result = [model mj_JSONObject];
    //                resolve(result);
    //            }
    //
    //        }];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}
@end

