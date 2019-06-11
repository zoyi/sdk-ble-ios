//
//  ViewController.swift
//  sdk-ble-ios-Examples
//
//  Created by ChangsoonKim on 03/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

import UIKit
import sdk_ble_ios

class ViewController: UIViewController, BleManagerDeleagate {
    var manager:BleManager!
    
    func didDiscoverMac(with mac: String, rssi: Int, timestamp: TimeInterval) {
        print(mac, rssi, timestamp)
    }
    
    @IBOutlet weak var lbMacAddress: UILabel!
    @IBOutlet weak var tbMac: UITextField!
    @IBOutlet weak var tbRSSI: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager = BleManager(initWithDelegate: self)
        tbMac.text = "hello"
        tbRSSI.text = "13"
        print(tbMac.text!)
        manager.startScanWithMacs(targetMacs: ["f4fd2b20105a"])
        
    }

    @IBAction func touchStartButton(_ sender: Any) {
        print(tbMac.text!)
        print(tbRSSI.text!)
    }
    
}

