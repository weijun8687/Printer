//
//  BackBarButton.m
//  QiShou
//
//  Created by WJ on 16/8/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "BackBarButton.h"

@implementation BackBarButton

- (instancetype)init{
    if (self = [super init]) {
        self.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}


- (void)layoutSubviews{
    
//    [super layoutSubviews];
    
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    CGRect lb_frame = self.titleLabel.frame;
    lb_frame.size.width = self.frame.size.width - 13;
    lb_frame.size.height = 14;
    lb_frame.origin.x = 13;
    lb_frame.origin.y = (self.frame.size.height - lb_frame.size.height)/2.0;
    self.titleLabel.frame = lb_frame;
    
    CGRect iv_frame = self.imageView.frame;
    iv_frame.size.height = 14;
    iv_frame.size.width = 8;
    iv_frame.origin.y = (self.frame.size.height - iv_frame.size.height)/2.0;
    iv_frame.origin.x = 0;
    self.imageView.frame = iv_frame;
    
    self.imageView.image = [UIImage imageNamed:@"返回"];
    

}


@end
