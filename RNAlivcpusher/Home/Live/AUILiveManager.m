//
//  AUILiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/19.
//

#import "AUILiveManager.h"
#import "AUIFoundation.h"

@implementation AUILiveManager

#if LIVE_TYPE==INTERACTION_LIVE
+ (AUIInteractionLiveManager *)liveManager {
    return [AUIInteractionLiveManager defaultManager];
}
#else
+ (AUIEnterpriseLiveManager *)liveManager {
    return [AUIEnterpriseLiveManager defaultManager];
}
#endif


#pragma mark - last live

static NSString *g_lastLiveId = nil;
+ (void)joinLastLive:(UIViewController *)currentVC {
    if (![self hasLastLive]) {
        [AVAlertController show:@"没有上场直播数据" vc:currentVC];
        return;
    }
    
    [[AUILiveManager liveManager] joinLiveWithLiveId:g_lastLiveId currentVC:currentVC completed:nil];
}

+ (BOOL)hasLastLive {
    return g_lastLiveId.length > 0;
}

+ (void)loadLastLiveData {
    NSString *last_live_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_live_id"];
    AUIRoomUser *me = [[AUILiveManager liveManager] currentUser];
    if (me.userId.length > 0 && [last_live_id hasPrefix:me.userId]) {
        g_lastLiveId = [last_live_id substringFromIndex:me.userId.length + 1];
    }
    else {
        g_lastLiveId = nil;
    }
}

+ (void)saveLastLiveData:(NSString *)lastLiveId {
    if ([g_lastLiveId isEqualToString:lastLiveId]) {
        return;
    }
    g_lastLiveId = lastLiveId;
    if (g_lastLiveId.length > 0) {
        AUIRoomUser *me = [[AUILiveManager liveManager] currentUser];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@_%@", me.userId, g_lastLiveId] forKey:@"last_live_id"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"last_live_id"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
