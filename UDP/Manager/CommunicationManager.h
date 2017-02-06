//
//  CommunicationManager.h
//  UDP
//
//  Created by kenny on 16/3/5.
//  Copyright © 2016年 honeywell. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommunicationManagerDelegate <NSObject>

- (void)outputInReTV:(NSString *)msg;
- (void)outputInSeTV:(NSString *)msg;
- (void)showWifis:(NSArray *)wifis;
- (void)showMessage:(NSString *)msg;

- (int)getActionType;
@end

typedef enum : NSUInteger {
    UDPErrorTypeSuccess,
    UDPErrorTypeTimeOut,
    UDPErrorTypeCancel,
    UDPErrorTypeInvalid
} UDPErrorType;

typedef void(^UDPCallback)(UDPErrorType);
@interface CommunicationManager : NSObject

- (void)startLinkWithTimeout:(NSInteger)timeout callback:(UDPCallback)callback;
- (void)stopLink;

- (void)getWifiList;
- (void)connectWifi:(NSString *)ssid password:(NSString *)password;
- (void)disconnectWifi;
- (void)getConnectWifiInfo;

@property(nonatomic, assign)id<CommunicationManagerDelegate> delegate;

@end
