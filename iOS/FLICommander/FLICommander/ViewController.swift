//
//  ViewController.swift
//  FLICommander
//
//  Created by Mitchell Sweet on 3/25/18.
//  Copyright © 2018 Mitchell Sweet. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

class ViewController: UIViewController, BluetoothSerialDelegate {
    
    //MARK: Outlets
    @IBOutlet var deviceLabel: UILabel!
    
    @IBOutlet var powerButton: UIButton!
    @IBOutlet var brightnessSlider: UISlider!
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet var effectButtons: [UIButton]!
    @IBOutlet var timerButton: UIButton!
    @IBOutlet var statusBar: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var disconnectButton: UIButton!
    
    @IBOutlet weak var barHeight: NSLayoutConstraint!
    
    var poweredOn = false
    
    
    var disabledView: DisabledView?
    var timerSelection: TimerSelection?
    let timerDurations = [10, 30, 60, 120]
    let timerFunctions: [Selector] = [#selector(timer10), #selector(timer30), #selector(timer60), #selector(timer120)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disabledView = DisabledView(width: Int(self.view.frame.width), height: Int(self.view.frame.height))
        timerSelection = TimerSelection(width: Int(self.view.frame.width), height: Int(self.view.frame.height))
        
        serial.delegate = self
        
        reloadView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        viewSetup()
        initalizeDevice()
    }
    
    //MARK: UI
    
    /// Sets up runtime UI elements.
    func viewSetup() {
        
        powerButton.backgroundColor = .clear
        powerButton.layer.borderColor = UIColor.white.cgColor
        powerButton.layer.borderWidth = 2
        powerButton.setTitleColor(.white, for: .normal)
        powerButton.layer.cornerRadius = 15
        
        timerButton.layer.cornerRadius = 15
        disconnectButton.layer.cornerRadius = 15
        
        statusBar.layer.cornerRadius = 15
        statusBar.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        
        
        for button in colorButtons {
            button.layer.cornerRadius = 15
            button.addTarget(self, action: #selector(select(sender:)), for: .touchDown)
            button.addTarget(self, action: #selector(deselect(sender:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(deselect(sender:)), for: .touchDragExit)
        }
        
        for button in effectButtons {
            button.layer.cornerRadius = 15
        }
        
        
    }
    
    /// Sends startup message to FLIC to show successful connection.
    func initalizeDevice() {
        //TODO: Use UserDefaults to pull up last state of light.
        serial.sendMessageToDevice("I")
        serial.sendMessageToDevice("W")
        serial.sendMessageToDevice("O")
        poweredOn = false
        changeState(enabled: false)
    }
    
    
    
    //MARK: BluetoothSerialDelegate
    
    // Remove notification observer when view deinitalizes.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Checks the state of the serial connection and changes UI accordingly.
    @objc func reloadView() {
        serial.delegate = self
        
        if serial.isReady {
            deviceLabel.text = serial.connectedPeripheral!.name
            
        } else if serial.centralManager.state == .poweredOn {
            deviceLabel.text = "Not Connected"
        } else {
            deviceLabel.text = "Bluetooth Off"
        }
    }
    
    func serialDidReceiveString(_ message: String) {
        setStatus(status: message)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        print("Disconnected")
        deviceLabel.text = "Device Has Disconnected"
        showDisabledView()
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            print("Bluetooth off.")
            deviceLabel.text = "Bluetooth Off"
        }
    }
    
    
    //MARK: Functions
    
    var statusTimer = Timer()
    
    func setStatus(status: String) {
        self.view.layoutIfNeeded()
        statusLabel.text = status
        
        guard barHeight.constant != 75 else {
            statusTimer.invalidate()
            statusTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dismissStatus), userInfo: nil, repeats: false)
            return
        }
        
        // Animate presenation of bottom status bar.
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.barHeight.constant = 75
            self.view.layoutIfNeeded()
        },completion: nil)
        
        statusTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dismissStatus), userInfo: nil, repeats: false)
    }
    
    @objc func dismissStatus() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.barHeight.constant = 0
            self.view.layoutIfNeeded()
        },completion: nil)
    }
    
    func showDisabledView() {
        if let view = disabledView {
            view.descriptionLabel.text = "FLIC has disconnected"
            view.actionButton.setTitle("Rescan", for: .normal)
            view.actionButton.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
            self.view.addSubview(view)
        }
    }
    
    
    
    /// Changes the enabled state for all buttons and sliders except for power.
    func changeState(enabled: Bool) {
        
        timerButton.isEnabled = enabled
        timerButton.alpha = (enabled ? 1 : 0.6)
        brightnessSlider.isEnabled = enabled
        for button in colorButtons {
            button.isEnabled = enabled
            button.alpha = (enabled ? 1 : 0.6)
        }
        
    }
    
    
    
    //MARK: Objc Functions and Actions
    
    @IBAction func togglePower() {
        if poweredOn {
            serial.sendMessageToDevice("O")
            poweredOn = false
            powerButton.backgroundColor = .clear
            powerButton.setTitleColor(.white, for: .normal)
            powerButton.setTitle("Turn On", for: .normal)
            changeState(enabled: false)
        }
        else {
            serial.sendMessageToDevice("I")
            poweredOn = true
            powerButton.backgroundColor = .white
            powerButton.setTitleColor(.themeColor, for: .normal)
            powerButton.setTitle("Turn Off", for: .normal)
            changeState(enabled: true)
        }
    }
    
    @IBAction func makeWhite() {
        serial.sendMessageToDevice("W")
    }
    
    @IBAction func makeRed() {
        serial.sendMessageToDevice("R")
    }
    
    @IBAction func makeGreen() {
        serial.sendMessageToDevice("G")
    }
    
    @IBAction func makeblue() {
        serial.sendMessageToDevice("B")
    }
    
    
    var lastValue = 5 //Stores the current value of the brightness. Used for changing brightness value with slider.
    @IBAction func changeBrightness(sender: UISlider) {
        let difference = abs(lastValue - Int(sender.value))
        print(difference)
        
        guard difference != 0 else {
            return
        }
        
        for _ in 1...difference {
            if lastValue > Int(sender.value) {
                lowerBrightness()
            }
            else {
                raiseBrightness()
            }
        }
        lastValue = Int(sender.value)
        print("Value should be \(lastValue)")
    }
    
    
    
    /// Sends message to lower brightness.
    func lowerBrightness() {
        serial.sendMessageToDevice("D")
    }
    
    /// Sends message to raise brightness.
    func raiseBrightness() {
        serial.sendMessageToDevice("L")
    }
    
    
    @IBAction func startStrobe() {
        effectStart(type: "strobe")
        serial.sendMessageToDevice("S")
    }
    
    @IBAction func startFlash() {
        effectStart(type: "flash")
        serial.sendMessageToDevice("F")
    }
    
    @IBAction func startFade() {
        effectStart(type: "fade")
        serial.sendMessageToDevice("U")
    }
    
    @IBAction func startPulse() {
        effectStart(type: "pulse")
        serial.sendMessageToDevice("P")
    }
    
    /// Updates UI and adds disabledView when effect is started.
    func effectStart(type: String) {
        poweredOn = true
        powerButton.backgroundColor = .white
        powerButton.setTitleColor(.themeColor, for: .normal)
        powerButton.setTitle("Turn Off", for: .normal)
        changeState(enabled: true)
        
        if let view = disabledView {
            view.descriptionLabel.text = "Performing \(type)"
            view.actionButton.setTitle("Stop", for: .normal)
            view.actionButton.addTarget(self, action: #selector(effectStop), for: .touchUpInside)
            self.view.addSubview(view)
        }

    }
    
    /// Stops effect and removes disabledView if it exists.
    @objc func effectStop() {
        serial.sendMessageToDevice("X")
        if let view = disabledView {
            view.removeFromSuperview()
        }
    }
    
    
    @IBAction func setTimer() {
        if let view = timerSelection {
            view.titleLabel.text = "Choose timer duration"
            for (index, button) in view.timerButtons.enumerated() {
                button.setTitle("\(timerDurations[index]) Mins", for: .normal)
                button.addTarget(self, action: timerFunctions[index], for: UIControlEvents.touchUpInside)
                button.addTarget(self, action: #selector(dismissTimerView), for: UIControlEvents.touchUpInside)
            }
            self.view.addSubview(view)
            view.fadeIn(duration: 0.4)
        }
    }
    
    @objc func dismissTimerView() {
        timerSelection?.fadeOut(duration: 0.4)
        timerSelection?.removeFromSuperview()
    }
    
    @objc func timer10() {
        serial.sendMessageToDevice("1")
        setStatus(status: "10 min timer set")
    }
    
    @objc func timer30() {
        serial.sendMessageToDevice("3")
        setStatus(status: "30 min timer set")
    }
    
    @objc func timer60() {
        serial.sendMessageToDevice("6")
        setStatus(status: "1 hour timer set")
    }

    @objc func timer120() {
        serial.sendMessageToDevice("0")
        setStatus(status: "2 hour timer set")
    }
    
    //TODO: Temporary!
    @IBAction func disconnectTapped() {
        UserDefaults.standard.set(nil, forKey: "lastConnection")
        disconnect()
    }
    
    @objc func disconnect() {
        serial.disconnect()
        //self.dismiss(animated: true, completion: nil)
        //TODO: Make sure this actually works.
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    /// Changes button alpha to show that it is being tapped.
    @objc func select(sender: UIButton) {
        sender.alpha = 0.7
    }
    
    /// Resets button alpha after it is deselected.
    @objc func deselect(sender: UIButton) {
        sender.alpha = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

