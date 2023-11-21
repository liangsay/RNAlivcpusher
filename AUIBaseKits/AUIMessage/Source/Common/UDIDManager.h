//
//  UDIDManager.h
//  YunXueTang
//
//  Created by liu jinliang on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UDIDManager : NSObject
/** 获取UDID */
+ (NSString *)UDID;
/** 保存UDID */
+ (BOOL)saveUDID:(NSString *)udid;
/** 清除UDID */
+ (BOOL)clearUDID;
@end

NS_ASSUME_NONNULL_END
