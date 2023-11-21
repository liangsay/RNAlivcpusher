//
//  CustomView.m
//  RNAlivcpusher
//
//  Created by liu jinliang on 2023/11/16.
//

#import "CustomView.h"

@implementation CustomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // 初始化视图
    // 添加子视图、设置样式等
  }
  return self;
}

// 触发自定义事件
- (void)triggerCustomEvent:(NSString *)eventName {
  if (self.onCustomEvent) {
    self.onCustomEvent(@{@"eventName": eventName});
  }
}
- (void)dealloc {
  
}
@end
