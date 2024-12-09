import cv2
import pytesseract
import re
import time
import requests
from datetime import datetime
from arduino_control import ArduinoControl
from config import API_URL, API_KEY  # Importar API_URL y API_KEY desde config.py

# Inicializar conexión con Arduino
try:
    arduino = ArduinoControl(port='COM7')
except Exception as e:
    print(f"Error al conectar con Arduino: {e}")
    arduino = None

# Configurar la ruta de Tesseract
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Inicializar la cámara web
cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

if not cap.isOpened():
    print("Error: No se pudo acceder a la cámara.")
    exit()

def es_patente_valida(texto):
    """
    Verifica si el texto cumple con el formato de una patente chilena (4 letras + 2 números).
    """
    return bool(re.fullmatch(r'[A-Z]{4}[0-9]{2}', texto))

def registrar_salida_bitacora(vehiculo_id):
    """Registra la salida del vehículo en la bitácora y envía comando al Arduino."""
    url = f"{API_URL}/api/v2/bitacora/salida/{vehiculo_id}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': API_KEY  # Aquí se corrigió el error
    }
    data = {
        "fechaout": datetime.now().isoformat()
    }

    print("Datos enviados a la bitácora de salida:", data)
    try:
        response = requests.put(url, json=data, headers=headers)
        response.raise_for_status()
        if response.status_code == 200:
            print(f"Registro de salida exitoso para vehículo ID: {vehiculo_id}")
            # Enviar comando al Arduino para subir la barrera
            if arduino:
                arduino.enviar_comando("subir")
            else:
                print("Arduino no está conectado.")
            return True
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar en bitácora de salida: {e}")
    return False

# Variables para control de tiempo y patentes
last_detection_time = 0
processed_plates = {}  # Patentes procesadas exitosamente con su tiempo de procesamiento

# Intervalo de tiempo para permitir re-procesar una patente (en segundos)
PLATE_REPROCESS_INTERVAL = 10 # 1 minuto

def main():
    global last_detection_time, processed_plates
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: No se pudo leer el cuadro de la cámara.")
            break

        # Reducir la resolución para mejorar el rendimiento
        frame = cv2.resize(frame, (640, 480))

        # Mostrar el cuadro de la cámara
        cv2.imshow('Cámara', frame)

        # Verificar si han pasado 3 segundos desde la última detección
        current_time = time.time()
        if current_time - last_detection_time >= 3:
            last_detection_time = current_time

            # Convertir a escala de grises y aplicar preprocesamiento
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            gray = cv2.blur(gray, (3, 3))
            canny = cv2.Canny(gray, 150, 200)
            canny = cv2.dilate(canny, None, iterations=1)

            # Mostrar la imagen de bordes para depuración
            cv2.imshow('Canny', canny)

            # Encontrar contornos
            cnts, _ = cv2.findContours(canny, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
            for c in cnts:
                area = cv2.contourArea(c)
                x, y, w, h = cv2.boundingRect(c)
                epsilon = 0.09 * cv2.arcLength(c, True)
                approx = cv2.approxPolyDP(c, epsilon, True)

                # Filtrar contornos con forma rectangular y tamaño adecuado
                if len(approx) == 4 and area > 5000:
                    aspect_ratio = float(w) / h
                    if aspect_ratio > 2.0:
                        # Recortar la región de la patente
                        placa = gray[y:y + h, x:x + w]

                        # Reducir el tamaño de la región antes de OCR
                        placa = cv2.resize(placa, (200, 50))

                        # Reconocer texto con Tesseract
                        text = pytesseract.image_to_string(placa, config='--psm 8 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')

                        # Filtrar solo caracteres alfanuméricos
                        filtered_text = re.sub(r'[^A-Za-z0-9]', '', text).upper()

                        # Mostrar la placa recortada para depuración
                        cv2.imshow('Placa Recortada', placa)

                        if filtered_text:
                            if es_patente_valida(filtered_text):
                                # Verificar si la patente fue procesada y si ha pasado el tiempo suficiente
                                if filtered_text in processed_plates:
                                    time_since_processed = current_time - processed_plates[filtered_text]
                                    if time_since_processed < PLATE_REPROCESS_INTERVAL:
                                        remaining_time = int(PLATE_REPROCESS_INTERVAL - time_since_processed)
                                        print(f"Patente {filtered_text} ya fue procesada hace {int(time_since_processed)} segundos. Volverá a procesarse en {remaining_time} segundos.")
                                        continue
                                    else:
                                        # Ha pasado el tiempo suficiente, se puede re-procesar
                                        del processed_plates[filtered_text]

                                # Actualizar el tiempo de procesamiento de la patente
                                processed_plates[filtered_text] = current_time
                                print(f"PATENTE VÁLIDA ENCONTRADA: {filtered_text}")

                                # Construir la URL de la solicitud para obtener el ID del vehículo
                                url = f"{API_URL}/api/v2/vehiculo/patente/{filtered_text}"

                                # Configurar los encabezados de la solicitud con la clave API
                                headers = {
                                    'x-api-key': API_KEY,
                                    'Content-Type': 'application/json'
                                }

                                # Realizar la consulta a la API
                                try:
                                    response = requests.get(url, headers=headers)
                                    if response.status_code == 200:
                                        # Parsear la respuesta JSON
                                        data = response.json()
                                        print(f"Consulta exitosa para la patente {filtered_text}: {data}")

                                        # Verificar el estado y el mensaje
                                        if data.get('status') == 200 and data.get('message') == 'Vehiculo encontrado':
                                            vehicle_data = data.get('data', {})
                                            vehicle_id = vehicle_data.get('id')

                                            # Registrar la salida en la bitácora
                                            registro_exitoso = registrar_salida_bitacora(vehicle_id)
                                            if not registro_exitoso:
                                                print("No se pudo registrar la salida en la bitácora.")

                                        else:
                                            print(f"Error en la consulta para la patente {filtered_text}: {data.get('message', 'Error desconocido')}")
                                    else:
                                        print(f"Error en la consulta para la patente {filtered_text}: Código de estado {response.status_code}")
                                except Exception as e:
                                    print(f"Excepción al realizar la solicitud HTTP: {e}")
                            else:
                                print(f"TEXTO ENCONTRADO (NO ES PATENTE): {filtered_text}")
                        else:
                            print("No se detectó texto válido en la región.")

        # Salir con la tecla 'q'
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Liberar la cámara y cerrar ventanas
    cap.release()
    cv2.destroyAllWindows()
    # Cerrar la conexión con el Arduino
    if arduino:
        arduino.cerrar()

if __name__ == "__main__":
    main()
