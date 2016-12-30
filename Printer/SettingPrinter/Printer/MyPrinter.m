//
//  MyPrinter.m
//  StoreOrder
//
//  Created by WJ on 16/9/26.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "MyPrinter.h"

//for issc
static NSString *const kWriteCharacteristicUUID_cj = @"49535343-8841-43F4-A8D4-ECBE34729BB3";
static NSString *const kReadCharacteristicUUID_cj = @"49535343-1E4D-4BD9-BA61-23C647249616";
static NSString *const kServiceUUID_cj = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";

//for ivt
static NSString *const kFlowControlCharacteristicUUID = @"ff03";
static NSString *const kWriteCharacteristicUUID = @"ff02";
static NSString *const kReadCharacteristicUUID = @"ff01";
static NSString *const kServiceUUID = @"ff00";

CBPeripheral *activeDevice;
CBCharacteristic *activeWriteCharacteristic;
CBCharacteristic *activeReadCharacteristic;
CBCharacteristic *activeFlowControlCharacteristic;
int mtu = 20;
int credit = 0;
int response = 1;

int cjFlag=1;

int cmdaaa = 0;
NSThread *thread = NULL;

@interface MyPrinter ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) AppDelegate *app;
// 蓝牙管理器
@property(strong,nonatomic)CBCentralManager *centralManager;
// 蓝牙
@property(strong,nonatomic)CBPeripheral *selectedPeripheral;
// 存放查找的设备
@property(strong,nonatomic)NSMutableArray *mArrDevice;

@end

@implementation MyPrinter

- (instancetype)init{
    if (self = [super init]) {
        
        self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark 查找蓝牙设备
- (void)findDevices{
    //    if (self.selectedPeripheral.state==CBPeripheralStateConnected){
    //        [self.centralManager cancelPeripheralConnection:self.selectedPeripheral];
    //    }
    
    //清空当前设备列表
    if ( self.mArrDevice == nil) {
        self.mArrDevice = [[NSMutableArray alloc]init];
    } else {
        //        [self.mArrDevice removeAllObjects];
        
        //        for (CBPeripheral * tempPeri in self.mArrDevice) {
        //            if (tempPeri.state != CBPeripheralStateConnected) {
        //                [self.mArrDevice removeObject:tempPeri];
        //            }
        //        }
        NSInteger arrCount = self.mArrDevice.count;
        for (int i = 0; i < arrCount; i++) {
            CBPeripheral * tempPeri = self.mArrDevice[i];
            if (tempPeri.state != CBPeripheralStateConnected) {
                NSLog(@"%@",tempPeri.name);
                [self.mArrDevice removeObject:tempPeri];
                arrCount--;
                i--;
            }
        }
        if (self.block) {
            self.block(self.mArrDevice);
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        // 只查找符合自己型号的打印机
        //        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopScanPeripheral) userInfo:nil repeats:NO];
    });
    
    if (self.block) {
        self.block(self.mArrDevice);
    }
}

#pragma mark 停止查询
- (void)stopScanPeripheral{
    [self.centralManager stopScan];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
    
    return YES;
}

#pragma  mark -- CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * state = nil;
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            self.app.openBlueTooth = NO;
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            self.app.openBlueTooth = NO;
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            self.app.openBlueTooth = NO;
            [NOTIFICATION_CENTER postNotificationName:BLUETOOLSTATE object:nil];
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"work";
            self.app.openBlueTooth = YES;
            [NOTIFICATION_CENTER postNotificationName:BLUETOOLSTATE object:nil];
            
            break;
        case CBCentralManagerStateUnknown:
            self.app.openBlueTooth = NO;
            break;
        default:
            self.app.openBlueTooth = NO;
            break;
            ;
    }
    NSLog(@"Central manager state: %@", state);
}

#pragma mark 查找到打印机执行的代理方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (peripheral)
    {
        
        if (![self.mArrDevice containsObject:peripheral]){
            if (peripheral.name.length > 0) {
                [self.mArrDevice  addObject:peripheral];
                
            }
            //            [self.mArrDevice  addObject:peripheral];
        }
        
        //        NSString *posName = [USER_DEFAULT objectForKey:POSNAME];
        NSString *posIdentifier = [USER_DEFAULT objectForKey:POSIDENTIFIER];
        if (posIdentifier.length > 0) {
            if ( [peripheral.identifier.UUIDString isEqualToString:posIdentifier] ){
                
                
                self.selectedPeripheral = peripheral;
                [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
                
            }
            
        }
        
        //            self.peripheral = peripheral;
        //发现设备后即可连接该设备 调用完该方法后会调用代理CBCentralManagerDelegate的- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral表示连接上了设别
        //如果不能连接会调用 - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
        //[centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : YES}];
        
        
        
        
        if (self.block) {
            self.block(self.mArrDevice);
        }
    
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"has connected");
    
    //[mutableData setLength:0];
    [USER_DEFAULT setObject:peripheral.name forKey:POSNAME];
    [USER_DEFAULT setObject:peripheral.identifier.UUIDString forKey:POSIDENTIFIER];
    
    self.selectedPeripheral.delegate = self;
    //此时设备已经连接上了  你要做的就是找到该设备上的指定服务 调用完该方法后会调用代理CBPeripheralDelegate（现在开始调用另一个代理的方法了）的
    //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
    
    // qzfeng begin 2016/05/10
    [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID_cj]]];
    // qzfeng end 2016/05/10
    if (self.block) {
        self.block(self.mArrDevice);
    }
    
}

#pragma mark 断开连接执行的代理方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    [USER_DEFAULT removeObjectForKey:POSNAME];
    [USER_DEFAULT removeObjectForKey:POSIDENTIFIER];
    //self.peripheral = nil;
    [self alertMessage:@"连接断开！"];
    activeDevice = nil;
    
}

#pragma mark 连接失败执行的代理方法
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //此时连接发生错误
    NSLog(@"connected periphheral failed");
    [USER_DEFAULT removeObjectForKey:POSNAME];
    [USER_DEFAULT removeObjectForKey:POSIDENTIFIER];
    
    [self alertMessage:@"连接失败！"];
}

#pragma mark -- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:error{
    if (error==nil)
    {
        NSLog(@"Write edata failed!");
        return;
    }
    NSLog(@"Write edata success!");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if (error==nil){
        //在这个方法中我们要查找到我们需要的服务  然后调用discoverCharacteristics方法查找我们需要的特性
        //该discoverCharacteristics方法调用完后会调用代理CBPeripheralDelegate的
        //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        for (CBService *service in peripheral.services){
            
            if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]){
                
                cjFlag=0;           // qzfeng 2016/05/10
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                [peripheral discoverCharacteristics:nil forService:service];
            }else if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID_cj]]){
                
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                cjFlag=1;
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error==nil) {
        //在这个方法中我们要找到我们所需的服务的特性 然后调用setNotifyValue方法告知我们要监测这个服务特性的状态变化
        //当setNotifyValue方法调用后调用代理CBPeripheralDelegate的- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        for (CBCharacteristic *characteristic in service.characteristics){
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]){
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]]){
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeReadCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFlowControlCharacteristicUUID]]) {
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeFlowControlCharacteristic = characteristic;
                credit = 0;
                response = 1;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID_cj]]) {
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID_cj]]) {
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeReadCharacteristic = characteristic;
            }
            
            activeDevice = peripheral;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateNotificationStateForCharacteristic!");
    if (error==nil){
        //调用下面的方法后 会调用到代理的- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value;
    NSLog(@"read data=%@!",data);
    if (characteristic == activeFlowControlCharacteristic) {
        NSData * data = [characteristic value];
        NSUInteger len = [data length];
        int bytesRead = 0;
        if (len > 0) {
            unsigned char * measureData = (unsigned char *) [data bytes];
            unsigned char field = * measureData;
            measureData++;
            bytesRead++;
            if(field == 2){
                unsigned char low  = * measureData;
                measureData++;
                mtu =  low + (* measureData << 8);
            }
            if(field == 1){
                if(credit < 5) {
                    credit += * measureData;
                }
            }
        }
    }
}


// 提示
-(void) alertMessage:(NSString *)msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示"
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"关闭"
                                         otherButtonTitles:nil];
    [alert show];
}

/*
#pragma mark 实际打印,传一个 model
- (void)printOrder:(OrderDetailModel *)model{
    if(cjFlag==0){          // qzfeng 2016/05/10
        if (thread == NULL) {
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(printPageThreadProcModel:) object:model];
            [thread start];
        } else {
            NSLog(@"Already running");
        }
        
    }else{
        [self printModel:model];
    }
}

- (void)printPageThreadProcModel:(OrderDetailModel *)model{
    [self printModel:model];           // qzfeng 2016/05/10
    
    thread = NULL;
    
}

- (void)printModel:(OrderDetailModel *)model{
    if (activeDevice) {
        activeDevice.delegate = self;
    }
    
    int temp = 1;
    NSString *str = [USER_DEFAULT objectForKey:PRINTCOUNT];
    if (str.length == 0 || str == nil || [str isEqualToString:@"1"]) {
        temp = 1;
        
    }else{
        temp = [[USER_DEFAULT objectForKey:PRINTCOUNT] intValue];
    }
    
    for (int i = 0; i < temp; i++) {
        
        
        [SPRTPrint printAlignLeft];
        [SPRTPrint setLineHeight:100];
        // 商户头广告语
        if (model.header_slogan.length > 0) {
            [SPRTPrint printTxt:[NSString stringWithFormat:@"%@\n",model.header_slogan]];
        }
        
        [SPRTPrint printAlignCenter];
        
        // 订单号
        NSString *strOrderCode = [model.order_code substringFromIndex:model.order_code.length - 4];
        [SPRTPrint printTxt:[NSString stringWithFormat:@"************** #%@ 易吃外卖  **************\n",strOrderCode]];
        
        // 店铺名
        [SPRTPrint printTxt:[NSString stringWithFormat:@"%@【%@】\n",model.tenancy_name, model.storeName]];
        
        [SPRTPrint restoreDefaultLineHeight];
        // 设置双倍字体大小
        [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:YES doubleWidth:NO underline:NO];
        [SPRTPrint setChineseWordFormat:YES doubleWidth:NO underline:NO];
        
        // 地址
        [SPRTPrint printAlignLeft];
        [SPRTPrint printTxt:[NSString stringWithFormat:@"定位地址:%@\n",model.address]];
        
        [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
        [SPRTPrint setChineseWordFormat:NO doubleWidth:NO underline:NO];
        [SPRTPrint printTxt:@"\n"];
        [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:YES doubleWidth:NO underline:NO];
        [SPRTPrint setChineseWordFormat:YES doubleWidth:NO underline:NO];
        
        // 电话
        [SPRTPrint printTxt:[NSString stringWithFormat:@"收货电话:%@\n",model.consigner_phone]];
        
        [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
        [SPRTPrint setChineseWordFormat:NO doubleWidth:NO underline:NO];
        [SPRTPrint printTxt:@"\n"];
        [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:YES doubleWidth:NO underline:NO];
        [SPRTPrint setChineseWordFormat:YES doubleWidth:NO underline:NO];
        
        // 姓名
        NSString *strSex = [model.sex isEqualToString:@"1"]? @"先生" : @"女士";
        [SPRTPrint printTxt:[NSString stringWithFormat:@"用户姓名:%@ (%@)\n",model.consigner,strSex]];
        
        // 恢复默认字体大小
        [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
        [SPRTPrint setChineseWordFormat:NO doubleWidth:NO underline:NO];
        
        [SPRTPrint printTxt:@"\n"];
        
        [SPRTPrint setLineHeight:100];
        // 下单时间
        [SPRTPrint printTxt:[NSString stringWithFormat:@"下单时间:%@\n",[NSString stringWithDateSecondsForPrinter:model.single_time]]];
        
        // 送达时间
        NSString *sendTime = nil;
        if ([model.send_immediately isEqualToString:@"1"]) {
            sendTime = [NSString stringWithFormat:@"立即送达(%@)",model.send_time];
        }else{
            sendTime = model.send_time;
        }
        [SPRTPrint printTxt:[NSString stringWithFormat:@"送达时间:%@\n",sendTime]];
        
        [SPRTPrint setLineHeight:80];
        
        [SPRTPrint printAlignCenter];
        [SPRTPrint printTxt:@"--------------------菜品信息--------------------\n"];
        
        [SPRTPrint printAlignLeft];
        // 设置行高
        
        NSArray *arrOrder = model.items;
        for (int i = 0; i < arrOrder.count; i++) {
            
            ZFS_DetailItem *item = arrOrder[i];
            
            if ([item.is_combo isEqualToString:@"N"]) {
                // 单品
                
                NSString *str = [self stringWithString1:item.item_name proportion1:0.5 isSubTitle:NO string2:[NSString stringWithFormat:@"x%@",item.number] proportion2:0.3 string3:[NSString stringWithFormat:@"  ￥%.2lf",[item.price floatValue]] proportion3:0.2];
                [SPRTPrint printTxt:str];
                
            }else{
                // 套餐
                
                [SPRTPrint printTxt:[self stringWithString1:item.item_name proportion1:0.5 isSubTitle:NO string2:[NSString stringWithFormat:@"x%@",item.number] proportion2:0.3 string3:[NSString stringWithFormat:@"  ￥%.2lf",[item.price floatValue]] proportion3:0.2]];
                
                for (int j = 0; j < item.combo.count; j++) {
                    ComboSub *tempComb = item.combo[j];
                    
                    [SPRTPrint printTxt:[self stringWithString1:[NSString stringWithFormat:@"%@",tempComb.item_name] proportion1:0.5 isSubTitle:YES string2:[NSString stringWithFormat:@"x%@",tempComb.combo_num] proportion2:0.3 string3:nil proportion3:0]];
                }
                
            }
        }
        
        
        [SPRTPrint printAlignCenter];
        [SPRTPrint printTxt:@"----------------------其他----------------------\n"];
        
        // 餐盒费
        [SPRTPrint printAlignLeft];
        NSString *strBoxPrice = [NSString string];
        if ([model.package_box_price floatValue] > 0.001) {
            strBoxPrice = [NSString stringWithFormat:@"  ￥%.2lf",[model.package_box_price floatValue]];
        }else{
            strBoxPrice = @"  ￥0.00";
        }
        [SPRTPrint printTxt:[self stringWithString1:@"餐盒费" proportion1:0.8 isSubTitle:NO string2:strBoxPrice proportion2:0.2 string3:nil proportion3:0]];
        
        // 配送费
        [SPRTPrint printAlignLeft];
        [SPRTPrint printTxt:[self stringWithString1:@"配送费" proportion1:0.8 isSubTitle:NO string2:[NSString stringWithFormat:@"  ￥%.2lf",[model.meals floatValue]] proportion2:0.2 string3:nil proportion3:0]];
        
        
        // 活动
        [SPRTPrint printAlignLeft];
        
        if (model.activity.count > 0) {
            // 优惠
            for (Activity *act in model.activity) {
                [SPRTPrint printTxt:[self stringWithString1:[NSString stringWithFormat:@"[%@]",act.discount_desc] proportion1:0.8 isSubTitle:NO string2:[NSString stringWithFormat:@"-￥%@",act.discount_fee] proportion2:0.2 string3:nil proportion3:0]];
            }
        }
        
        // 备注
        [SPRTPrint printAlignLeft];
        if (model.remark.length > 0) {
            [SPRTPrint printTxt:[NSString stringWithFormat:@"备注:%@\n",model.remark]];
        }else{
            [SPRTPrint printTxt:[NSString stringWithFormat:@"备注:无\n"]];
        }
        
        [SPRTPrint printAlignLeft];
        if (model.invoice_title.length > 0) {
            [SPRTPrint printTxt:[NSString stringWithFormat:@"发票:%@\n",model.invoice_title]];
        }else{
            [SPRTPrint printTxt:[NSString stringWithFormat:@"发票:无\n"]];
        }
        
        [SPRTPrint printAlignCenter];
        [SPRTPrint printTxt:@"-----------------------------------------------\n"];
        
        [SPRTPrint printAlignLeft];
        NSString *strPayment = [NSString string];
        if ([model.payment_state isEqualToString:@"1"]) {
            // 已支付
            strPayment = @"(已支付)";
        }else if ([model.payment_state isEqualToString:@"0"]){
            // 未支付
            strPayment = @"(未支付)";
        }else if ([model.payment_state isEqualToString:@"2"]){
            // 已退款
            strPayment = @"(已退款)";
        }
        [SPRTPrint printTxt:[NSString stringWithFormat:@"原价:￥%.2lf     %@\n",[model.total_money floatValue],strPayment]];
        
        
        [SPRTPrint printAlignCenter];
        
        [SPRTPrint printTxt:@"***********************************************\n"];
        
        [SPRTPrint printAlignLeft];
        
        // 商户尾广告语
        if (model.footer_slogan1.length > 0) {
            [SPRTPrint printTxt:[NSString stringWithFormat:@"%@\n",model.footer_slogan1]];
        }
        
        if (model.footer_slogan2.length > 0) {
            [SPRTPrint printTxt:[NSString stringWithFormat:@"%@\n",model.footer_slogan2]];
        }
        // 恢复行高
        [SPRTPrint restoreDefaultLineHeight];
        
        [SPRTPrint cutPaper:65 feed_distance:8];
    }
    
}
*/




#pragma mark 下面的所有代码是测试打印
- (void)printText{
    
    if(cjFlag==0){          // qzfeng 2016/05/10
        if (thread == NULL) {
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(printPageThreadProc) object:nil];
            [thread start];
        } else {
            NSLog(@"Already running");
        }
        
    }else{
        [self print];
    }
}

- (void)printPageThreadProc {
    
    [self print];           // qzfeng 2016/05/10
    
    thread = NULL;
}

- (void)print{
    
    if (activeDevice) {
        activeDevice.delegate = self;
    }
    
    
        
    [SPRTPrint printAlignCenter];
    [SPRTPrint printTxt:@"商户广告语\n\n"];
    
    [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:YES doubleWidth:YES underline:NO];
    [SPRTPrint setChineseWordFormat:YES doubleWidth:YES underline:NO];
    [SPRTPrint printTxt:@"**** #0260  易吃外卖  ****\n"];
    
    [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
    [SPRTPrint setChineseWordFormat:NO doubleWidth:NO underline:NO];
    
    [SPRTPrint printTxt:@"\n店铺名称【门店名】\n\n"];
    
    [SPRTPrint printAlignLeft];
    [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:YES doubleWidth:YES underline:NO];
    [SPRTPrint setChineseWordFormat:YES doubleWidth:YES underline:NO];
    [SPRTPrint printTxt:@"详细地址:\n"];
    [SPRTPrint printTxt:@"收货电话:12345678901\n"];
    
    [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
    [SPRTPrint setChineseWordFormat:NO doubleWidth:NO underline:NO];
    
    [SPRTPrint printTxt:@"用户姓名\n"];
    [SPRTPrint printTxt:@"下单时间:2016-09-12 12:15:36\n"];
    
    [SPRTPrint printAlignCenter];
    [SPRTPrint printTxt:@"--------------------菜品信息--------------------\n"];
    
    [SPRTPrint printTxt:[self stringWithString1:@"菜品名" proportion1:0.5 isSubTitle:NO string2:@"数量" proportion2:0.3 string3:@"单价" proportion3:0.2]];
    
    [SPRTPrint printTxt:@"\n\n\n"];
    [SPRTPrint cutPaper:65 feed_distance:8];
        
    
    
    
    //    // 设置行间距
    //    [SPRTPrint setLineHeight:255];
    //    // 恢复行间距
    //    [SPRTPrint restoreDefaultLineHeight];
}


- (void)didSelectDevice:(CBPeripheral *)device{
    
    CBPeripheral *tempDevice = nil;
    for (int i = 0; i < self.mArrDevice.count; i++) {
        CBPeripheral *temp = self.mArrDevice[i];
        
        if ([temp.name isEqualToString:device.name]) {
            tempDevice = temp;
        }
    }
    
    if(tempDevice.state==CBPeripheralStateConnected){
        [self.centralManager cancelPeripheralConnection:tempDevice];
        [USER_DEFAULT removeObjectForKey:POSNAME];
        [USER_DEFAULT removeObjectForKey:POSIDENTIFIER];
        
    }else{
        
        [self.centralManager stopScan];
        NSLog(@"stop scan");
        self.selectedPeripheral = tempDevice;
        [self.centralManager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
        [USER_DEFAULT setObject:device.name forKey:POSNAME];
        [USER_DEFAULT setObject:device.identifier.UUIDString forKey:POSIDENTIFIER];
    }
    
    if (self.block) {
        self.block(self.mArrDevice);
    }
    
}


/**
 设置打印格式
 
 @param string1    菜品名
 @param value1     所占比例
 @param isSubtitle 是否为套餐子项
 @param string2    份数
 @param value2     所占比例
 @param string3    价格
 @param value3     所占比例
 
 @return 整个菜的信息
 */
- (NSString *)stringWithString1:(NSString *)string1  proportion1:(CGFloat)value1 isSubTitle:(BOOL)isSubtitle string2:(NSString *)string2 proportion2:(CGFloat)value2 string3:(NSString *)string3 proportion3:(CGFloat)value3{
    
    CGFloat maxWidth = 320.0;
    
    if (isSubtitle) {
        string1 = [NSString stringWithFormat:@"    %@",string1];
    }
    
    while ([string1 sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}].width < maxWidth * value1) {
        string1 = [NSString stringWithFormat:@"%@ ",string1];
    }
    
    int count2 = 0;
    for (int i = 0; i < string1.length; i++) {
        NSString * obj = [string1 substringWithRange:NSMakeRange(i, 1)];
        NSLog(@"%@",obj);
        if ([obj isEqualToString:@" "]) {
            count2 ++;
        }
    }
    
    string1 = [string1 substringToIndex:string1.length - count2 / 2];
    
    if (string2.length > 0) {
        while ([string2 sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}].width < maxWidth * value2) {
            string2 = [NSString stringWithFormat:@"%@ ",string2];
        }
        
        count2 = 0;
        for (int i = 0; i < string2.length; i++) {
            NSString * obj = [string2 substringWithRange:NSMakeRange(i, 1)];
            NSLog(@"%@",obj);
            if ([obj isEqualToString:@" "]) {
                count2 ++;
            }
        }
        
        string2 = [string2 substringToIndex:string2.length - count2 / 2];
    }
    
    
    NSString *straa = [NSString string];
    if (string3.length > 0) {
        while ([string3 sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}].width < maxWidth * value3) {
            string3 = [NSString stringWithFormat:@"%@ ",string3];
        }
        
        count2 = 0;
        for (int i = 0; i < string3.length; i++) {
            NSString * obj = [string3 substringWithRange:NSMakeRange(i, 1)];
            NSLog(@"%@",obj);
            if ([obj isEqualToString:@" "]) {
                count2 ++;
            }
        }
        
        string3 = [string3 substringToIndex:string3.length - count2 / 2];
        
        straa = [NSString stringWithFormat:@"%@%@%@",string1,string2, string3];
        
        
    }else{
        straa = [NSString stringWithFormat:@"%@%@",string1,string2];
    }
    
    return [NSString stringWithFormat:@"%@\n",straa];
}

@end
