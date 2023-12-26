
// Demo Code to find the Threshold value for the Analog Sensors (e.g. LDR, MQ2, Temperature Sensor, Soil Moisture Sensor or Rain sensor)
// use this code on Aruino IDE for Aruino UNO to find the raw valu of your analog sensor.
// Then use that value in the AVR Assembly code in Microchip Studio for Arduino UNO (Atmega328p).

int sensorPin = A0;
int sensorValue = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  sensorValue = analogRead(sensorPin);    // 0 to 1023  (10-bit ADC)
  sensorValue = map(sensorValue, 0, 1023, 0, 255);  // 0 to 255 (8-bit ADC)
  Serial.println(sensorValue);
  delay(500);
}
