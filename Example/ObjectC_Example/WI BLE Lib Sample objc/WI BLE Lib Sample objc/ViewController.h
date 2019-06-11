//
//  ViewController.h
//  WI BLE Lib Sample objc
//
//  Created by ChangsoonKim on 11/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WIBLELib/WIBLELib-Swift.h>

@interface ViewController : UIViewController<BleManagerDeleagate>
    @property (weak, nonatomic) IBOutlet UITextField *tbMacs;
    @property (weak, nonatomic) IBOutlet UIButton *btnStart;
    @property (weak, nonatomic) IBOutlet UITextField *tbRSSI;
    @property BleManager* manager;
    @property int rssiThreashHold;
    
    - (IBAction)touchUpStartBtn:(id)sender;
    - (void) showAlert:(NSString *) mac withRssi:(NSInteger) rssi;
    - (void) startScanning;
    - (void) stopScanning;
@end
