import cv2
import time
import requests
import config
from detectarPatente import detectar_patente  # Importa la función desde detectarPatente.py
from datetime import datetime

# Variables globales para la última patente detectada y resultados
ultima_patente = None
ultimo_resultado = None
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
    """Actualiza la hora de salida del vehículo en la bitácora."""
    url = f"http://35.226.113.153:30050/api/v2/bitacora/salida/{vehiculo_id}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }
    data = {
        "fechaout": datetime.now().isoformat()  # Fecha y hora actuales en formato ISO
    }

    # Imprimir los datos enviados para verificar
    print("Actualizando bitácora con los datos:", data)

    try:
        response_update = requests.put(url, json=data, headers=headers)
        response_update.raise_for_status()
        if response_update.status_code == 200:
            print(f"Registro de salida exitoso para vehículo ID: {vehiculo_id}")
            return True
    except requests.exceptions.RequestException as e:
        print(f"Error al actualizar la salida en bitácora: {e}")
        if response_update.content:
            print("Detalles del error:", response_update.json())
        return False

def imprimir_resultados_salida(resultados, frame, fecha_in, fecha_out, duracion):
    """Muestra la información de salida en pantalla."""
    global ultimo_resultado

    if resultados:
        vehiculo = resultados.get('data')
        if vehiculo:
            detalles = [
                f"Patente: {vehiculo.get('patente', 'N/A')}",
                f"Marca: {vehiculo.get('marca', 'N/A')}",
                f"Modelo: {vehiculo.get('modelo', 'N/A')}",
                "--- Salida Registrada ---",
                f"Fecha de entrada: {fecha_in.strftime('%Y-%m-%d %H:%M:%S')}",
                f"Fecha de salida: {fecha_out.strftime('%Y-%m-%d %H:%M:%S')}",
                f"Duración: {str(duracion)}",
                "Vuelva pronto!"
            ]

            ultimo_resultado = detalles

    # Mostrar la información en pantalla
    if ultimo_resultado:
        cv2.rectangle(frame, (10, 10), (600, 300), (0, 0, 0), -1)
        y_offset = 30
        for detalle in ultimo_resultado:
            cv2.putText(frame, detalle, (15, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
            y_offset += 25

def main():
    """Función principal para capturar video y detectar patentes y registrar salida."""
    global ultima_patente, ultimo_tiempo

    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    print("Iniciando la detección de patentes y consulta de salida a la API...")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            break

        patente = detectar_patente(frame)

        # Temporizador de 3 segundos para detectar una nueva patente o procesar una diferente
        tiempo_actual = time.time()
        if patente and (patente != ultima_patente or tiempo_actual - ultimo_tiempo > 3):
            print(f"Patente detectada: {patente}")
            resultados = consultar_vehiculo(patente)
            
            if resultados:
                vehiculo_id = resultados['data'].get('id')
                if vehiculo_id:
                    # Obtener la fecha de entrada (debe ser recuperada del registro de bitácora actual)
                    fecha_in = datetime.now()  # Ejemplo, debe ser la fecha de entrada real
                    fecha_out = datetime.now()
                    duracion = fecha_out - fecha_in

                    # Actualizar la salida en la bitácora
                    if actualizar_salida_bitacora(vehiculo_id):
                        imprimir_resultados_salida(resultados, frame, fecha_in, fecha_out, duracion)

            ultima_patente = patente
            ultimo_tiempo = tiempo_actual

        # Mostrar el frame en tiempo real
        cv2.imshow('Registro de Salida', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
