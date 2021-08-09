void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

}

void loop() {
  // put your main code here, to run repeatedly:
  int sensor1 = analogRead(A0);
  Serial.println(sensor1);
  delay(5);

}
