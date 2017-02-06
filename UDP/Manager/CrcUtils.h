//
//  CrcUtils.h
//  UDP
//
//  Created by kenny on 19/01/2017.
//  Copyright © 2017 honeywell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrcUtils : NSObject
+ (Byte)crc8:(Byte*)bs :(int)off :(int)len;
@end
