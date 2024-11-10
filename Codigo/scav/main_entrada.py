import cv2
import time
import requests
import config
from detectarPatente import detectar_patente
from arduino_control import ArduinoControl
from datetime import datetime

# Inicializar conexión con Arduino
try:
    arduino = ArduinoControl(port='COM6')
except Exception as e:
    print(f"Error al conectar con Arduino: {e}")
    arduino = None

# Variables globales
ultima_patente = None
ultimo_resultado = None
ultimo_tiempo = 0

def consultar_vehiculo(patente):
    url = f"{config.API_URL_VEHICULO}patente/{patente}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }

    try:
        response = requests.get(url, headers=headers)
        print("Response status code:", response.status_code)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error al consultar el vehículo: {e}")
        return None

def registrar_entrada_bitacora(vehiculo_id):
    """Registra la entrada del vehículo en la bitácora."""
    url = f"{config.API_URL_BITACORA_ENTRADA}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }
    data = {
        "vehiculoId": vehiculo_id,
        "fechain": datetime.now().isoformat(),
        "fechaout": None
    }

    print("Datos enviados a la bitácora:", data)
    try:
        response = requests.post(url, json=data, headers=headers)
        response.raise_for_status()
        if response.status_code == 201:
            print(f"Registro de entrada exitoso para vehículo ID: {vehiculo_id}")
            return True
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar en bitácora: {e}")
    return False


def main():
    global ultima_patente, ultimo_tiempo  # Asegurarse de utilizar las variables globales

    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    print("Iniciando detección de patentes...")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            break

        patente = detectar_patente(frame)

        tiempo_actual = time.time()

        # Declaramos como globales nuevamente aquí para evitar errores locales
        global ultima_patente
        global ultimo_tiempo

        if patente and (patente != ultima_patente or tiempo_actual - ultimo_tiempo > 5):
            print(f"Patente detectada: {patente}")
            resultados = consultar_vehiculo(patente)

            if resultados:
                vehiculo = resultados.get('data')
                if vehiculo:
                    vehiculo_id = vehiculo.get('id')
                    if registrar_entrada_bitacora(vehiculo_id):
                        arduino.enviar_comando("subir")

            ultima_patente = patente
            ultimo_tiempo = tiempo_actual

        cv2.imshow('Detección de Patente', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    arduino.cerrar()

if __name__ == "__main__":
    main()
