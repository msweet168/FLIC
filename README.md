# FLIC (Fantastic Light Illumination Controller)

## What is FLIC? 

FLIC, or Fantastic Light Illumination Controller, is a smart home device that uses IR LED lights to control an assortment of smart home devices, specifically IR lights. In order to run FLIC, the IR remote library is required (linked below).

## How it works

FLIC consists of two parts, the device and the app. The device consists of an Arduino connected to the HM-10 bluetooth chip and an IR LED. This Arduino runs the FLIController sketch. When the Arduino receives a single letter command over serial, FLIController sends a signal out of the IR LED based on the letter. The sketch will also send commands to perform effects like strobing and flashing. 

## FLIController

FLIController is what decides what IR signal to send out. It utilizes the IR remote library written by shirriff. 

#### IR remote: https://github.com/z3t0/Arduino-IRremote/blob/master

The sketch reads the serial input to decide which signal to send out. 

## The Arduino 

The Arduino is connected to three components: the HM-10 bluetooth chip, an IR LED, and a status LED. The HM-10 is connected to the TX and RX ports so it can send serial input. The IR LED is connected to pwm port 3, and the RGB status LED is connected to pwm ports 9, 10 and 11. 

## FLICommander 

This is the iOS app which controls the device. It uses the CoreBluetooth iOS framework to communicate with the chip. The app uses the BluetoothSerial class made by hoiberg. 

#### BluetoothSerial: https://github.com/hoiberg/HM10-BluetoothSerial-iOS

The app features controls for the IR lights. It allows the user to turn the lights on and off, change the brightness and color, enable effects, and set timers. 


## Creator and License 

FLIC is protected under the MIT license. Credit must be given for any substantial use. 

Created by Mitchell Sweet 
© 2018 Mitchell Sweet

