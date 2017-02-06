//
//  MessagePack.m
//  UDP
//
//  Created by kenny on 19/01/2017.
//  Copyright © 2017 honeywell. All rights reserved.
//

#import "MessagePack.h"
#import "CrcUtils.h"

//static const Byte payload_bind_server[] = {0x55};
static const Byte FLAG = 0x55;
static const Byte HEADER[] = {0x55, 0x55};
//static const Byte REQUESTWIFILISTPAYLOAD[] = {0x67, 0x65, 0x74, 0x57, 0x69, 0x66, 0x69, 0x4c, 0x69, 0x73, 0x74};
//static const Byte RESPONSEWIFILISTPAYLOAD[] = {0x00,
//    0x43, 0x47, 0x4f, 0x45, 0x54, 0x2d, 0x32, 0x36, 0x30, 0x30, 0x32, 0x34,
//    0x0a,
//    0x43, 0x47, 0x4f, 0x50, 0x2d, 0x39, 0x36, 0x30, 0x30, 0x30, 0x34,
//    0x0a,
//    0x59, 0x55, 0x4e, 0x45, 0x45, 0x43, 0x2d, 0x34, 0x31, 0x30, 0x30, 0x30, 0x32
//};


@interface MessagePack()
@property (nonatomic, readwrite) Byte *bytes;
@property (nonatomic, readwrite) Byte *payload;

@property (nonatomic, readwrite) int length;
@property (nonatomic, readwrite) int payloadLen;

@property (nonatomic, readwrite) int requestType;
@property (nonatomic, readwrite) int ack;

@end

@implementation MessagePack

- (instancetype)initWithBytes:(Byte *)bytes {
    if (self == [super init]) {
        
        if (bytes[0] != FLAG || bytes[1] != FLAG) {
            return NULL;
        }
        
        self.bytes = bytes;
        
        int payloadLen = (bytes[2] & 0xff) | ((bytes[3] & 0xff) << 8);
        printf("payloadLen=%d\n", payloadLen);
        
        self.payloadLen = payloadLen;
        self.length = payloadLen + 8;
        
        //        if (strlen(payload) < payloadLen + 8) {
        //            return NULL;
        //        }
        
        //if ([CrcUtils crc8:payload :7 :payloadLen] == payload[payloadLen + 7]) {
        // 初始化
        self.requestType = bytes[4];
        self.ack = (bytes[5] & 0xff) | ((bytes[6] & 0xff) << 8);
        
        
        if (payloadLen > 0) {
            self.payload = malloc(payloadLen *sizeof(Byte));
            memcpy(self.payload, bytes+7, payloadLen);
        }
        return self;
        //}
        
    }
    return NULL;
}

- (instancetype)initWithPayload_len:(int)payload_len type:(int)type ack:(int)ack payload:(Byte *)payload {
    Byte *byte = malloc(payload_len + 8);
    memcpy(byte, HEADER, 2);
    memcpy(byte+2, &payload_len, sizeof(payload_len));
    byte[4] = type;
    memcpy(byte+5, &ack, sizeof(ack));
    if (payload_len > 0 && payload != NULL)
        memcpy(byte+7, payload, payload_len);
    byte[payload_len + 7] = [CrcUtils crc8:payload :0 :payload_len];
    
    return [self initWithBytes:byte];
}

- (instancetype)wrapServerBind {
    return [self initWithPayload_len:0 type:Type_Bind ack:++self.ack
                             payload:NULL];
}

- (instancetype)wrapGetWifiList {
    NSString *cmd = @"getWifiList";
    return [self initWithPayload_len:cmd.length type:Type_Request ack:++self.ack payload:[cmd UTF8String]];
}

- (instancetype)wrapConnectWifiWithssid:(NSString *)ssid password:(NSString *)password {
    NSString *cmd = [NSString stringWithFormat:@"connectWifi?ssid=%@&password=%@", ssid, password];
    return [self initWithPayload_len:cmd.length type:Type_Request ack:++self.ack payload:[cmd UTF8String]];
}

- (instancetype)wrapDisconnectWifi {
    NSString *cmd = @"disconnectWifi";
    return [self initWithPayload_len:cmd.length type:Type_Request ack:++self.ack payload:[cmd UTF8String]];
}

- (instancetype)wrapGetConnectWifiInfo {
    NSString *cmd = @"getConnectWifiInfo";
    return [self initWithPayload_len:cmd.length type:Type_Request ack:++self.ack payload:[cmd UTF8String]];
}

//- (instancetype)responseWifiList {
//    //67 65 74 57 69 66 69 4c 69 73 74
//    //Byte payload[] = {0x55, 0x55, 0x0b, 0x00, 0x1b, 0x64, 0x01, 0x67, 0x65, 0x74, 0x57, 0x69, 0x66, 0x69, 0x4c, 0x69, 0x73, 0x74, 0xa1};
//    
//    //return [[MessagePack alloc]initWithPayload:RESPONSEWIFILIST];
//}

// MARK: Aux Methods

- (NSData *)data {
    return [NSData dataWithBytes:self.bytes length:self.length];
}

//MARK: test code

- (NSArray *)wifiList {
    NSMutableString *ms = [[NSMutableString alloc]init];
    for (int i = 0; i < self.payloadLen; i++) //ignore the first response code
    {
        [ms appendFormat:@"%c", self.payload[i]];
    }
    
    NSArray *lists = [ms componentsSeparatedByString:@"&&"];
    return lists;
    //[self printStringArray:lists];
}

- (NSString *)message {
    NSMutableString *ms = [[NSMutableString alloc]init];
    for (int i = 0; i < self.payloadLen; i++) //ignore the first response code
    {
        [ms appendFormat:@"%c", self.payload[i]];
    }
    
    return ms;
}

//MARK: test code
- (void)print {
    for (int i = 0; i < self.length; i++) {
        printf("%x ", self.bytes[i]);
    }
    printf("\n--------------------------\n");
}

- (void)printStringArray:(NSArray *)stringArr {
    for (NSString *str in stringArr) {
        NSLog(@"%@\n", str);
    }
}

- (void)connectPackage:(NSString *)ssid :(NSString *)password {
    NSString *payloadStr = [NSString stringWithFormat:@"connectWifi?ssid=%@&password=%@", ssid, password];
    
    Byte *contents = [payloadStr UTF8String];
    
    for (int i = 0; i < strlen(contents); i++) {
        printf("%x ", contents[i]);
    }
}



@end
