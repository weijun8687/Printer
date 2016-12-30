//
//  SettingPrinterVC.m
//  StoreOrder
//
//  Created by WJ on 16/8/30.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "SettingPrinterVC.h"
#import "AppDelegate.h"
#import "PrinterList.h"

extern CBPeripheral *activeDevice;

@interface SettingPrinterVC ()

@property (nonatomic, strong) UIView *viewFirst;
@property (nonatomic, strong) UILabel *lbPrinterName;

@property (nonatomic, strong) UIView *viewSecond;
@property (nonatomic, strong) UILabel *lbCount;

@property (nonatomic, strong) UIView *viewThird;

@property (nonatomic, strong) UIButton *btnTest;
@property (nonatomic, strong) AppDelegate *app;

// 打印模型
@property (nonatomic, strong) UIButton *btnPrint;


@end

@implementation SettingPrinterVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"打印机";
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (activeDevice && self.app.openBlueTooth) {

        self.lbPrinterName.text = [USER_DEFAULT objectForKey:POSNAME];
    }else{
        self.lbPrinterName.text = @"未连接";
    }
}


- (void)initSubViews{
    if (!self.viewFirst) {
        self.viewFirst = [UIView new];
        [self.view addSubview:self.viewFirst];
        [self.viewFirst remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(50);
            make.top.equalTo(self.view.top).offset(64);
        }];
        
        UIImageView *iv1 = [UIImageView new];
        [self.viewFirst addSubview:iv1];
        [iv1 remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(15);
            make.centerY.equalTo(self.viewFirst.centerY);
            make.left.equalTo(self.viewFirst.left).offset(10);
        }];
        [iv1 setImage:[UIImage imageNamed:@"蓝牙-(1)"]];
        
        UILabel *lbTitle = [UILabel new];
        [self.viewFirst addSubview:lbTitle];
        [lbTitle remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iv1.right).offset(10);
            make.centerY.equalTo(iv1.centerY);
            make.width.greaterThanOrEqualTo(20);
            make.height.equalTo(20);
        }];
        lbTitle.textColor = [UIColor colorFromString:@"#333"];
        lbTitle.text = @"蓝牙打印机";
        lbTitle.font = [UIFont systemFontOfSize:14.0];
        
        UIImageView *ivRight = [UIImageView new];
        [self.viewFirst addSubview:ivRight];
        [ivRight remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(16);
            make.centerY.equalTo(self.viewFirst.centerY);
            make.right.equalTo(self.viewFirst.right).offset(-20);
        }];
        [ivRight setImage:[UIImage imageNamed:@"icon_cell_right_arrow"]];
        
        self.lbPrinterName = [UILabel new];
        [self.viewFirst addSubview:self.lbPrinterName];
        [self.lbPrinterName remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(ivRight.left).offset(-10);
            make.centerY.equalTo(iv1.centerY);
            make.width.greaterThanOrEqualTo(20);
            make.height.equalTo(20);
        }];
        self.lbPrinterName.textColor = [UIColor colorFromString:@"#999"];
        
        if (activeDevice && self.app.openBlueTooth) {
             self.lbPrinterName.text = activeDevice.name;
        }else{
            self.lbPrinterName.text = @"未连接";
        }
        
       
        self.lbPrinterName.font = [UIFont systemFontOfSize:12.0];
        
        UIImageView *ivLine = [UIImageView new];
        [self.viewFirst addSubview:ivLine];
        [ivLine remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.viewFirst.left).offset(10);
            make.right.equalTo(self.viewFirst.right).offset(-10);
            make.height.equalTo(1);
            make.bottom.equalTo(self.viewFirst.bottom);
        }];
        ivLine.image = [UIImage imageNamed:@"横线"];
        
        UIButton *btnCoverFirst = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.viewFirst addSubview:btnCoverFirst];
        [btnCoverFirst remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.viewFirst);
        }];
        btnCoverFirst.tag = 0;
        [btnCoverFirst addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!self.btnPrint) {
        self.btnPrint = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:self.btnPrint];
        
        [self.btnPrint remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.left).offset(30);
            make.right.equalTo(self.view.right).offset(-30);
            make.height.equalTo(45);
            
            make.bottom.equalTo(self.view.bottom).offset(-160);
        }];
        
        [self.btnPrint setTitle:@"打印" forState:UIControlStateNormal];
        [self.btnPrint setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnPrint setBackgroundColor:[UIColor blueColor]];
        [self.btnPrint addTarget:self action:@selector(print) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)print{
    
    if (activeDevice && self.app.openBlueTooth) {

        // 打印
        [self.app.print printText];
    
    }else{
        // 没有连接打印机或者蓝牙没打开
        [self.navigationController pushViewController:[PrinterList new] animated:YES];
        
    }

}

- (void)clickButton:(UIButton *)button{
    if (button.tag == 0) {
        // 点击了第一行
        [self.navigationController pushViewController:[PrinterList new] animated:YES];
        
    }

}


@end
