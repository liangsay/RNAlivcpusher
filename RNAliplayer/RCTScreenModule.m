//
//  RCTScreenModule.m
//  RNAliplayer
//
//  Created by liu jinliang on 2022/4/8.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import "RCTScreenModule.h"

@implementation RCTScreenModule
RCT_EXPORT_MODULE();

/**
 *  设置横屏
 */
RCT_EXPORT_METHOD(setLandscape)
{
    // 强制竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];

}

/**
 * 设置竖屏
 */
RCT_EXPORT_METHOD(setPortrait)
{
    // 强制向左
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return true;
}
@end
