import serial
import time

class ArduinoControl:
    def __init__(self, port='COM6', baud_rate=9600):
        """Inicializa la conexión con Arduino."""
        try:
            self.arduino = serial.Serial(port, baud_rate, timeout=1)
            time.sleep(2)  # Esperar a que el puerto se estabilice
            print(f"Conectado a Arduino en {port}")
        except Exception as e:
            print(f"Error al conectar con Arduino: {e}")
            self.arduino = None

    def enviar_comando(self, comando):
        """Envía un comando al Arduino y lee la respuesta."""
        if self.arduino and self.arduino.isOpen():
            try:
                self.arduino.write(f"{comando}\n".encode())
                print(f"Comando enviado a Arduino: {comando}")
                
                # Leer respuesta del Arduino (si envía alguna)
                respuesta = self.arduino.readline().decode().strip()
                if respuesta:
                    print(f"Respuesta de Arduino: {respuesta}")
            except Exception as e:
                print(f"Error al enviar comando a Arduino: {e}")
        else:
            print("Arduino no está conectado o el puerto no está abierto.")

    def cerrar(self):
        """Cierra la conexión con Arduino."""
        if self.arduino:
            self.arduino.close()
            print("Conexión con Arduino cerrada.")

# Ejemplo de uso para probar la conexión
if __name__ == "__main__":
    arduino = ArduinoControl()
    arduino.enviar_comando("subir")
    arduino.cerrar()
