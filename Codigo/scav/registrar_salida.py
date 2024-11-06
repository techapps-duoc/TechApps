import cv2
import time
import requests
import config
from detectarPatente import detectar_patente  # Importa la función desde detectarPatente.py
from datetime import datetime

# Variable para almacenar la última patente detectada y su tiempo
ultima_patente = None
ultimo_tiempo = 0

def consultar_bitacora(patente):
    """Consulta la bitácora para obtener la última entrada registrada de un vehículo específico por su patente."""
    url = f"http://35.226.113.153:30050/api/v2/bitacoras"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        bitacoras = response.json()
        for entry in bitacoras:
            if entry['vehiculo']['patente'] == patente and entry['fechaout'] is None:
                return entry  # Retorna la entrada sin fecha de salida
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error al consultar la bitácora: {e}")
        return None

def registrar_salida_bitacora(bitacora_id):
    """Registra la salida del vehículo en la bitácora actualizando fecha de salida."""
    url = f"http://35.226.113.153:30050/api/v2/bitacoras/{bitacora_id}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }
    data = {
        "fechaout": datetime.now().isoformat()  # Fecha y hora actuales en formato ISO para la salida
    }

    try:
        response = requests.put(url, json=data, headers=headers)
        response.raise_for_status()
        if response.status_code == 200:
            print(f"Registro de salida exitoso para bitácora ID: {bitacora_id}")
        else:
            print(f"Error al registrar la salida: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar la salida en bitácora: {e}")

def main():
    """Función principal para capturar video y detectar patentes para registrar salidas."""
    global ultima_patente, ultimo_tiempo

    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    print("Iniciando la detección de patentes para registrar salidas...")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            break

        patente = detectar_patente(frame)

        # Consultar la bitácora cada 5 segundos o cuando se detecte una nueva patente
        tiempo_actual = time.time()
        if patente and (patente != ultima_patente or tiempo_actual - ultimo_tiempo > 5):
            print(f"Patente detectada: {patente}")
            bitacora_entry = consultar_bitacora(patente)
            if bitacora_entry:
                print(f"Registrando salida para la patente: {patente}")
                registrar_salida_bitacora(bitacora_entry['id'])
            else:
                print("No se encontró una entrada sin salida para esta patente en la bitácora.")
            ultima_patente = patente
            ultimo_tiempo = tiempo_actual

        # Muestra el cuadro en pantalla en tiempo real
        cv2.imshow('Registro de Salida de Patente', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
