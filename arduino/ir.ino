#include <IRremote.h>
int RECV_PIN = 2; //define input pin on Arduino
int RECV_RELAY = 3; //define input actuator for relay 
IRrecv irrecv(RECV_PIN);
decode_results results;
int lightState = 1; // 1 is ON 0 is OFF

void setup() {
  Serial.begin(9600);
  irrecv.enableIRIn(); // Start the receiver
  pinMode(RECV_RELAY, OUTPUT); 
}

void loop() {
  // put your main code here, to run repeatedly:
  if (irrecv.decode(&results)) {
    int value = results.value;
    Serial.println(value, HEX);

    // change with received value from above (HEX variable)
    if (value != 0xFF00BBA9) {
      if (lightState > 0) { 
         Serial.println("TURN OFF");
         //turn off light  
         digitalWrite(RECV_RELAY, HIGH);
         lightState = 0;
      } else {
         Serial.println("TURN ON");
         //turn on light  
         digitalWrite(RECV_RELAY, LOW); 
         lightState = 1;
      }
      delay(2000);
    }
    irrecv.resume(); // Receive the next value
  }
}