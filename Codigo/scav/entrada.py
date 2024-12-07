import cv2
import pytesseract
import re
import time
import requests
from datetime import datetime
from arduino_control import ArduinoControl
from config import API_URL, API_KEY, API_URL2  # Importar API_URL y API_KEY desde config.py

# Inicializar conexión con Arduino
try:
    arduino = ArduinoControl(port='COM7')
    arduino.enviar_comando("subir")
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

def registrar_entrada_bitacora(vehiculo_id):
    """Registra la entrada del vehículo en la bitácora y envía comando al Arduino."""
    url = f"{API_URL}/api/v2/bitacora"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': API_KEY
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
            # Enviar comando al Arduino para subir la barrera
            if arduino:
                arduino.enviar_comando("subir")
            else:
                print("Arduino no está conectado.")
            return True
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar en bitácora: {e}")
    return False

def verificar_autorizacion_visita(visita_id):
    """Verifica si la visita está autorizada basándose en el código de estado HTTP."""
    url = f"{API_URL2}/api/v2/visita/verificar-autorizacion/{visita_id}"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': API_KEY
    }
    try:
        response = requests.get(url, headers=headers)
        print(f"Respuesta de la API de verificación: Código de estado {response.status_code}")
        if response.status_code == 200:
            # La visita está autorizada
            return True
        elif response.status_code == 403:
            print("La visita no tiene una autorización aprobada.")
        elif response.status_code == 404:
            print("No se encontró un registro de visita en el período especificado.")
        else:
            print(f"Error al verificar autorización de la visita. Código de estado: {response.status_code}")
        return False
    except requests.exceptions.RequestException as e:
        print(f"Error al verificar autorización de la visita: {e}")
        return False

# Variables para control de tiempo y patentes
last_detection_time = 0
processed_plates = {}  # Patentes procesadas exitosamente con su tiempo de procesamiento
pending_plates = {}    # Patentes pendientes de respuesta 200, con tiempo de último intento
pending_visits = {}    # Visitas pendientes de autorización

# Intervalo de tiempo para permitir re-procesar una patente (en segundos)
PLATE_REPROCESS_INTERVAL = 10  # 1 minutos

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
            if len(approx) == 4 and area > 5000:  # Ajuste del área mínima
                aspect_ratio = float(w) / h
                if aspect_ratio > 2.0:  # Relajar el aspecto inicial
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

                    if filtered_text:  # Si se detectó texto
                        if es_patente_valida(filtered_text):
                            # Verificar si la patente fue procesada y si ha pasado el tiempo suficiente
                            if filtered_text in processed_plates:
                                time_since_processed = current_time - processed_plates[filtered_text]
                                if time_since_processed < PLATE_REPROCESS_INTERVAL:
                                    remaining_time = int(PLATE_REPROCESS_INTERVAL - time_since_processed)
                                    print(f"Patente {filtered_text} ya fue procesada exitosamente hace {int(time_since_processed)} segundos. Volverá a procesarse en {remaining_time} segundos.")
                                    continue
                                else:
                                    # Ha pasado el tiempo suficiente, se puede re-procesar
                                    del processed_plates[filtered_text]

                            # Verificar si es tiempo de volver a intentar con patentes pendientes
                            should_retry = True
                            if filtered_text in pending_plates:
                                last_attempt_time = pending_plates[filtered_text]
                                if current_time - last_attempt_time < 3:
                                    should_retry = False  # No ha pasado suficiente tiempo
                            else:
                                # Primera vez que se encuentra esta patente
                                pending_plates[filtered_text] = current_time

                            if should_retry:
                                pending_plates[filtered_text] = current_time
                                print(f"PATENTE VÁLIDA ENCONTRADA: {filtered_text}")

                                # Construir la URL de la solicitud
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
                                            residente_data = vehicle_data.get('residente')
                                            visita_data = vehicle_data.get('visita')

                                            if residente_data and residente_data != 'No registrado':
                                                # Es un residente
                                                if isinstance(residente_data, dict):
                                                    residente_nombre = residente_data.get('nombre', 'Desconocido')
                                                    residente_apellido = residente_data.get('apellido', '')
                                                    full_name = f"{residente_nombre} {residente_apellido}".strip()
                                                else:
                                                    full_name = 'Residente Desconocido'
                                                print(f"Bienvenido, {full_name}")

                                                # Registrar en la bitácora
                                                registro_exitoso = registrar_entrada_bitacora(vehicle_id)
                                                if not registro_exitoso:
                                                    print("No se pudo registrar la entrada en la bitácora.")

                                                # Marcar la patente como procesada exitosamente con el tiempo actual
                                                processed_plates[filtered_text] = current_time
                                                # Remover de pendientes
                                                if filtered_text in pending_plates:
                                                    del pending_plates[filtered_text]

                                            elif visita_data:
                                                # Es una visita
                                                visita_id = visita_data.get('id')
                                                visita_nombre = visita_data.get('nombre', 'Desconocido')
                                                visita_apellido = visita_data.get('apellido', '')
                                                full_name = f"{visita_nombre} {visita_apellido}".strip()

                                                # Agregar la visita a las pendientes de autorización
                                                if visita_id not in pending_visits:
                                                    pending_visits[visita_id] = {
                                                        'start_time': current_time,
                                                        'last_check_time': 0,
                                                        'name': full_name,
                                                        'plate': filtered_text,
                                                        'vehicle_id': vehicle_id  # Almacenamos el vehicle_id
                                                    }
                                                    print(f"Esperando confirmación para la visita {full_name}")
                                                else:
                                                    print(f"Ya se está esperando confirmación para la visita {full_name}")

                                            else:
                                                print("El vehículo no está asociado ni a un residente ni a una visita.")

                                            # Remover de pendientes
                                            if filtered_text in pending_plates:
                                                del pending_plates[filtered_text]

                                        else:
                                            print(f"Error en la consulta para la patente {filtered_text}: {data.get('message', 'Error desconocido')}")
                                            # Mantener la patente en pendientes para volver a intentar
                                    else:
                                        print(f"Error en la consulta para la patente {filtered_text}: Código de estado {response.status_code}")
                                        # Mantener la patente en pendientes para volver a intentar
                                except Exception as e:
                                    print(f"Excepción al realizar la solicitud HTTP: {e}")
                                    # Mantener la patente en pendientes para volver a intentar

                                # Dibujar el rectángulo y mostrar el texto
                                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 3)
                                cv2.putText(frame, filtered_text, (x, y - 10), 1, 2.2, (0, 255, 0), 3)
                            else:
                                print(f"Esperando para reintentar con la patente {filtered_text}.")
                        else:
                            print(f"TEXTO ENCONTRADO (NO ES PATENTE): {filtered_text}")
                    else:
                        print("No se detectó texto válido en la región.")

    # Verificar autorizaciones pendientes de visitas
    for visita_id, info in list(pending_visits.items()):
        current_time = time.time()
        # Si han pasado más de 3 minutos, dejar de consultar
        if current_time - info['start_time'] > 180:  # 3 minutos = 180 segundos
            print(f"No se recibió confirmación para la visita {info['name']} en el tiempo límite. Se cancela la espera.")
            del pending_visits[visita_id]
            continue

        # Verificar si han pasado 3 segundos desde el último intento
        if current_time - info['last_check_time'] >= 3:
            info['last_check_time'] = current_time
            autorizado = verificar_autorizacion_visita(visita_id)
            if autorizado:
                print(f"Bienvenido, {info['name']}")

                # Registrar en la bitácora utilizando el vehicle_id almacenado
                registro_exitoso = registrar_entrada_bitacora(info['vehicle_id'])
                if not registro_exitoso:
                    print("No se pudo registrar la entrada en la bitácora.")

                # Marcar la patente como procesada exitosamente con el tiempo actual
                processed_plates[info['plate']] = current_time
                del pending_visits[visita_id]
            else:
                print(f"Visita {info['name']} aún no autorizada. Reintentando en 3 segundos.")

    # Salir con la tecla 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Liberar la cámara y cerrar ventanas
cap.release()
cv2.destroyAllWindows()
arduino.cerrar()

if __name__ == "__main__":
    main()
