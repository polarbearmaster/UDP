//
//  ViewController.m
//  UDP
//
//  Created by kenny on 16/3/5.
//  Copyright © 2016年 honeywell. All rights reserved.
//

#import "ViewController.h"
#import "CommunicationManager.h"

typedef NS_ENUM(NSInteger, ActionType) {
    Action_GetWifiList = 1,
    Action_ConnectWifi,
    Action_DisconnectWifi,
    Action_GetConnectWifiInfo
};


#define kTimeout                30

@interface ViewController ()<CommunicationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CommunicationManager *communicationManager;
@property (weak, nonatomic) IBOutlet UITextView *receiveTextView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UITextView *sendTextView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (nonatomic, strong) NSArray *wifis;
@property (nonatomic, strong) NSString *ssid;

@property (nonatomic) ActionType actionType;

- (IBAction)getWifiList:(id)sender;
- (IBAction)connectWifi:(id)sender;
- (IBAction)disconnectWifi:(id)sender;
- (IBAction)getConnectWifiInfo:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.communicationManager = [[CommunicationManager alloc]init];
    self.communicationManager.delegate = self;
    self.wifis = [NSArray new];
    
    [self.communicationManager startLinkWithTimeout:kTimeout callback:^(UDPErrorType error) {
        switch (error) {
            case UDPErrorTypeCancel:
                break;
            case UDPErrorTypeSuccess:
                break;
            case UDPErrorTypeInvalid:
                break;
            case UDPErrorTypeTimeOut:
                break;
            default:
                break;
        }
    }];
}

// MARK: UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wifis.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"kCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    cell.textLabel.text = self.wifis[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.ssid = self.wifis[indexPath.row];
}

// MARK: UDP Delegate Methods
- (void)outputInReTV:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = _receiveTextView.text;
        _receiveTextView.text = [NSString stringWithFormat:@"%@\n%@", text,msg];
         [_receiveTextView scrollRangeToVisible:NSMakeRange(self.receiveTextView.text.length, 0)];
    });
}

- (void)outputInSeTV:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = _sendTextView.text;
        _sendTextView.text = [NSString stringWithFormat:@"%@\n%@", text,msg];
        [_sendTextView scrollRangeToVisible:NSMakeRange(_sendTextView.text.length, 0)];
    });
}

- (void)showWifis:(NSArray *)wifis {
    self.wifis = wifis;
    [self.listTableView reloadData];
}

- (void)showMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        _messageTextView.text = msg;
    });
}

-(int)getActionType {
    return self.actionType;
}

// MARK: IBAction Methods
- (IBAction)getWifiList:(id)sender {
    self.actionType = Action_GetWifiList;
    [self.communicationManager getWifiList];
}

- (IBAction)connectWifi:(id)sender {
    self.actionType = Action_ConnectWifi;
    if (self.ssid.length > 0) {
        [self.communicationManager connectWifi:self.ssid password:@"1234567890"];//yuneec123
    }
}

- (IBAction)disconnectWifi:(id)sender {
    self.actionType = Action_DisconnectWifi;
    [self.communicationManager disconnectWifi];
}

- (IBAction)getConnectWifiInfo:(id)sender {
    self.actionType = Action_GetConnectWifiInfo;
    [self.communicationManager getConnectWifiInfo];
}

@end
