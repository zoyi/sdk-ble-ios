//
//  ScanManager.swift
//  sdk-ble-ios
//
//  Created by ChangsoonKim on 04/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

import Foundation
import CoreBluetooth

func dlog<T>( _ object:  @autoclosure () -> T, color: UIColor = UIColor.black) {
    guard BleManager.debugMode else { return }
    let message = "[ZBeaconKit] \(Date()): \(object())\n\n"
    print(message, terminator: "")
}

@objc
public final class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager!
    let targetServiceUUIDs : [CBUUID]!
    var delegate: BleManagerDeleagate?
    var targetMacs: [String]
    
    private static let zoyiServiceUUID = "b02d"
    private static let zoyiOUI = "f4fd2b"
    @objc public static var debugMode = false
    
    init(initWithDelegate delegate : BleManagerDeleagate) {
        targetServiceUUIDs = [CBUUID(string: BleManager.zoyiServiceUUID)]
        self.delegate = delegate
        self.targetMacs = []
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unsupported:
            NSLog("BLE UNSUPPORTED")
        case .poweredOn:
            NSLog("Power on")
        default:
            NSLog("state: \(central.state)")
        }
        NSLog("did update State")
    }
    
    func stopScan() {
        self.manager?.stopScan()
    }
    
    func startScanWithMacs(targetMacs: [String]) {
        self.targetMacs = targetMacs
        self.startScan();
    }
    
    func startScan() {
        self.manager?.scanForPeripherals(withServices: targetServiceUUIDs, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let rssi = Int(truncating: RSSI)
        var mac: String;
        
        let macFromServiceData = self.getMacAddressFromServiceData(advertisementData: advertisementData)
        dlog(macFromServiceData)
        
        let macFromManufacturerData = self.getMAcAddressFromManufacturerData(advertisementData: advertisementData)
        dlog(macFromManufacturerData)
        
        if (macFromServiceData != nil) {
            mac = macFromServiceData!
        } else if (macFromManufacturerData != nil) {
            mac = macFromManufacturerData!
        } else {
            return;
        }
        
        delegate?.didDiscoverMac(with: mac, rssi: rssi, timestamp: NSDate().timeIntervalSince1970)
    }
    
    private func getMacAddressFromServiceData(advertisementData: [String : Any]) -> String? {
        let serviceDatas = advertisementData[CBAdvertisementDataServiceDataKey] as! NSDictionary?
        let serviceData = serviceDatas![BleManager.zoyiServiceUUID] as! Data?
        let macAddr = serviceData?.subdata(in: 1..<7).hexString
        
        if ((macAddr?.contains(BleManager.zoyiOUI))!) {
            dlog(macAddr)
            return macAddr
        }
        return nil
    }
    
    private func getMAcAddressFromManufacturerData(advertisementData: [String : Any]) -> String? {
        let manufacturerDatas = advertisementData[CBAdvertisementDataManufacturerDataKey] as! Data?
        
        dlog(manufacturerDatas)
        if (manufacturerDatas == nil) {
            return nil
        }
        
        let macAddr = manufacturerDatas?.hexString
        if ((macAddr?.contains(BleManager.zoyiOUI))!) {
            return macAddr
        }
        return nil
    }
}
