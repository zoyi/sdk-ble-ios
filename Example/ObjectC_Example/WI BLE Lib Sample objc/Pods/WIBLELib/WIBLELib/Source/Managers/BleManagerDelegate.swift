//
//  BleManagerDelegate.swift
//  sdk-ble-ios
//
//  Created by ChangsoonKim on 07/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

import Foundation

@objc
public protocol BleManagerDeleagate: class {
    func didDiscoverMac(with mac: String, rssi: Int, timestamp: TimeInterval)
}
