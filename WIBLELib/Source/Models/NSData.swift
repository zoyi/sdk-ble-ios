//
//  NSData.swift
//  sdk-ble-ios
//
//  Created by ChangsoonKim on 04/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
