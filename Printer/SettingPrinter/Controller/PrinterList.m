//
//  PrinterList.m
//  StoreOrder
//
//  Created by WJ on 16/8/30.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "PrinterList.h"
#import "PrinterListCell.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"
@interface PrinterList () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *mySwitch;
@property (nonatomic, strong) AppDelegate *app;
@property (nonatomic, strong) NSMutableArray *arrDevice;

@end

@implementation PrinterList

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.arrDevice) {
        self.arrDevice = [NSMutableArray array];
    }
    
    self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.title = @"蓝牙打印机";
    [self setNavItem];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [NOTIFICATION_CENTER addObserver:self selector:@selector(changeBlueToolState) name:BLUETOOLSTATE object:nil];
    
    [self initSubViews];
    
}

- (void)changeBlueToolState{
    if (self.app.openBlueTooth) {
        
        [self.mySwitch setBackgroundImage:[UIImage imageNamed:@"按钮-已"] forState:UIControlStateNormal];
        
        [self.app.print findDevices];
        WS(ws)
        self.app.print.block = ^(NSMutableArray *arr){
            
            [ws.arrDevice removeAllObjects];
            
            [ws.arrDevice addObjectsFromArray:arr];
            [ws.tableView reloadData];
        };
    }else{
        [self.arrDevice removeAllObjects];
        [self.tableView reloadData];
        [self.mySwitch setBackgroundImage:[UIImage imageNamed:@"按钮-未"] forState:UIControlStateNormal];
        
    }

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self changeBlueToolState];
}

- (void)setNavItem{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemBackButtonWithTarget:self action:@selector(clickNavItem)];
}

- (void)clickNavItem{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initSubViews{
    
    
    UIView *viewSecond = [UIView new];
    [self.view addSubview:viewSecond];
    [viewSecond remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.top).offset(64);
        make.height.equalTo(50);
    }];
    viewSecond.backgroundColor = [UIColor whiteColor];
    
    UIImageView *ivMark = [UIImageView new];
    [viewSecond addSubview:ivMark];
    [ivMark remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewSecond.left).offset(10);
        make.width.height.equalTo(15);
        make.centerY.equalTo(viewSecond.centerY);
    }];
    [ivMark setImage:[UIImage imageNamed:@"蓝牙-(1)"]];
    
    UILabel *lbLanya = [UILabel new];
    [viewSecond addSubview:lbLanya];
    [lbLanya remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ivMark.right).offset(10);
        make.centerY.equalTo(viewSecond.centerY);
        make.height.equalTo(20);
        make.width.greaterThanOrEqualTo(10);
    }];
    lbLanya.text = @"蓝牙";
    lbLanya.textColor = [UIColor colorFromString:@"#333"];
    lbLanya.font = [UIFont systemFontOfSize:14.0];
    
    self.mySwitch = [UIButton buttonWithType:UIButtonTypeCustom];
    [viewSecond addSubview:self.mySwitch];
    [self.mySwitch remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewSecond.right).offset(-20);
        make.centerY.equalTo(viewSecond.centerY);
        make.height.equalTo(20);
        make.width.equalTo(40);
    }];
    [self.mySwitch addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
        [self.tableView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewSecond.bottom);
            make.left.right.bottom.equalTo(self.view);
        }];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
}

//- (void)clickButton:(UIButton *)button{
//
//    if ([button isSelected]) {
//        //
//        [button setImage:[UIImage imageNamed:@"单选按钮-副本"] forState:UIControlStateNormal];
//        [button setSelected:NO];
//    }else{
//        [button setImage:[UIImage imageNamed:@"单选选中"] forState:UIControlStateNormal];
//        [button setSelected:YES];
//
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrDevice.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PrinterListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PrinterListCell class])];
    if (!cell) {
        cell = [[PrinterListCell alloc] init];
    }
    CBPeripheral * device = [self.arrDevice objectAtIndex:indexPath.row];
//    cell.textLabel.text= device.name;
    
//    if(device.state==CBPeripheralStateConnected){
//        cell.detailTextLabel.text = @"断开";
//    }
//    else {
//        cell.detailTextLabel.text = @"连接";
//    }

    [cell setCellInfo:device];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    headView.backgroundColor = RGBCOLOR(240, 240, 240);
    UILabel *lbHeadTitle = [UILabel new];
    [headView addSubview:lbHeadTitle];
    [lbHeadTitle remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.left).offset(10);
        make.width.greaterThanOrEqualTo(10);
        make.height.equalTo(20);
        make.center.equalTo(headView);
    }];
    lbHeadTitle.textColor = [UIColor colorFromString:@"#333"];
    lbHeadTitle.text = @"打开蓝牙将可以与您的蓝牙打印机连接打印";
    lbHeadTitle.font = [UIFont systemFontOfSize:12.0];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


- (void)clickSwitch:(UIButton *)button{
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max) {
    // 使用xcode8 之前的版本打开需要换成下面一句代码
//    if (NSFoundationVersionNumber > 1299) {
        // do stuff for iOS 9 and newer
        
        ALERT_TITLE(@"提示", @"请到设置->蓝牙中设置");
    } else {
        // do stuff for older versions than iOS 9
        NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.app.print didSelectDevice:self.arrDevice[indexPath.row]];
    
}




@end
