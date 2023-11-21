//
//  RNAlivcpusher.h
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/2.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN


@interface RNAlivcpusher : RCTEventEmitter <RCTBridgeModule>
+(void)sendEvent:(NSString *)eventName params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
