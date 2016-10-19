//
//  ViewController.h
//  Bluetooth
//
//  Created by Amanda Harman on 10/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothManager.h"


@interface ViewController : UIViewController

@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) NSString *connected;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UITextView *deviceInfo;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIButton *connectionButton;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;

- (IBAction)connectDeviceButtonPressed:(UIButton *)sender;

@end

