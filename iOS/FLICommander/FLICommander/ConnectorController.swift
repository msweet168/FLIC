//
//  ConnectorController.swift
//  FLICommander
//
//  Created by Mitchell Sweet on 3/25/18.
//  Copyright © 2018 Mitchell Sweet. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectorController: UIViewController, BluetoothSerialDelegate {
   
    
    
    @IBOutlet var connectButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        serial = BluetoothSerial(delegate: self)
        
        connectButton.layer.borderWidth = 2
        connectButton.layer.borderColor = UIColor.white.cgColor
        connectButton.layer.cornerRadius = 28
    }
    
    func serialDidChangeState() {
        if UserDefaults.standard.string(forKey: "lastConnection") != nil {
            print("found")
            self.performSegue(withIdentifier: "toScan", sender: self)
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
