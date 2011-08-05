/*
* expose LED state over serial
*/

const int ledPin = 13;
int previousValue = -1;

void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() > 0) {
    int value = Serial.read();
    if (value != previousValue) {
      // ascii 1 is 49, ascii 0 is 48
      if (value == 49) {
        digitalWrite(ledPin, HIGH);
      } else if (value == 48) {
        digitalWrite(ledPin, LOW);
      }

      // send value change over serial
      Serial.println(value);
      previousValue = value;
    }
  }

}
