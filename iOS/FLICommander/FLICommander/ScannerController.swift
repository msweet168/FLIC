//
//  ScannerController.swift
//  FLICommander
//
//  Created by Mitchell Sweet on 3/25/18.
//  Copyright © 2018 Mitchell Sweet. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScannerController: UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothSerialDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancelButton: UIButton!
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading...")
        
        serial.delegate = self
        //serial = BluetoothSerial(delegate: self)
        
        if serial.centralManager.state != .poweredOn {
            title = "Bluetooth not turned on"
            return
        }
        
        serial.startScan()
        //Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(scanTimeOut), userInfo: nil, repeats: false)
        
        viewSetup()
        tableViewSetup()
    }
    
    func viewSetup() {
       
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.cornerRadius = 25
        
    }
    
    @IBAction func back() {
        serial.stopScan()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func scanTimeOut() {
        serial.stopScan()
        print("Scan has timed out.")
    }
    
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        
        print("Connect has timed out.")
        
    }
    
    
    
    func tableViewSetup() {
        tableView.separatorColor = .white
        tableView.backgroundColor = UIColor.themeColor
        tableView.rowHeight = 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = peripherals.count
        
        if count == 0 {
            //TODO: Handle nothing found
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let name = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        
        if (name?.contains("FLIC"))! {
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = "Ready to Connect"
            cell.detailTextLabel?.textColor = UIColor(red: 0/255, green: 165/255, blue: 0/255, alpha: 1)
            //#00A500
        }
        else {
            cell.textLabel?.text = name
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //TODO: make sure this works right
        
        serial.stopScan()
        selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        
        if let name = selectedPeripheral?.name {
            savePeripheralName(name: name)
        }
        else {
            print("Could not save peripheral.")
        }
        
        serial.connectToPeripheral(selectedPeripheral!)
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(connectTimeOut), userInfo: nil, repeats: false)
        
    }
    
    func savePeripheralName(name: String) {
        UserDefaults.standard.set(name, forKey: "lastConnection")
    }
    
    func connectToLast() {
        
        guard let lastPeripheralName = UserDefaults.standard.string(forKey: "lastConnection") else {
            print("No past connection found.")
            return
        }
        
        for (index, peripheral) in peripherals.enumerated() {
            if peripheral.peripheral.name == lastPeripheralName {
                print("Past connection found, attempting to connect...")
                serial.stopScan()
                selectedPeripheral = peripherals[index].peripheral
                serial.connectToPeripheral(selectedPeripheral!)
            }
        }
        
    }
    
    
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        connectToLast()
        tableView.reloadData()
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect.")
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected.")
        
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
        //dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "ToController", sender: self)
    }
    
    func serialDidChangeState() {
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
