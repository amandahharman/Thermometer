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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConnection:) name:THERMOMETER_CONNECT_NOTIFICATION_NAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTemperatureLabel:) name:THERMOMETER_RECEIVED_TEMPERATURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDisconnection) name:@"Peripheral disconnected" object:nil];

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showOrHideNavPrompt];
}

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
    if([connectionButton.currentTitle isEqual:@"Connect Device"]){
    [bluetoothManager.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:THERMOMETER_SERVICE_UUID]] options:nil];
    }
    else if([connectionButton.currentTitle isEqual:@"Forget Connection"]){
        [bluetoothManager.centralManager cancelPeripheralConnection:bluetoothManager.thermometerPeripheral];
        [self showDisconnection];

    }
}

#pragma mark - Update View With Delegate
-(void)showConnection:(BOOL)connected withName:(NSString *)peripheralName{
        self.connected = [NSString stringWithFormat:@"Connected: %@", connected ? @"YES" : @"NO"];
        NSLog(@"%@", self.connected);
        connectionStatusLabel.text = [NSString stringWithFormat:@"Connected to %@", peripheralName];
        [connectionButton setEnabled:FALSE];
        [self.navigationItem setPrompt:nil];
};

-(void)updateLabelWithTemperature: (float)temperature{
        self.tempLabel.text = [NSString stringWithFormat:@"%2f",temperature];
        self.statusImage.image = [UIImage imageNamed:@"yes"];

}



#pragma mark - Update View With Notification
-(void)showConnection:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *infoDict = notification.userInfo;
        BOOL connected = [infoDict objectForKey:@"connected"];
        NSString *peripheralName = [infoDict objectForKey:@"name"];
        self.connected = [NSString stringWithFormat:@"Connected: %@", connected ? @"YES" : @"NO"];
        NSLog(@"%@", self.connected);
        connectionStatusLabel.text = [NSString stringWithFormat:@"Connected to %@", peripheralName];
        [connectionButton setTitle:@"Forget Connection" forState:UIControlStateNormal];
        [self.navigationItem setPrompt:nil];
    });
};

-(void)updateTemperatureLabel: (NSNotification *)notification{
    NSDictionary *infoDict = notification.userInfo;
    NSNumber *temperature = [infoDict objectForKey:@"temperature"];
    NSString *finalReading = [infoDict objectForKey: @"finalReading"];
        self.tempLabel.text = [NSString stringWithFormat:@"%.2f", [temperature floatValue]];
        if([finalReading isEqualToString:@"YES"]){
            self.statusImage.image = [UIImage imageNamed:@"yes"];
        }
}

-(void)showDisconnection{
    dispatch_async(dispatch_get_main_queue(), ^{
        connectionStatusLabel.text = @"Not Connected to a Device";
        [connectionButton setTitle:@"Connect Device" forState:UIControlStateNormal];
        [self.navigationItem setPrompt:@"Add a Bluetooth supported themometer to get started!"];
    });
};

@end
