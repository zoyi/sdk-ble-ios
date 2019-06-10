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
    private var delegate: BleManagerDeleagate?
    private var targetMacs: [String]
    
    private static let zoyiServiceUUID = "b02d"
    private static let zoyiOUI = "f4fd2b"
    @objc public static var debugMode = false
    
    @objc private(set) public var isPowerOn: Bool
    @objc private(set) public var isScanning: Bool

    @objc public init(initWithDelegate delegate : BleManagerDeleagate) {
        targetServiceUUIDs = [CBUUID(string: BleManager.zoyiServiceUUID)]
        self.delegate = delegate
        self.targetMacs = []
        self.isPowerOn = false
        self.isScanning = false

        super.init()

        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central)
        switch (central.state) {
        case .unsupported:
            NSLog("BLE UNSUPPORTED")
        case .poweredOn:
            NSLog("Power on")
            self.isPowerOn = true
        default:
            NSLog("state: \(central.state)")
        }
        NSLog("did update State")
    }
    
    @objc public func stopScan() {
        self.manager?.stopScan()
        self.isScanning = false
    }
    
    @objc public func startScanWithMacs(targetMacs: [String]) {
        self.targetMacs = targetMacs
        self.startScan();
    }
    
    private func startScan() {
        self.manager?.scanForPeripherals(withServices: targetServiceUUIDs, options: nil)
        self.isScanning = true
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
        dlog("Fined: \(mac)")
        
        if self.targetMacs.contains(mac) {
            delegate?.didDiscoverMac(with: mac, rssi: rssi, timestamp: NSDate().timeIntervalSince1970)
        }
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
