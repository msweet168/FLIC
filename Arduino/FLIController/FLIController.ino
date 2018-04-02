/*
 * The controller for FLIC
 * Sends basic functions to IR transmitter
 * and creates complex transitions and effects. 
 * 
 * Created by Mitchell Sweet
 * Includes libaray IRremote by shirriff
 * https://github.com/z3t0/Arduino-IRremote/blob/master/LICENSE.txt
 * 
 * Copyright © 2017 Mitchell Sweet
 */ 

 #include <IRremote.h>

 IRsend irsend; 

 bool effectLoop; //Bool to start/stop loops for effects
 int currentColor; //Holds the value for the current color set to lights
 //1 = whiteqqqa
 //2 = blue
 //3 = red
 //4 = green
 int currentBrightness; //There are 5 total brightness settings
 bool lightOn; //Holds the current state of the light. 

const int redLight = 11; //Red LED
const int greenLight = 10; //Green LED
const int blueLight = 9; //Blue LED

void setup() {
  Serial.begin(9600); //Start the serial connection
  effectLoop = false; //Initalize effects loop to false
  currentColor = 1; //Initalize current color to white
  lightOn = false; //Initalize light status
  currentBrightness = 5; //Initalize brightness, there are 5 total brightness levels (starting at 1)
  
  //Set output for status LED
  pinMode(redLight, OUTPUT);
  pinMode(greenLight, OUTPUT);
  pinMode(blueLight, OUTPUT);  
  
  //Confirm that system has started up successfully
  startupSuccess(); 
}

void loop() {
  char command = 'X'; //Create variable for command
  
  if (Serial.available()) {
    command = Serial.read(); //Set the command to the character typed in serial
    //Serial.println(Serial.read()); 
  }

//  buttonState = digitalRead(recieverButtonPin); 
//  if (buttonState == HIGH) {
//    reciever(); 
//  }

  //Decides what code to send to the sendSignal method. Based on command typed in serial
  switch(command) {
    case 'I': 
    //Power on
       setStatus(0, 255, 0);
       turnOn();
    break; 
    case 'O':
    //Turn off
       setStatus(0, 255, 0);
       turnOff();
    break; 
    case 'L':
    //Brightness up
       setStatus(0, 255, 0);
       brightnessUp();
    break; 
    case 'D':
    //Brightness dim
       setStatus(0, 255, 0);
       brightnessDown();
    break; 
    case 'W':
    //White color
      setStatus(0, 255, 0);
      colorWhite();
    break; 
    case 'R':
    //Red color 
      setStatus(0, 255, 0);
      colorRed();
    break;
    case 'G':
    //Green color 
      setStatus(0, 255, 0);
      colorGreen();
    break; 
    case 'B':
    //Blue color 
      setStatus(0, 255, 0);
      colorBlue();
    break; 
    case '1':
    //Timer 10
       setStatus(0, 255, 0);
       sendSignal(0x33B811EE);
    break; 
    case '3':
    //Timer 30 
       setStatus(0, 255, 0);
       sendSignal(0x33B8619E);
    break;
    case '6':
    //Timer 60
       setStatus(0, 255, 0);
       sendSignal(0x33B851AE);
    break; 
    case '0':
    //Timer 120
       setStatus(0, 255, 0);
       sendSignal(0x33B8D12E);
    break; 
    case 'S': 
    //Strobe
    effectStarted();
    effectLoop = true; 
       strobe(3);
    break;
    case 'F':
    //flash
    effectStarted();
    effectLoop = true;
      flash(10);
    break;
    case 'N':
    //Next color
    setStatus(0, 255, 0);
    nextColor();
    break;
    case 'U':
    //Start fade
    effectStarted();
    effectLoop = true;
      fade();
    break;
    case 'P':
    //Start pulse
    effectStarted();
    effectLoop = true;
      pulse();
    break;
    case 'X':
    //Default
    break;
  }
  command = 'X'; 
 }

 
//Turns light on
void turnOn() {
  sendSignal(0x33B801FE); //Sends correct code as parameter
  lightOn = true;
  if (effectLoop == false) {
    Serial.println("Light on");
  }
}

//Turns light off
void turnOff() {
  sendSignal(0x33B8817E);
  lightOn = false;
  if (effectLoop == false) {
    Serial.println("Light off");
  }
}

//Raises the brightness
void brightnessUp() { 
  //Check to see if the light is as bright as it can be 
  if (currentBrightness == 5) { //If it is, print status message
    setStatus(255, 0, 0);
    Serial.println("Full brightness");
    delay(500);
    statusOff();
  }
  else { //If it isn't, just send brightness signal and change variable
    sendSignal(0x33B841BE);
    currentBrightness += 1; 
    if (effectLoop == false) {
      Serial.println(currentBrightness); 
    }
  }
  
}

//Lowers the brightness
void brightnessDown() {
  //Check to see if the light is as bright as it can be
  if(currentBrightness == 1) { //If it is, print status message
    setStatus(255, 0, 0);
    Serial.println("Fully dim"); 
    delay(500);
    statusOff();
  }
  else { //If it isn't, just send brightness signal and change variable
    sendSignal(0x33B8C13E);
    currentBrightness -= 1; 
    if (effectLoop == false) {
      Serial.println(currentBrightness); 
    }
  }
  
}

//Changes the color of the light to white
void colorWhite() {
  sendSignal(0x33B821DE);
  currentColor = 1;
  currentBrightness = 5; 
}

//Changes the color of the light to blue
void colorBlue() {
  sendSignal(0x33B8E11E);
  currentColor = 2;
  currentBrightness = 5; 
}

//Changes the color of the light to red
void colorRed() {
  sendSignal(0x33B8A15E);
  currentColor = 3;
  currentBrightness = 5;
}

//Changes the color of the light to green
void colorGreen() {
  sendSignal(0x33B8916E);
  currentColor = 4;
  currentBrightness = 5;
}

//Flashes the light on and off in a loop
void strobe(int speed) {
  Serial.println("Strobe activated");
  turnOn();
  unsigned long previousMillis = 0;
  const long interval = speed*100;
  
  while(effectLoop) {
      unsigned long currentMillis = millis();
      if ((currentMillis - previousMillis >= interval)) {
      // save the last time light was blinked
      previousMillis = currentMillis;
  
      // if the light is off turn it on and vice-versa:
      if (lightOn == false) {
        turnOn();
      } else {
        turnOff();
      }
  
      char input = Serial.read(); 
      if (input != -1) {
        effectLoop = false;
        Serial.println("Strobe deactivated");
        turnOn();
        effectEnded();
      }
    }
  }
}

//Slowly lowers and raises the brightness in a loop
void pulse() {
  Serial.println("Pulse activated");
  turnOn(); 

  while(effectLoop) {
        //Lower brightness
      for(int i = 0; i < 4; i++) {
        brightnessDown();
        delay(100);
      }
      //Raise brightness
      for(int i = 0; i < 4; i++) {
        brightnessUp();
        delay(100);
      }

      char input = Serial.read(); 
      if (input != -1) {
        effectLoop = false;
        Serial.println("Pulse deactivated");
        effectEnded();
      }
  }

}

//Changes brightness along with color in a loop
void fade() {
  Serial.println("Fade activated");
  turnOn(); 
  int originalColor = currentColor-1; 

  while(effectLoop) {
        //Lower brightness
      for(int i = 0; i < 4; i++) {
        brightnessDown();
        delay(70);
      }
      nextColor(); //Change color
      char input = Serial.read(); 
      if (input != -1) {
        effectLoop = false;
        if (originalColor == 0) {
          colorWhite();
        }
        else {
          currentColor = originalColor; 
          nextColor();
        }
        Serial.println("Fade deactivated");
        effectEnded();
      }
      delay(40);
  }
}

//Changes the light to the next color
void nextColor() {
  switch(currentColor){
      case 1:
        colorBlue();
      break; 
      case 2:
        colorRed();
      break; 
      case 3:
        colorGreen();
      break;
      case 4:
        colorBlue();
      break;
  }
}

//Flashes different colors in a loop
void flash(int speed) {
  Serial.println("Flash activated");
  unsigned long previousMillis = 0;
  const long interval = speed*100;
  int originalColor = currentColor-1; 
  turnOn();
  
  while(effectLoop) {
      unsigned long currentMillis = millis();
      if ((currentMillis - previousMillis >= interval)) {
      // save the last time light was blinked
      previousMillis = currentMillis;

      //Set color based on current color. 
      switch(currentColor){
      case 1:
        colorBlue();
      break; 
      case 2:
        colorRed();
      break; 
      case 3:
        colorGreen();
      break;
      case 4:
        colorBlue();
      break;
    }
  
      char input = Serial.read(); 
      if (input != -1) {
        effectLoop = false;
        if (originalColor == 0) {
          colorWhite();
        }
        else {
          currentColor = originalColor; 
          nextColor();
        }
        Serial.println("Flash deactivated");
        effectEnded();
      }
    }
  }
}


//Sets color of status LED
void setStatus(int red, int green, int blue)
{
  analogWrite(redLight, red);
  analogWrite(greenLight, green);
  analogWrite(blueLight, blue);  
}

//Turns the status LED off
void statusOff() {
  analogWrite(redLight, 0); 
  analogWrite(greenLight, 0); 
  analogWrite(blueLight, 0); 
}

void startupSuccess() {
  setStatus(0, 0, 255);
  delay(50); 
  statusOff();
  delay(50); 
  setStatus(0, 0, 255);
  delay(50); 
  statusOff();
}

void effectStarted() {
  setStatus(0, 255, 0);
  delay(100); 
  statusOff(); 
  delay(100);
  setStatus(0, 255, 0);
}

void effectEnded() {
  setStatus(255, 0, 0);
  delay(100); 
  statusOff();
  delay(100); 
  setStatus(255, 0, 0);
  delay(100); 
  statusOff();
}


//Sends IR signal to light
 void sendSignal(long code) {
    //Serial.println("Sent"); //Prints "sent" to verify method was called
    for(int i = 0; i < 3; i++) {
    irsend.sendNEC(code, 32); //Sends the correct code through the IR blaster 3 times
    delay(40);
    statusOff();
  }
}


 
