//
//  DeviceDetailBaseController.m
//  YiLianGang
//
//  Created by Way_Lone on 2016/10/9.
//  Copyright © 2016年 Way_Lone. All rights reserved.
//

#import "DeviceDetailBaseController.h"


@interface DeviceDetailBaseController ()<SRWebSocketDelegate>

@property(nonatomic,strong) NSString *DeviceUrlStr;

@end

@implementation DeviceDetailBaseController
-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    [self.myActivityIndicatorView stopAnimating];
    [MBProgressHUD showSuccess:@"连接成功"];
    
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string{
    NSLog(@"%@",string);
    if ([string containsString:@"thing not online"]) {
        [ToastUtil showToast:@"设备不在线"];
    }
}
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data{
    NSLog(@"%@",data);
}
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"%@",error.userInfo);
    [self.myActivityIndicatorView stopAnimating];
    [MBProgressHUD showError:@"网络错误"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    if(self.navigationItem){
        UIFont *font = [UIFont systemFontOfSize:14];
        NSDictionary *dic = @{NSFontAttributeName:font,
                              NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationController.navigationBar.titleTextAttributes =dic;
        self.navigationItem.title = self.deviceInfo.thingName;
    }
    self.tableView.tableFooterView = [UIView new];
    self.myActivityIndicatorView = [[MyActivityIndicatorView alloc]initWithStr:@"连接中" imageColor:nil textColor:nil];
    [[UIApplication sharedApplication].keyWindow addSubview:_myActivityIndicatorView];
    // 动画开始
    [_myActivityIndicatorView startAnimating];
    
    
    //配置websocket
    if (self.deviceInfo) {
        self.DeviceUrlStr = self.deviceInfo.harborIp;
    }
    //截取ip
    NSRange range = [self.DeviceUrlStr rangeOfString:@":"];
    if (range.length>0) {
        self.DeviceUrlStr = [self.DeviceUrlStr substringWithRange:NSMakeRange(0, range.location)];
    }
    //加前缀
    if(![self.DeviceUrlStr containsString:@"ws://"]){
        self.DeviceUrlStr = [@"ws://" stringByAppendingString:self.DeviceUrlStr];
    }
    NSLog(@"%@",self.DeviceUrlStr);
    //加后缀
    self.DeviceUrlStr = [self.DeviceUrlStr stringByAppendingString:@":8999/IotHarborWebsocket"];
    self.webSocket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:self.DeviceUrlStr]];
    self.webSocket.delegate = self;
    [self.webSocket open];
    if (self.navigationController) {
        //左边
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftButton.frame = CGRectMake(0, 0, 60, 40);
        [leftButton setTitle:@"        " forState:UIControlStateNormal];
        [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        leftButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentCenter;
        [leftButton addTarget:self action:@selector(clickTopLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [leftView addSubview:leftButton];
        leftView.backgroundColor = [UIColor clearColor];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
        
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.webSocket close];
}
-(void)clickTopLeftButton:(UIButton*)button{
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
/**字典转json*/
-(NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
-(void)sendWebSocketStringWithParam:(NSDictionary*)param{
    
    NSString *sendStr = [self dictionaryToJson:param];
    NSError *error = [NSError new];
    NSLog(@"%@",sendStr);
    [self.webSocket sendString:sendStr error:&error];
    if (error.userInfo.allKeys.count>0) {
        NSLog(@"%@",error.userInfo);
        [MBProgressHUD showError:@"发送错误"];
    }
}

-(NSString *)imageAddExStr:(NSString *)imageStr{
    NSString *exStr = [imageStr pathExtension];
    NSString *temp = [imageStr stringByDeletingPathExtension];
    temp = [temp stringByAppendingString:@"1"];
    temp = [temp stringByAppendingPathComponent:exStr];
    if (![temp containsString:@"http://"]&&[temp containsString:@"http:/"]) {
        temp = [temp stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
    }
    return temp;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
