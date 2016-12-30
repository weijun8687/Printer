//
//  UIBarButtonItem+WJExtension.m
//  xc
//
//  Created by Michael Zhang on 16/3/2.
//  Copyright © 2016年 bjtongan. All rights reserved.
//

#import "UIBarButtonItem+WJExtension.h"
#import "BackBarButton.h"

@implementation UIBarButtonItem (WJExtension)

// 返回按钮
+ (instancetype)itemBackButtonWithTarget:(id)target action:(SEL)action
{
    BackBarButton *button = [[BackBarButton alloc] init];
    button.size = CGSizeMake(60, 20);
    
    button.x = 10;
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:button];
}

// 创建一个空的按钮
+ (instancetype)itemWithNull{
    UIButton *button = [[UIButton alloc] init];
    button.size = CGSizeMake(60, 20);
    button.x = 10;
    return [[self alloc] initWithCustomView:button];
}

+ (instancetype)itemWithImage:(NSString *)image target:(id)target action:(SEL)action{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateHighlighted];
//    button.size = button.currentBackgroundImage.size;
    button.size = CGSizeMake(20, 20);

    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:button];

}



@end
