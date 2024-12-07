
import cv2
import time
import requests
import config
from detectarPatente import detectar_patente
from arduino_control import ArduinoControl
from datetime import datetime
import threading
import re

# Variables globales
ultima_patente = None
ultimo_tiempo = 0
procesar = True  # Controla el procesamiento en el hilo
arduino = None  # Inicializado más tarde en un hilo

def inicializar_arduino():
    """Inicializa la conexión con Arduino en segundo plano."""
    global arduino
    try:
        print("Inicializando conexión con Arduino...")
        arduino = ArduinoControl(port='COM4')
        print("Conexión con Arduino establecida.")
    except Exception as e:
        print(f"Error al conectar con Arduino: {e}")

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

def es_patente_valida(patente):
    """
    Verifica si el texto cumple con el formato de una patente chilena (2 letras + 4 números).
    """
    return bool(re.fullmatch(r'[A-Z]{4}[0-9]{2}', patente))

def procesar_frames(cap):
    global ultima_patente, ultimo_tiempo, procesar
    frame_count = 0  # Contador de frames para reducir procesamiento

    while procesar:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            continue

        frame_count += 1
        cv2.imshow('Detección de Patente (Original)', frame)

        if frame_count % 30 != 0:  # Procesa cada 30 frames
            if cv2.waitKey(1) & 0xFF == ord('q'):
                procesar = False
            continue

        # Detección de patente
        patente, preprocesada, roi = detectar_patente(frame, return_intermediate=True)
        tiempo_actual = time.time()

        # Mostrar la región de interés (ROI) donde se detectó la patente
        if roi is not None:
            cv2.imshow('Patente Detectada', roi)

        # Verificar detección de patente
        if patente:
            print(f"Patente detectada: {patente}")
            if es_patente_valida(patente):
                print(f"Patente válida detectada: {patente}")
                resultados = consultar_vehiculo(patente)

                if resultados:
                    vehiculo = resultados.get('data')
                    if vehiculo:
                        vehiculo_id = vehiculo.get('id')
                        if registrar_entrada_bitacora(vehiculo_id):
                            if arduino:
                                arduino.enviar_comando("subir")

                ultima_patente = patente
                ultimo_tiempo = tiempo_actual
        else:
            print("No se detectó ninguna patente en este frame.")

        if cv2.waitKey(1) & 0xFF == ord('q'):
            procesar = False


def main():
    global procesar

    cv2.setUseOptimized(True)
    cv2.setNumThreads(4)

    print("Inicializando cámara...")
    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    cap.set(cv2.CAP_PROP_FPS, 30)

    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    print("Cámara inicializada.")

    arduino_thread = threading.Thread(target=inicializar_arduino)
    arduino_thread.start()

    print("Iniciando detección de patentes...")
    hilo_procesamiento = threading.Thread(target=procesar_frames, args=(cap,))
    hilo_procesamiento.start()

    hilo_procesamiento.join()
    arduino_thread.join()

    cap.release()
    cv2.destroyAllWindows()
    if arduino:
        arduino.cerrar()

if __name__ == "__main__":
    main()
