//
//  ViewController.h
//  Bluetooth
//
//  Created by Amanda Harman on 10/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>

#define THERMOMETER_SERVICE_UUID @"0x1809"

#define THERMOMETER_MEASUREMENT_CHARACTERISTIC_UUID @"2A1C"
#define THERMOMETER_INTERMEDIATE_TEMP_CHARACTERISTIC_UUID @"2A1E"

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *thermometerPeripheral;

@property (nonatomic, strong) NSString *connected;
@property (readonly) float temperature;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UITextView *deviceInfo;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIButton *connectionButton;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;

- (IBAction)connectDeviceButtonPressed:(UIButton *)sender;
-(void)getIntermediateTempReading:(CBCharacteristic *)characteristic error:(NSError *)error;
-(void)getFinalTempReading:(CBCharacteristic *)characteristic error:(NSError *)error;

@end

