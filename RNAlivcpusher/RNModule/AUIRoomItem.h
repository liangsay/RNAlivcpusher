//
//  AUIRoomItem.h
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/10.
//

#import <Foundation/Foundation.h>
#import "AUIRoomAppServer.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomItem : NSObject
@property (nonatomic, strong) AUIRoomLiveInfoModel *roomModel;

@property (nonatomic, strong) NSString *cover;

@property (nonatomic, assign) BOOL living;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *info;

@property (nonatomic, strong) NSString *metrics;

- (instancetype)initWithRoomModel:(AUIRoomLiveInfoModel *)roomModel;
@end

NS_ASSUME_NONNULL_END
