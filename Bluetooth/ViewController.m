//
//  ViewController.m
//  Bluetooth
//
//  Created by Amanda Harman on 10/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <BluetoothManagerDelegate>

@end

@implementation ViewController

@synthesize connectionButton;
@synthesize connectionStatusLabel;
@synthesize bluetoothManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.deviceInfo setUserInteractionEnabled:NO];
    bluetoothManager = [BluetoothManager sharedManager];
    bluetoothManager.delegate = self;
    
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

#pragma mark - User Actions
- (IBAction)connectDeviceButtonPressed:(UIButton *)sender {
    [bluetoothManager.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:THERMOMETER_SERVICE_UUID]] options:nil];
    
}

#pragma mark - UpdateView
-(void)showConnection:(BOOL)connected withName:(NSString *)peripheralName{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connected = [NSString stringWithFormat:@"Connected: %@", connected ? @"YES" : @"NO"];
        NSLog(@"%@", self.connected);
        connectionStatusLabel.text = [NSString stringWithFormat:@"Connected to %@", peripheralName];
        [connectionButton setEnabled:FALSE];
        [self.navigationItem setPrompt:nil];
    });
};

-(void)updateLabelWithTemperature: (float)temperature{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tempLabel.text = [NSString stringWithFormat:@"%2f",temperature];
        self.statusImage.image = [UIImage imageNamed:@"yes"];
    });
}






@end
