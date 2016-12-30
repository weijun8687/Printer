//
//  PrinterListCell.m
//  StoreOrder
//
//  Created by WJ on 16/8/30.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "PrinterListCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PrinterListCell ()

// 打印机名
@property (strong, nonatomic) IBOutlet UILabel *lbName;

// 打印机状态
@property (strong, nonatomic) IBOutlet UILabel *lbState;

@end

@implementation PrinterListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)init{
    if (self == [super init]) {
        NSArray * arr = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PrinterListCell class]) owner:self options:nil];
        if (arr.count > 0) {
            self = [arr objectAtIndex:0];
        }
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.lbName.textColor = [UIColor colorFromString:@"#333"];
    self.lbState.textColor = [UIColor colorFromString:@"#333"];
    return self;
}

- (void)setCellInfo:(CBPeripheral *)model{
    
    self.lbName.text = model.name;
    
        if(model.state==CBPeripheralStateConnected){
            self.lbState.text = @"断开";
        }
        else {
            self.lbState.text = @"连接";
        }
}


@end
