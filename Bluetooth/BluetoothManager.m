//
//  BluetoothManager.m
//  Bluetooth
//
//  Created by Amanda Harman on 10/17/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import "BluetoothManager.h"

@implementation BluetoothManager

+ (instancetype)sharedManager{
    static BluetoothManager *sharedBluetoothManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBluetoothManager = [[BluetoothManager alloc] init];
    });
    return sharedBluetoothManager;
};
    




@end
