//
//  ScanBleSignal.swift
//  sdk-ble-ios
//
//  Created by ChangsoonKim on 03/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

import Foundation
import CoreBluetooth

class ScanBleSignals: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager!
    var targetServiceUUIDs : [CBUUID]
    var cbFunction : (String?, [String : Any], NSNumber) -> ()
    
    init(serviceUUIDS : [CBUUID], function callback: @escaping(String?, [String: Any], NSNumber) -> ()) {
        targetServiceUUIDs = serviceUUIDS
        cbFunction = callback
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unsupported:
            NSLog("BLE UNSUPPORTED")
        case .poweredOn:
            NSLog("Power on")
            self.manager?.scanForPeripherals(withServices: targetServiceUUIDs, options: nil)
        default:
            NSLog("state: \(central.state)")
        }
        NSLog("did update State")
    }
    
    func stopScan() {
        self.manager?.stopScan()
    }
    
    func startScan() {
        self.manager?.scanForPeripherals(withServices: targetServiceUUIDs, options: nil)
    }
}
