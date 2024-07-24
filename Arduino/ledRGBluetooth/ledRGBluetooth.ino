#include <Stepper.h>
#include <DHT.h>

String data = "";
int motorSpeed = 10;
Stepper myStepper(2048, 8, 10, 9, 11);
#define DHTPIN 2
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

const int ledPin = 13; // Pin del LED

void setup() {
  Serial.begin(9600);
  dht.begin(); // Inicializamos el sensor DHT
  pinMode(ledPin, OUTPUT); // Configuramos el LED como salida
  myStepper.setSpeed(motorSpeed);
}

void loop() {
  if (Serial.available() > 0) {
    data = Serial.readStringUntil('\n');  // Lee hasta el fin de línea
    handleCommand(data);
  }

  // Lee la humedad y la temperatura
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  // Envia los datos de temperatura y humedad por serial
  Serial.print("TEMP:");
  Serial.println(t);
}

void handleCommand(String command) {
  command.trim(); // Elimina espacios en blanco
  if (command.startsWith("LED_ON")) {
    digitalWrite(ledPin, HIGH); // Enciende el LED
  } else if (command.startsWith("LED_OFF")) {
    digitalWrite(ledPin, LOW); // Apaga el LED
  } else if (command.startsWith("MOTOR_FORWARD")) {
    int steps = command.substring(13).toInt(); // Obtiene el número de pasos
    myStepper.step(steps); // Mueve el motor hacia adelante
  } else if (command.startsWith("MOTOR_BACKWARD")) {
    int steps = command.substring(14).toInt(); // Obtiene el número de pasos
    myStepper.step(-steps); // Mueve el motor hacia atrás
  }
}
