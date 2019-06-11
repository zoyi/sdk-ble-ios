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
    let message = "[WIBLELib] \(Date()): \(object())\n\n"
    print(message, terminator: "")
}

@objc
public final class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager!
    let targetServiceUUIDs : [CBUUID]!
    private var delegate: BleManagerDeleagate?
    private var targetMacs: [String]
    
    private let zoyiServiceUUID = CBUUID(string: "b02d")
    private let zoyiOUI:String = "f4fd2b"

    @objc public static var debugMode = false
    
    @objc private(set) public var isPowerOn: Bool
    @objc private(set) public var isScanning: Bool

    @objc public init(initWithDelegate delegate : BleManagerDeleagate) {
        targetServiceUUIDs = [self.zoyiServiceUUID]
        self.delegate = delegate
        self.targetMacs = []
        self.isPowerOn = false
        self.isScanning = false

        super.init()

        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unsupported:
            dlog("BLE UNSUPPORTED")
            self.isPowerOn = false
        case .poweredOn:
            dlog("Power on")
            self.isPowerOn = true
        default:
            dlog("state: \(central.state)")
            self.isPowerOn = false
        }
        dlog("did update State")
    }
    
    @objc public func stopScan() {
        self.manager?.stopScan()
        self.isScanning = false
    }
    
    @objc public func startScanWithMacs(targetMacs: [String]) -> Bool {
        self.targetMacs = targetMacs.map{
            $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter{
            $0.count == 12 && $0.contains(self.zoyiOUI)
        }

        dlog("Valid Target Mac Count: \(self.targetMacs.count), Bluetooth power state: \(self.isPowerOn)")
        if (BleManager.debugMode) {
            for mac in self.targetMacs {
                dlog("\t> \(mac)")
            }
        }

        if (self.targetMacs.count == 0 || self.isPowerOn == false) {
            return false
        }

        self.startScan();
        return true
    }
    
    private func startScan() {
        self.manager?.scanForPeripherals(withServices: targetServiceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        self.isScanning = true
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let rssi = Int(truncating: RSSI)
        var mac: String;
        
        if rssi == 127 {
            return;
        }

        let macFromServiceData = self.getMacAddressFromServiceData(advertisementData: advertisementData)
        
        let macFromManufacturerData = self.getMAcAddressFromManufacturerData(advertisementData: advertisementData)

        if (macFromServiceData != nil) {
            mac = macFromServiceData!
        } else if (macFromManufacturerData != nil) {
            mac = macFromManufacturerData!
        } else {
            return;
        }
        dlog("Find mac:\(mac), rssi:\(rssi)")

        if self.targetMacs.contains(mac) {
            delegate?.didDiscoverMac(with: mac, rssi: rssi, timestamp: NSDate().timeIntervalSince1970)
        }
    }
    
    private func getMacAddressFromServiceData(advertisementData: [String : Any]) -> String? {
        let serviceDatas = advertisementData[CBAdvertisementDataServiceDataKey] as! NSDictionary?
        if (serviceDatas == nil) {
            return nil
        }

        let serviceData = serviceDatas![self.zoyiServiceUUID] as! Data?
        if (serviceData == nil) {
            return nil
        }

        let macAddr = serviceData?.subdata(in: 1..<7).hexString
        
        if ((macAddr?.contains(self.zoyiOUI))!) {
            dlog(macAddr)
            return macAddr
        }

        return nil
    }
    
    private func getMAcAddressFromManufacturerData(advertisementData: [String : Any]) -> String? {
        let manufacturerDatas = advertisementData[CBAdvertisementDataManufacturerDataKey] as! Data?
        if (manufacturerDatas == nil) {
            return nil
        }
        
        let macAddr = manufacturerDatas?.hexString
        if ((macAddr?.contains(self.zoyiOUI))!) {
            return macAddr
        }
        return nil
    }
}
