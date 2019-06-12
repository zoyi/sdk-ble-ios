# [Walkinsights](https://walkinsights.com) - Offline Customer Analytics
[Walkinsights](https://walkinsights.com) analyzes customer behavior through outside traffic, store visits and returns through automated solution.

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/CHPlugin)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/zoyi/channel-plugin-ios)
[![Commercial License](https://img.shields.io/badge/license-Commercial-brightgreen.svg)](https://github.com/zoyi/sdk-ble-ios/blob/master/LICENSE)

## Overview

This BLE SDK providing a simple API set that gives third party Apps ability to get notified from registered ZOYI Squares (ZOYI Router device).

## Prerequisite

* iOS 8.0 or above

## Simple Flow Graph

```
     +-------------------------------+      
     |                               |      
     |  Get squares' MAC addresses.  |      
     |                               |      
     +---------------+---------------+      
                     |                      
                     |                      
                     |                      
    +----------------v----------------+     
    |                                 |     
    | BleManager start scan with      |     
    | these mac addresses.            |     
    |                                 |     
    +----------------+----------------+     
                     |                      
                     |                      
                     |                      
  +------------------v-------------------+  
  |                                      |  
  | Get notified from BleManager when one|  
  | of the MAC address are discovered.   |  
  |                                      |  
  +------------------+-------------------+  
                     |                      
                     |                      
                     |                      
     +---------------v--------------+       
     |                              |       
     | Stop Scan when you are done. |       
     |                              |       
     +------------------------------+       
```

## How to use it(Objective-C)

### Install WI BLE Library Framework from CocoaPods(iOS 8.0+)

Add below into your Podfile on Xcode.

```ruby
target YOUR_PROJECT_TARGET do
  pod 'WIBLELib'
end
```


Install WIBLELib Framework through CocoaPods.

```sh
pod repo update
pod install
```

Now you can see WI BLE framework by inspecting YOUR_PROJECT.xcworkspace.

### Create a BleManager that you want to manage the scan process, Assign BleManagerDeleagate to BleManager to get invoked.

```objective-c
@interface ViewController : UIViewController<BleManagerDeleagate>
  @property BleManager* manager;
...
@end
```

### Start scanning by filtering with specific MAC addresses

```objective-c
  // startScanWithmacs
  if (![_manager isScanning] &&
      [_manager isPowerOn] &&
      [_manager startScanWithMacsWithTargetMacs:macs])
  {
    // Success
  } else {
    // Failed
  }
```

### Receive the discovery callback from BleManager

```objective-c
  - (void)didDiscoverMacWith:(NSString * _Nonnull)mac rssi:(NSInteger)rssi timestamp:(NSTimeInterval)timestamp {
    if (rssi > [self rssiThreashHold]) {
      [self stopScanning];
    }
  }
```

### Remember to stop scanning when you are done.

```objective-c
  [_manager stopScan];
```


## How to use it(Swift)

### Install WI BLE Library Framework from CocoaPods(iOS 8.0+)

Add below into your Podfile on Xcode.

```ruby
target YOUR_PROJECT_TARGET do
  pod 'WIBLELib'
end
```


Install WIBLELib Framework through CocoaPods.

```sh
pod repo update
pod install
```

Now you can see WI BLE framework by inspecting YOUR_PROJECT.xcworkspace.

### Create a BleManager that you want to manage the scan process, Assign BleManagerDeleagate to BleManager to get invoked.

```swift
class ViewController: UIViewController, BleManagerDeleagate{
  func didDiscoverMac(with mac: String, rssi: Int, timestamp: TimeInterval) {
    // example
    if (rssi > rssiThreashHold) {
      self.stopScanning()
    }
  }

  var manager:BleManager!
  override func viewDidLoad() {
    // on Debug mode
    BleManager.debugMode = true

    // Create BleManager
    manager = BleManager(initWithDelegate: self)
  }

  ...
}
```

### Start scanning by filtering with specific MAC addresses

```swift
  // startScanWithmacs
  if (manager.isPowerOn &&    // Support Bluetooth hardware
      !manager.isScanning &&  // Check Already scanning
      manager.startScanWithMacs(targetMacs: targetMacs)) {  // Start Scaning with specific MAC addresses
    // Success
  } else {
    // Failed
  }
```

### Receive the discovery callback from BleManager

```swift
  func didDiscoverMac(with mac: String, rssi: Int, timestamp: TimeInterval) {
    // example
    if (rssi > rssiThreashHold) {
      print("Find!! \(mac)")
      // stop Scanning
      self.stopScanning()
    }
  }
```

### Remember to stop scanning when you are done.

```swift
  manager.stopScanning()
```


