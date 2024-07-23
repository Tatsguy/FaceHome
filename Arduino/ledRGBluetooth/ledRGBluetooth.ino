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
  // Inicializamos el sensor DHT
  dht.begin();
  // Configuramos el LED como salida
  pinMode(ledPin, OUTPUT);

  myStepper.setSpeed(motorSpeed);
}

void loop() {
  if (Serial.available() > 0) {
    data = Serial.readStringUntil('\n');  // Lee hasta el fin de línea (puedes ajustar esto según tu formato de entrada)
    handleCommand(data);
  }

  // Leemos la humedad relativa
  float h = dht.readHumidity();
  // Leemos la temperatura en grados centígrados (por defecto)
  float t = dht.readTemperature();

  // Enviamos los datos de temperatura y humedad por serial
  Serial.print("Humedad: ");
  Serial.print(h);
  Serial.print(" %\t");
  Serial.print("Temperatura: ");
  Serial.print(t);
  Serial.println(" *C ");
}

void handleCommand(String command) {
  command.trim(); // Elimina espacios en blanco al inicio y al final
  if (command.startsWith("LED_ON")) {
    digitalWrite(ledPin, HIGH); // Enciende el LED
  } else if (command.startsWith("LED_OFF")) {
    digitalWrite(ledPin, LOW); // Apaga el LED
  } else if (command.startsWith("MOTOR_FORWARD")) {
    int steps = command.substring(13).toInt(); // Obtiene el número de pasos desde el comando
    myStepper.step(steps); // Mueve el motor hacia adelante
  } else if (command.startsWith("MOTOR_BACKWARD")) {
    int steps = command.substring(14).toInt(); // Obtiene el número de pasos desde el comando
    myStepper.step(-steps); // Mueve el motor hacia atrás
  } else if (command.startsWith("TEMP")) {
    // Enviamos solo la temperatura a la aplicación
    float t = dht.readTemperature();
    Serial.print("Temperatura: ");
    Serial.println(t);
  }
}
