//
//  ViewController.m
//  WI BLE Lib Sample objc
//
//  Created by ChangsoonKim on 11/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

#import "ViewController.h"
#import <WIBLELib/WIBLELib-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [BleManager setDebugMode:false];
    
    _manager = [[BleManager alloc] initWithInitWithDelegate:self];
    [_tbMacs setText:@"f4fd2b10780a, f4fd2b2086fe"];
    [_tbRSSI setText:@"-70"];
}
    
- (void) showAlert:(NSString *)mac withRssi:(NSInteger)rssi {
    NSString *title = [NSString stringWithFormat:@"Find Mac %@ - %ld", mac, (long)rssi];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                message:@"Success"
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) startScanning {
    NSArray* macs = [[_tbMacs text] componentsSeparatedByString:@", "];
    
    if (macs != NULL &&
        ![_manager isScanning] &&
        [_manager isPowerOn] &&
        [_manager startScanWithMacsWithTargetMacs:macs])
    {
        _rssiThreashHold = [[_tbRSSI text] intValue];
        [_btnStart setTitle: @"Stop" forState: UIControlStateNormal];
        [_tbRSSI setUserInteractionEnabled:false];
        [_tbMacs setUserInteractionEnabled:false];
    }
}

- (void) stopScanning {
    NSLog(@"stop Scanning");
    [_manager stopScan];
    [_btnStart setTitle: @"Start" forState: UIControlStateNormal];
    [_tbRSSI setUserInteractionEnabled:true];
    [_tbMacs setUserInteractionEnabled:true];
}
    

- (IBAction)touchUpStartBtn:(id)sender {
    NSLog(@"clicked");
    if ([_manager isScanning]) {
        [self stopScanning];
        return;
    }
    [self startScanning];
}
    
- (void)didDiscoverMacWith:(NSString * _Nonnull)mac rssi:(NSInteger)rssi timestamp:(NSTimeInterval)timestamp {
    if (rssi > [self rssiThreashHold]) {
        NSLog(@"Find %@", mac);
        [self showAlert:mac withRssi:rssi];
        [self stopScanning];
    }    
}

@end
