//
//  MessagePack.h
//  UDP
//
//  Created by kenny on 19/01/2017.
//  Copyright © 2017 honeywell. All rights reserved.
//

#import <Foundation/Foundation.h>
//static const Byte PAYLOAD_BIND_SERVER[] = {0x0};
//static const Byte REQUESTWIFILISTPAYLOAD[] = {0x67, 0x65, 0x74, 0x57, 0x69, 0x66, 0x69, 0x4c, 0x69, 0x73, 0x74};
//static const Byte RESPONSEWIFILISTPAYLOAD[] = {0x00,
//    0x43, 0x47, 0x4f, 0x45, 0x54, 0x2d, 0x32, 0x36, 0x30, 0x30, 0x32, 0x34,
//    0x0a,
//    0x43, 0x47, 0x4f, 0x50, 0x2d, 0x39, 0x36, 0x30, 0x30, 0x30, 0x34,
//    0x0a,
//    0x59, 0x55, 0x4e, 0x45, 0x45, 0x43, 0x2d, 0x34, 0x31, 0x30, 0x30, 0x30, 0x32
//};

static const int Type_Bind = 26;
static const int Type_Request = 27;
static const int Type_Response = 28;

@interface MessagePack : NSObject
//@property (nonatomic, readonly) int length;
//
@property (nonatomic, readonly) int requestType;
//@property (nonatomic, readonly) Byte *bytes;
//@property (nonatomic, readonly) int payloadLen;
@property (nonatomic, readonly) int ack;
//
//@property (nonatomic, readonly) Byte *payload;

- (instancetype)initWithBytes:(Byte*)bytes;
- (instancetype)initWithPayload_len:(int)payload_len type:(int)type ack:(int)ack payload:(Byte *)payload;

- (instancetype)wrapServerBind;
- (instancetype)wrapGetWifiList;
- (instancetype)wrapConnectWifiWithssid:(NSString *)ssid password:(NSString *)ssid;
- (instancetype)wrapDisconnectWifi;
- (instancetype)wrapGetConnectWifiInfo;

- (NSArray *)wifiList;
- (NSData *)data;
- (NSString *)message;

//// test
//- (void)print;
//- (void)connectPackage:(NSString *)ssid :(NSString *)password;
@end
