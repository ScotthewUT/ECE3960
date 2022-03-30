/*
   The following code is designed for the ECE 3960 Course

   This code receives UDP Packets and parses them to get
   read and write to the arduino board.

   Connor Olsen 2021
   NeuroRobotics Lab
   University of Utahu
*/

#include <WiFiNINA.h>             // Click here to get the library: http://librarymanager/All#WiFiNINA
#include <MKRMotorCarrier.h>      // Click here to get the library: http://librarymanager/All#MKRMotorCarrier
#include "SparkFun_MMA8452Q.h"    // Click here to get the library: http://librarymanager/All#SparkFun_MMA8452Q
#include "Adafruit_TCS34725.h"    // Click here to get the library: http://librarymanager/ALL#Adafruit_TCS34725
#include <QTRSensors.h>           // Click here to get the library: http://librarymanager/All#QTRSensors 
#include <WiFiUdp.h>
#include <SPI.h>
#include <Wire.h>
#include "rgb_led.h"

#define HERTZ 10000 // PERIOD in MICROSECONDS
#define SERIALDEBUG 1

void setupWifi();
int getCommand(String input);
double getPin(String input);
int getVal(String input);
void executeCommand(String udpPacket);
void udpSend(char* input);
void resetReadings();

int status = WL_IDLE_STATUS;

// Set up the credentials and objects for the access point
char ssid[] = "TEAM_TBD_BOT";
char pass[] = "RSWPASSSUPERSECURE";
unsigned int localPort = 551;
char packetBuffer[256];
WiFiUDP Udp;
IPAddress ip(192, 168, 1, 100); //Assigned Static IP

bool streamAnalogData = false;
bool streamIMUData = false;
int a1;
int a2;
int a5;
int a6;
double t;
double x;
double y;
double z;
float red, green, blue;

//Ultrasonic sensor declarations
int trigPin = 0;
int echoPin = 1;
unsigned long duration;

//Piezo Piano
int tonePeriod;
unsigned long toneDuration;

rgb_led led;                      // create rgb LED object
MMA8452Q accel;                   // create instance of the MMA8452 class
Adafruit_TCS34725 rgbSensor = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_4X);

// Reflectance sensor Setup variables
QTRSensors qtr;
const uint8_t SensorCount = 4;
uint16_t sensorValues[SensorCount];


void setup() {
  delay(500);

  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A5, INPUT);
  pinMode(A6, INPUT);

  led.init();

  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
  //  while (!Serial);

  setupWifi();

  // Once the connection is made, open the UDP socket
  Udp.begin(localPort);

  // Check for Motor Carrier
  if (controller.begin()) {
    controller.reboot();
    M1.setDuty(0);
    M2.setDuty(0);
    M3.setDuty(0);
    M4.setDuty(0);
  }
  else {
    Serial.print("Motor Carrier Not Detected");
    while (1); //hang if not connected
  }

  if (accel.begin() == false) {
    Serial.println("IMU Offline");
  }  else {
    Serial.println("IMU Online");
  }

  if (rgbSensor.begin() == false) {
    Serial.println("RGB Sensor Offline");
  } else {
    Serial.println("RGB Sensor Online");
  }
  // Turn on Blue LED, indicating Initialization
  // completed and the MKR is ready to receive signals

  led.blue(100);
}

void loop() {
  double start_t = micros();
  // if there's data available, read a packet
  int packetSize = Udp.parsePacket();
  if (packetSize) {
    if (SERIALDEBUG) {
      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      Serial.print("From ");
      IPAddress remoteIp = Udp.remoteIP();
      Serial.print(remoteIp);
      Serial.print(", port ");
      Serial.println(Udp.remotePort());
    }

    // read the packet into packetBufffer
    int len = Udp.read(packetBuffer, 255);
    if (len > 0) {
      packetBuffer[len] = 0;
    }

    if (SERIALDEBUG) {
      Serial.println("Contents: ");
      Serial.println(packetBuffer);
    }

    executeCommand(packetBuffer);
  }

  if (streamAnalogData || streamIMUData) {
    resetReadings();
    char analogReturn[100];
    if (streamAnalogData) {
      a1 = analogRead(A1);
      a2 = analogRead(A2);
      a5 = analogRead(A5);
      a6 = analogRead(A6);
    }
    if (streamIMUData) {
      x = accel.getCalculatedX() + 2;
      y = accel.getCalculatedY() + 2;
      z = accel.getCalculatedZ() + 2;
    }
    sprintf(analogReturn, "ANA:%d:%d:%d:%d:%f:%f:%f", a1, a2, a5, a6, x, y, z);
    udpSend(analogReturn);
    //    Serial.println(analogReturn);
  }
  if (micros() - start_t < HERTZ)
    delayMicroseconds(HERTZ - (micros() - start_t));
  //  Serial.println(micros() - start_t);
}

void setupWifi() {
  // Check for the WiFi module
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    while (true);
  }

  String fv = WiFi.firmwareVersion();
  if (fv < WIFI_FIRMWARE_LATEST_VERSION) {
    Serial.println("Please upgrade the firmware");
  }

  WiFi.config(ip);  // Sets the static IP to the chosen IP Address from above

  // attempt to create a wireless access point:
  Serial.print("Creating Access Point...");
  status = WiFi.beginAP(ssid, pass);
  if (status != WL_AP_LISTENING) {
    Serial.println("Creating access point failed");
    while (true);
  }

  Serial.println("\nAccess Point Created!");
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your board's IP address
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  // print out the port
  Serial.print("Using Port: ");
  Serial.println(localPort);

  Serial.println("To open a UDP socket in MATLAB, use:");
  Serial.print("udp(");
  Serial.print(WiFi.localIP());
  Serial.print(", ");
  Serial.print(localPort);
  Serial.println(");\n");
}

void executeCommand(String udpPacket) {
  char returnMsg[50];
  switch (getCommand(udpPacket)) {
    // Future commands to implement:
    // Reset
    case 0: // Set the Pin Mode
      pinMode(getPin(udpPacket), getVal(udpPacket));
      //      return 1;
      break;

    case 1: // Perform a Digital Write Function
      digitalWrite(getPin(udpPacket), getVal(udpPacket));
      //      return 1;
      break;

    case 2: // Perform a Digital Read Function
      sprintf(returnMsg, "DIG:%d:%d", (int)getPin(udpPacket), (int)digitalRead(getPin(udpPacket)));
      if (SERIALDEBUG) {
        Serial.println("This is a Digital Read.");
        Serial.println((int)getPin(udpPacket));
        Serial.println((int)digitalRead(getPin(udpPacket)));
        Serial.println(returnMsg);
      }
      udpSend(returnMsg);
      break;

    case 3: // Perform an Analog Write Function
      analogWrite(getPin(udpPacket), getVal(udpPacket));
      break;

    case 4: // Perform and Analog Read function
      sprintf(returnMsg, "ANR:%d:%d", (int)getPin(udpPacket), (int)analogRead(getPin(udpPacket)));
      udpSend(returnMsg);
      break;

    case 5: // Set the onboard LED
      {
        String color = String(getPin(udpPacket));
        Serial.println(getPin(udpPacket));
        Serial.println(color);
        int red = color.substring(1, 4).toInt();
        int green = color.substring(4, 7).toInt();
        int blue = color.substring(7).toInt();

        if (SERIALDEBUG) {
          Serial.println(getPin(udpPacket));
          Serial.println(color);
          Serial.print("red = ");
          Serial.print(red);
          Serial.print(" green = ");
          Serial.print(green);
          Serial.print(" blue = ");
          Serial.println(blue);
        }
        led.setTo(red, green, blue);
        break;
      }

    case 6: // Set Motor Carrier Motors
      switch ((int)getPin(udpPacket)) {
        case 1:
          M1.setDuty(getVal(udpPacket));
          break;
        case 2:
          M2.setDuty(getVal(udpPacket));
          break;
        case 3:
          M3.setDuty(getVal(udpPacket));
          break;
        case 4:
          M4.setDuty(getVal(udpPacket));
          break;
      }
      break;

    case 7: // Set Motor Carrier Servos
      switch ((int)getPin(udpPacket)) {
        case 1:
          servo1.setAngle(getVal(udpPacket));
          break;
        case 2:
          servo2.setAngle(getVal(udpPacket));
          break;
        case 3:
          servo3.setAngle(getVal(udpPacket));
          break;
        case 4:
          servo4.setAngle(getVal(udpPacket));
          break;
      }
      //      return 1;
      break;

    case 8: // Sets the Stream Data Flag
      switch ((int)getPin(udpPacket)) {
        case 0:
          streamAnalogData = getVal(udpPacket);
          sprintf(returnMsg, "MSG:Analog Stream Set to %d", getVal(udpPacket));
          break;
        case 1:
          streamIMUData = getVal(udpPacket);
          sprintf(returnMsg, "MSG:IMU Stream Set to %d", getVal(udpPacket));
      }
      udpSend(returnMsg);
      break;

    case 9: // Confirm Connection with Client
      udpSend("1");
      break;

    case 10:
      double voltage;
      switch (getVal(udpPacket)) {
        case 0:
          voltage = battery.getFiltered();
          break;
        case 1:
          voltage = battery.getConverted();
          break;
      }
      sprintf(returnMsg, "MSG:Current Battery Voltage = %f", voltage);
      udpSend(returnMsg);
      break;

    case 11: //Ultrasonic ranger
      // The sensor is triggered by a ??? pulse of ??? or more microseconds.
      // Give a short ??? pulse beforehand to ensure a clean ??? pulse:
      digitalWrite(trigPin, LOW);  //LOW or HIGH
      delayMicroseconds(5);
      digitalWrite(trigPin, HIGH); //LOW or HIGH
      delayMicroseconds(10); //How long should the trigger pulse be?
      digitalWrite(trigPin, LOW); //LOW or HIGH

      // Read the signal from the sensor: a ??? pulse whose
      // duration is the time (in microseconds) from the sending
      // of the ping to the reception of its echo off of an object.
      duration = pulseIn(echoPin, HIGH, 60000); //format: pulseIn(pin, HIGH or LOW, timeout in microseconds)
      sprintf(returnMsg, "US:%d", (int)duration);
      udpSend(returnMsg);
      break;

    case 12: { //Piezo tone
        tonePeriod = getPin(udpPacket); //this is the first value sent in piezoTone(period, duration)
        toneDuration = getVal(udpPacket); //this is the second value sent in piezoTone(period, duration)

        digitalWrite(2, LOW);                                   //Hint: how do I ensure that this sets the M3- pin to GND?

        unsigned long toneStart = millis();                  //Hint: how do I set this variable equal to the current timestamp when this function was called?
        unsigned long elapsed_time = 0;
        while ( elapsed_time < toneDuration ) {                                          //Hint: how do I check whether it has been more time than the toneDuration since the toneStart?
          digitalWrite(3, HIGH);  //LOW or HIGH
          delayMicroseconds(tonePeriod / 2);          //Hint: for a square wave with 50% duty cycle, how long should it be high/low in a given period?
          digitalWrite(3, LOW); //LOW or HIGH
          delayMicroseconds(tonePeriod / 2);          //Hint: for a square wave with 50% duty cycle, how long should it be high/low in a given period?
          elapsed_time = millis() - toneStart;
        }
      }
      break;

    case 13: { //set up the IR Reflectance sensor array
        // configure the sensors
        qtr.setTypeRC();
        const uint8_t SensorCount = 4;
        qtr.setSensorPins((const uint8_t[]) {
          7, 8, 9, 10
        }, SensorCount);
      }
      break;

    case 14: //read IR reflectance sensor
      qtr.read(sensorValues);
      sprintf(returnMsg, "IR:%d:%d:%d:%d", sensorValues[0], sensorValues[1], sensorValues[2], sensorValues[3]);
      udpSend(returnMsg);
      break;
    case 15: {
        int enc_num = getVal(udpPacket);
        switch (enc_num) {
          case 1:
            encoder1.resetCounter(0);
            break;
          case 2:
            encoder2.resetCounter(0);
            break;
        }
        break;
      }
    case 16: { //encoders (position)
        int enc1_cnt = encoder1.getRawCount();
        int enc2_cnt = encoder2.getRawCount();
        sprintf(returnMsg, "ENC:%d:%d", enc1_cnt, enc2_cnt);
        udpSend(returnMsg);
      }
    case 17: { //encoders (velocity)
        int enc1_vel = encoder1.getCountPerSecond();
        int enc2_vel = encoder2.getCountPerSecond();
        sprintf(returnMsg, "ENC_VEL:%d:%d", enc1_vel, enc2_vel);
        udpSend(returnMsg);
      }

    case 18:
      rgbSensor.getRGB(&red, &green, &blue);
      sprintf(returnMsg, "RGB:%d,%d,%d", int(red), int(green), int(blue));
      udpSend(returnMsg);
      break;
  }
}

int getCommand(String input) {
  return input.substring(0, input.indexOf(":")).toInt();
}

double getPin(String input) {
  String substr = input.substring(input.indexOf(":") + 1);
  return substr.substring(0, substr.indexOf(":")).toDouble();
}

int getVal(String input) {
  String substr = input.substring(input.indexOf(":") + 1);
  String ssubstr = substr.substring(substr.indexOf(":") + 1);
  return ssubstr.toInt();
}

void udpSend(char* input) {
  Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
  Udp.write(input);
  Udp.endPacket();
}

void resetReadings() {
  a1 = 0;
  a2 = 0;
  a5 = 0;
  a6 = 0;
  x = 0;
  y = 0;
  z = 0;
}
