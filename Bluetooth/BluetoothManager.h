//
//  BluetoothManager.h
//  Bluetooth
//
//  Created by Amanda Harman on 10/17/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>

#define THERMOMETER_SERVICE_UUID @"0x1809"

#define THERMOMETER_MEASUREMENT_CHARACTERISTIC_UUID @"2A1C"
#define THERMOMETER_INTERMEDIATE_TEMP_CHARACTERISTIC_UUID @"2A1E"

@protocol BluetoothManagerDelegate <NSObject>

-(void)showConnection:(BOOL)connected withName:(NSString *)peripheralName;
-(void)updateLabelWithTemperature: (float)temperature;

@end

@interface BluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<BluetoothManagerDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *thermometerPeripheral;

-(void)getIntermediateTempReading:(CBCharacteristic *)characteristic error:(NSError *)error;
-(void)getFinalTempReading:(CBCharacteristic *)characteristic error:(NSError *)error;

@end
