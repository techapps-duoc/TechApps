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
ultimo_tiempo = 0

def consultar_vehiculo(patente):
    """Consulta los datos de un vehículo específico por su patente."""
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

def actualizar_salida_bitacora(vehiculo_id):
    """Actualiza la hora de salida del vehículo en la bitácora utilizando la API de salida."""
    # Usamos la URL correcta para actualizar la salida
    url = f"{config.API_URL_BITACORA_SALIDA}/{vehiculo_id}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }
    data = {
        "fechaout": datetime.now().isoformat()
    }

    print("Actualizando bitácora con los datos:", data)
    print(f"Usando URL: {url}")

    try:
        response_update = requests.put(url, json=data, headers=headers, timeout=10)
        print(f"Response status code: {response_update.status_code}")
        response_update.raise_for_status()

        if response_update.status_code == 200:
            print(f"Registro de salida exitoso para vehículo ID: {vehiculo_id}")
            return True
        else:
            print(f"Error al registrar salida: {response_update.status_code} - {response_update.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error al actualizar la salida en bitácora: {e}")
        return False

def main():
    global ultima_patente, ultimo_tiempo

    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    print("Iniciando detección de patentes y registro de salida...")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            break

        patente = detectar_patente(frame)
        tiempo_actual = time.time()

        if patente and (patente != ultima_patente or tiempo_actual - ultimo_tiempo > 3):
            print(f"Patente detectada: {patente}")
            resultados = consultar_vehiculo(patente)

            if resultados:
                vehiculo = resultados.get('data')
                if vehiculo:
                    vehiculo_id = vehiculo.get('id')
                    # Actualizar la salida en la bitácora
                    if actualizar_salida_bitacora(vehiculo_id):
                        arduino.enviar_comando("subir")

            ultima_patente = patente
            ultimo_tiempo = tiempo_actual

        cv2.imshow('Registro de Salida', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    if arduino:
        arduino.cerrar()

if __name__ == "__main__":
    main()
