//
//  BluetoothManager.m
//  Bluetooth
//
//  Created by Amanda Harman on 10/17/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import "BluetoothManager.h"



@implementation BluetoothManager

@synthesize centralManager;

+ (instancetype)sharedManager{
    static BluetoothManager *sharedBluetoothManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBluetoothManager = [[BluetoothManager alloc] init];
    });
    return sharedBluetoothManager;
};

-(instancetype)init{
    self = [super init];
    centralManager = [[CBCentralManager alloc] initWithDelegate: self queue: nil];
    return self;
}


#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:THERMOMETER_CONNECT_NOTIFICATION_NAME object:nil userInfo: @{@"connected": @(peripheral.state == CBPeripheralStateConnected), @"name": peripheral.name} ];
        //    [self.delegate showConnection:peripheral.state == CBPeripheralStateConnected withName:peripheral.name];
        
    });
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ([localName length] > 0){
        NSLog(@"Found the thermometer: %@", localName);
        [self.centralManager stopScan];
        self.thermometerPeripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    // Determine the state of the peripheral
    switch([central state]){
        case CBManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            break;
        default:
            NSLog(@"CoreBluetooth BLE is not on or ready.");
            break;
    }
    
    
}

#pragma mark - CBPeripheralDelegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    
    if ([service.UUID isEqual: [CBUUID UUIDWithString: THERMOMETER_SERVICE_UUID]]){
        for (CBCharacteristic *aChar in service.characteristics){
            if ([aChar.UUID isEqual: [CBUUID UUIDWithString: THERMOMETER_INTERMEDIATE_TEMP_CHARACTERISTIC_UUID]]){
                [self.thermometerPeripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found intermediate temperature reading characteristic");
                
            }
            else if ([aChar.UUID isEqual: [CBUUID UUIDWithString: THERMOMETER_MEASUREMENT_CHARACTERISTIC_UUID]]){
                [self.thermometerPeripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found final temperature reading characteristic");
                
            }
            
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString: THERMOMETER_INTERMEDIATE_TEMP_CHARACTERISTIC_UUID]]){
        [self getIntermediateTempReading:characteristic error:error];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString: THERMOMETER_MEASUREMENT_CHARACTERISTIC_UUID]]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self getFinalTempReading:characteristic error:error];
        });
    }
}

#pragma mark - CBCharacteristic helpers
-(void)getIntermediateTempReading:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData *data = characteristic.value;
    float temperature = [self convertToFloatFromData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:THERMOMETER_RECEIVED_TEMPERATURE object:nil userInfo: @{@"temperature": @(temperature), @"finalReading": @"NO"}];
    });
    //    [self.delegate updateLabelWithTemperature: temperature];
}

-(void)getFinalTempReading:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData *data = characteristic.value;
    float temperature = [self convertToFloatFromData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:THERMOMETER_RECEIVED_TEMPERATURE object:nil userInfo: @{@"temperature": @(temperature), @"finalReading": @"YES"} ];
        //    [self.delegate updateLabelWithTemperature: temperature];
    });
}

-(float)convertToFloatFromData: (NSData *)data {
    Byte *bytes = (Byte*)data.bytes;
    UInt32 integer = 0;
    integer |= (UInt32)(bytes[1]);
    integer |= (UInt32)(bytes[2]) << 8;
    integer |= (UInt32)(bytes[3]) << 16;
    integer |= (UInt32)(bytes[4]) << 24;
    return  *(float *)(&integer);
}


@end
