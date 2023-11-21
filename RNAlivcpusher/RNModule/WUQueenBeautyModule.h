//
//  WUQueenBeautyModule.h
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/17.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface WUQueenBeautyModule : NSObject<RCTBridgeModule>
- (void)captureBegin;
- (void)captureEnd;
- (void)captureReset;
- (CVPixelBufferRef)getProcessedPixelBufferRefWithCurrentPixelBufferRef:(CVPixelBufferRef)pixelBufferRef;
@end

NS_ASSUME_NONNULL_END
