//
//  AppDelegate.h
//  Printer
//
//  Created by WJ on 16/12/28.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPrinter.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 蓝牙是否开启
@property (nonatomic, assign) BOOL openBlueTooth;
// 打印机
@property (nonatomic, strong) MyPrinter *print;


@end

