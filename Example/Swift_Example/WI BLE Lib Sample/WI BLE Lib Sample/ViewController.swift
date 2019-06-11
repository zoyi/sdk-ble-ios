//
//  ViewController.swift
//  WI BLE Lib Sample
//
//  Created by ChangsoonKim on 10/06/2019.
//  Copyright © 2019 ZOYI Corporation. All rights reserved.
//

import UIKit
import WIBLELib

class ViewController: UIViewController, BleManagerDeleagate {
    var manager:BleManager!
    var rssiThreashHold:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        BleManager.debugMode = false
        manager = BleManager(initWithDelegate: self)
        
        tbRSSI.text = "-70"
        tbTargetMacs.text = "f4fd2b10780a, f4fd2b2086fe"
        
    }

    @IBOutlet weak var btnStartStop: UIButton!
    @IBOutlet weak var tbRSSI: UITextField!
    @IBOutlet weak var tbTargetMacs: UITextField!
    
    func didDiscoverMac(with mac: String, rssi: Int, timestamp: TimeInterval) {
        if (rssi > rssiThreashHold) {
            print("Find!! \(mac)")
            self.showAlert(mac: mac, rssi: rssi)
            self.stopScanning()
        }
    }
    
    func showAlert(mac: String, rssi: Int) {
        let alert = UIAlertController(title: "Find Mac(\(mac) - \(rssi))", message: "Success", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func startScanning() {
        let targetMacs = tbTargetMacs.text?.components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
        
        if (targetMacs != nil &&
            !manager.isScanning &&
            manager.isPowerOn &&
            manager.startScanWithMacs(targetMacs: targetMacs!))
        {
            rssiThreashHold = Int(self.tbRSSI.text!)
            btnStartStop.setTitle("Stop", for: .normal)
            tbRSSI.isUserInteractionEnabled = false
            tbTargetMacs.isUserInteractionEnabled = false
        }
    }
    
    func stopScanning() {
        manager.stopScan()
        btnStartStop.setTitle("Start", for: .normal)
        tbRSSI.isUserInteractionEnabled = true
        tbTargetMacs.isUserInteractionEnabled = true
    }
    
    @IBAction func touchUpStartButton(_ sender: Any) {
        if (manager.isScanning) {
            self.stopScanning()
            return
        }
        
        self.startScanning()
    }
}

