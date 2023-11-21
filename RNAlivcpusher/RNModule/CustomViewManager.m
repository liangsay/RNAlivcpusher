//
//  CustomViewManager.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/16.
//

#import "CustomViewManager.h"

#import <React/RCTUIManager.h>

@implementation CustomViewManager

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(onCustomEvent, RCTBubblingEventBlock)

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (UIView *)view {
  CustomView *view = [[CustomView alloc] init];
  self.mainView = view;
  return view;
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

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

@end
