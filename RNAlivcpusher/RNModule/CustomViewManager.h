//
//  CustomViewManager.h
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/16.
//

#import <React/RCTViewManager.h>
#import "CustomView.h"
@interface CustomViewManager : RCTViewManager
@property (nonatomic, weak) CustomView *mainView;
@end
