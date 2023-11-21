//
//  AUIRoomItem.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/10.
//

#import "AUIRoomItem.h"

@implementation AUIRoomItem

- (instancetype)initWithRoomModel:(AUIRoomLiveInfoModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (NSString *)cover {
    return _roomModel.cover;
}

- (BOOL)living {
    return _roomModel.status != AUIRoomLiveStatusFinished;
}

- (NSString *)title {
    return _roomModel.title;
}

- (NSString *)info {
    return _roomModel.anchor_nickName ?: _roomModel.anchor_id;
}

- (NSString *)metrics {
    if (_roomModel.metrics.pv > 10000) {
        return [NSString stringWithFormat:@"%.1f万观看", _roomModel.metrics.pv / 10000.0];
    }
    return [NSString stringWithFormat:@"%zd观看", _roomModel.metrics.pv];
}

@end
