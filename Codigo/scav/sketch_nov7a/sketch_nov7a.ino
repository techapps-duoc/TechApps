#include <Servo.h>

Servo servol;  // Crear un objeto de servo

// Definir los pines y límites del servomotor
int PINSERVO = 2;
int PULSOMIN = 1000;   // Pulso mínimo en microsegundos
int PULSOMAX = 2000;   // Pulso máximo en microsegundos

void setup() {
  Serial.begin(9600);  // Iniciar la comunicación serial
  servol.attach(PINSERVO, PULSOMIN, PULSOMAX); // Conectar el servomotor al pin 2 con límites de pulso
  servol.write(0);  // Inicialmente, la barrera está abajo
}

void loop() {
  if (Serial.available() > 0) {
    String comando = Serial.readStringUntil('\n');  // Leer el comando completo
    comando.trim();  // Limpiar espacios en blanco

    if (comando == "subir") {
      Serial.println("Comando recibido: subir");
      servol.write(90);  // Mover el servomotor a 90 grados para subir la barrera
      delay(5000);       // Mantener la barrera arriba por 5 segundos
      servol.write(0);   // Bajar la barrera después de 5 segundos
    }
  }
}

