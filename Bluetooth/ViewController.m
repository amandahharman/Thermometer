//
//  ViewController.m
//  Bluetooth
//
//  Created by Amanda Harman on 10/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize temperature;
@synthesize connectionButton;
@synthesize connectionStatusLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.deviceInfo setUserInteractionEnabled:NO];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showOrHideNavPrompt];
}

//Modified from ReyWenderlich tutorial
- (void)showOrHideNavPrompt
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (connectionButton.isEnabled) {
            [self.navigationItem setPrompt:@"Add a Bluetooth supported themometer to get started!"];
        } else {
            [self.navigationItem setPrompt:nil];
        }
    });
}
#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    NSLog(@"%@", self.connected);
    connectionStatusLabel.text = [NSString stringWithFormat:@"Connected to %@", peripheral.name];
    [connectionButton setEnabled:FALSE];
    [self.navigationItem setPrompt:nil];
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
//    NSData *data = characteristic.value;

}
-(void)getFinalTempReading:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData *data = characteristic.value;
    Byte *bytes = (Byte*)data.bytes;
    Byte flag = bytes[0];
    temperature = 0.0;
    UInt32 integer = 0;
    integer |= (UInt32)(bytes[1]);
    integer |= (UInt32)(bytes[2]) << 8;
    integer |= (UInt32)(bytes[3]) << 16;
    integer |= (UInt32)(bytes[4]) << 24;
    
    temperature = *(float *)(&integer);
    dispatch_async(dispatch_get_main_queue(), ^{
    self.tempLabel.text = [NSString stringWithFormat:@"%.2f",temperature];
    self.statusImage.image = [UIImage imageNamed:@"yes"];
    });
}

#pragma mark - User Actions
- (IBAction)connectDeviceButtonPressed:(UIButton *)sender {
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:THERMOMETER_SERVICE_UUID]] options:nil];
    
}






@end
