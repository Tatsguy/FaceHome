const int PIN_RED = 5;
const int PIN_GREEN = 6;
const int PIN_BLUE = 9;
String data = "";

void setup() {
  pinMode(PIN_RED, OUTPUT);
  pinMode(PIN_GREEN, OUTPUT);
  pinMode(PIN_BLUE, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  byte red, green, blue;

  if (Serial.available() > 0) {
    data = Serial.readStringUntil('\n');  // Lee hasta el fin de línea (puedes ajustar esto según tu formato de entrada)

    if (isValidHex(data)) {
      long hexValue = strtol(data.c_str(), NULL, 16);  // Convierte la cadena a un valor hexadecimal

      red = (hexValue >> 16) & 0xFF;
      green = (hexValue >> 8) & 0xFF;
      blue = hexValue & 0xFF;

      setColor(red, green, blue);
    } else {
      Serial.println(data);
      Serial.println("Entrada no es un valor hexadecimal valido.");
    }
  }
}

bool isValidHex(String str) {
  for (int i = 0; i < str.length(); i++) {
    char c = str.charAt(i);
    if (!isHexadecimalDigit(c)) {
      return false;
    }
  }
  return true;
}

bool isHexadecimalDigit(char c) {
  return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f');
}

void setColor(int R, int G, int B) {
  analogWrite(PIN_RED, R);
  analogWrite(PIN_GREEN, G);
  analogWrite(PIN_BLUE, B);
}
