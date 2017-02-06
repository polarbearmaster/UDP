//
//  CommunicationManager.m
//  UDP
//
//  Created by kenny on 16/3/5.
//  Copyright © 2016年 honeywell. All rights reserved.
//

#import "CommunicationManager.h"
#import "GCDAsyncUdpSocket.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <stdio.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CrcUtils.h"
#import "MessagePack.h"

#define kBroadcastHost          @"255.255.255.255"
#define kUDPPort                8856
#define kUDPHeader              @"UDP"


@interface CommunicationManager() <GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *_socket;
    
    NSString *ip;
    uint16_t port;
}
@property (strong, nonatomic) UDPCallback callback;
@property (assign, nonatomic) NSInteger timeout;
@property (strong, nonatomic) NSData *sendData;

@property (nonatomic, strong) MessagePack *receivedMp;
@property (nonatomic, strong) MessagePack *sendMp;

@end
@implementation CommunicationManager

-(instancetype)init
{
    if (self = [super init]) {
        //[self convertStringToASCII:@"connectWifi?ssid=test&password=1234567890"];
    }
    return self;
}

- (void)startLinkWithTimeout:(NSInteger)timeout callback:(UDPCallback)callback {
    self.timeout = timeout;
    self.callback = callback;
    [self connectUDP];
}

- (void)stopLink {
    [self disconnectUDP];
    
    if (self.callback) {
        self.callback(UDPErrorTypeCancel);
    }
    self.callback = nil;
}

- (void)connectUDP {
    if (_socket) {
        [self disconnectUDP];
    }
    
    //NSLog(@"ip: %@", [self getIPAddress]);
    
    _socket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![_socket bindToPort:kUDPPort error:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Restart App!!!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Error binding: %@", error);
        return;
    }
    
//    if (![_socket receiveOnce:&error]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Restart App!!!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        NSLog(@"Error receiving: %@", error);
//        return;
//    }
    
    if (![_socket beginReceiving:&error])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Restart App!!!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
//    if (![_socket enableBroadcast:YES error:&error]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Restart App!!!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        NSLog(@"Error enableBroadcast: %@", error);
//        return;
//    }
    //sendUDPTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendUDPData:) userInfo:nil repeats:YES];
    

}

- (void)getWifiList {
    self.sendMp = [self.sendMp wrapGetWifiList];
    [self printWithSendData:[self.sendMp data]];
    
    [_socket sendData:[self.sendMp data] toHost:ip port:port withTimeout:-1 tag:99];
}

- (void)connectWifi:(NSString *)ssid password:(NSString *)password {
    self.sendMp = [self.sendMp wrapConnectWifiWithssid:ssid password:password];
    [self printWithSendData:[self.sendMp data]];
    
    [_socket sendData:[self.sendMp data] toHost:ip port:port withTimeout:-1 tag:99];
}

- (void)disconnectWifi {
    self.sendMp = [self.sendMp wrapDisconnectWifi];
    [self printWithSendData:[self.sendMp data]];
    
    [_socket sendData:[self.sendMp data] toHost:ip port:port withTimeout:-1 tag:99];
}

- (void)getConnectWifiInfo {
    self.sendMp = [self.sendMp wrapGetConnectWifiInfo];
    [self printWithSendData:[self.sendMp data]];
    
    [_socket sendData:[self.sendMp data] toHost:ip port:port withTimeout:-1 tag:99];
}

- (void)sendUDPData:(NSTimer *)timer {
    //NSLog(@"send data: %@", self.sendData);
    
    if (self.sendData) {
        [_socket sendData:self.sendData toHost:[self getIPAddress] port:0 withTimeout:-1 tag:100];
    }
}

- (void)disconnectUDP {
    [_socket close];
    _socket.delegate = nil;
    _socket = nil;
}

// MARK: Socket Delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"address: %@", address);
    NSString *message = [NSString stringWithFormat:@"[add]: %@", [[NSString alloc]initWithData:address encoding:NSUTF8StringEncoding]];

}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    NSLog(@"error: %@", error);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    //[_delegate output:[self getIPAddress]];

    
    ip = [GCDAsyncUdpSocket hostFromAddress:address];
    port = [GCDAsyncUdpSocket portFromAddress:address];
    
    //[_delegate outputInReTV:[NSString stringWithFormat:@"Address：ip:%@  port:%d",ip,port]];
    
    //[self printWithReceiveData:data];
    
    [self dealWithASCIIData:data];
}

- (NSString *)getIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


// MARK: Aux Methods
- (void)dealWithASCIIData:(NSData*)data {
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    self.receivedMp = [[MessagePack alloc]initWithBytes:byteData];
    //[_delegate outputInReTV:[NSString stringWithFormat:@"[requestType]:%d\n[ack]=%d\n", _receivedMp.requestType,_receivedMp.ack]];
    
    // 检查request_type
    if (_receivedMp.requestType == Type_Bind) {
        // 返回包
        self.sendMp = [self.receivedMp wrapServerBind];
        // 打印
        //[self printWithSendData:[_sendMp data]];
        // 发送
        [_socket sendData:[_sendMp data] toHost:ip port:port withTimeout:-1 tag:99];
    } else if (_receivedMp.requestType == Type_Response) {
        
        [_delegate outputInReTV:[NSString stringWithFormat:@"[requestType]:%d\n[ack]=%d\n", _receivedMp.requestType,_receivedMp.ack]];
        [self printWithReceiveData:data];
        
        // 判断是否是请求wifi列表
        if ([_delegate getActionType] == 1) {
            NSArray *lists = [self.receivedMp wifiList];
            [_delegate showWifis:lists];
        } else {
            [_delegate showMessage:[self.receivedMp message]];
        }        
    }
}

- (void)printWithReceiveData:(NSData *)data {
    NSMutableString *ms = [[NSMutableString alloc]init];
    for (NSUInteger i = 0; i < [data length]; i++) {
        unsigned char byte;
        [data getBytes:&byte range:NSMakeRange(i, 1)];
        [ms appendString:[NSString stringWithFormat:@"%x ", byte]];
    }
    
    [_delegate outputInReTV:[NSString stringWithFormat:@"[received]: %@", ms]];
}

- (void)printWithSendData:(NSData *)data {
    NSMutableString *ms = [[NSMutableString alloc]init];
    for (NSUInteger i = 0; i < [data length]; i++) {
        unsigned char byte;
        [data getBytes:&byte range:NSMakeRange(i, 1)];
        [ms appendString:[NSString stringWithFormat:@"%x ", byte]];
    }
    
    [_delegate outputInSeTV:[NSString stringWithFormat:@"[send]: %@\n", ms]];
}


@end
