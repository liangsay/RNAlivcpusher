//
//  CustomView.h
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomView : UIView
@property (nonatomic, copy) void (^onCustomEvent)(NSDictionary *);

@end

NS_ASSUME_NONNULL_END
