//
//  MyPrinter.h
//  StoreOrder
//
//  Created by WJ on 16/9/26.
//  Copyright © 2016年 WJ. All rights reserved.
//  关于打印机

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^DEVICEBLOCK)(NSMutableArray *);

@interface MyPrinter : NSObject


@property (nonatomic, strong) DEVICEBLOCK block;
// 查找蓝牙设备
- (void)findDevices;

- (void)didSelectDevice:(CBPeripheral *)device;

// 测试打印
- (void)printText;

// 实际打印
//- (void)printOrder:(OrderDetailModel *)model;

@end
