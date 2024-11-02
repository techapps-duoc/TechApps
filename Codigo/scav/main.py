import cv2
import time
import requests
import config
from datetime import datetime, timedelta
from detectarPatente import detectar_patente  # Importa la función desde detectarPatente.py

# Variables globales para la última patente y resultados
ultima_patente = None
ultimo_resultado = None
ultimo_tiempo = 0
registro_entradas = {}

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

def registrar_bitacora(vehiculo_id, tipo):
    """Registra la entrada o salida del vehículo en la bitácora."""
    url = f"{config.API_URL_BITACORA}bitacora"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }
    fecha_actual = datetime.now().isoformat()

    if tipo == "entrada":
        data = {
            "vehiculo_id": vehiculo_id,
            "fecha_in": fecha_actual
        }
    elif tipo == "salida":
        data = {
            "vehiculo_id": vehiculo_id,
            "fecha_out": fecha_actual
        }

    try:
        response = requests.post(url, json=data, headers=headers)
        response.raise_for_status()
        if response.status_code == 201:
            print(f"{tipo.capitalize()} registrada exitosamente en la bitácora.")
        else:
            print(f"Error al registrar la {tipo}: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar la {tipo}: {e}")

def manejar_bitacora(patente, vehiculo_id):
    """Maneja el registro de entrada y salida en la bitácora."""
    global registro_entradas
    tiempo_actual = datetime.now()

    if patente in registro_entradas:
        tiempo_ultimo_registro = registro_entradas[patente]
        if tiempo_actual - tiempo_ultimo_registro >= timedelta(seconds=30):
            # Registra salida si pasaron más de 30 segundos
            print(f"Registrando salida para la patente: {patente}")
            registrar_bitacora(vehiculo_id, "salida")
            registro_entradas.pop(patente)  # Remueve la patente después de la salida
    else:
        # Registra una nueva entrada
        print(f"Registrando entrada para la patente: {patente}")
        registrar_bitacora(vehiculo_id, "entrada")
        registro_entradas[patente] = tiempo_actual

def imprimir_resultados(resultados, frame):
    """Imprime los resultados de la consulta y los muestra en la pantalla."""
    global ultimo_resultado

    if resultados:
        vehiculo = resultados.get('data')
        if vehiculo:
            patente = vehiculo['patente']
            vehiculo_id = vehiculo['id']
            manejar_bitacora(patente, vehiculo_id)

            detalles = [
                f"Patente: {patente}",
                f"Marca: {vehiculo['marca']}",
                f"Modelo: {vehiculo['modelo']}",
                f"Color: {vehiculo['color']}"
            ]

            # Verifica si es un residente o una visita
            residente = vehiculo.get('residente')
            visita = vehiculo.get('visita')

            if isinstance(residente, dict):
                detalles.extend([
                    "--- Datos del Residente ---",
                    f"Nombre: {residente.get('nombre', 'N/A')}",
                    f"Correo: {residente.get('correo', 'N/A')}",
                    f"Torre: {residente.get('torre', 'N/A')}",
                    f"Departamento: {residente.get('departamento', 'N/A')}"
                ])
            elif isinstance(visita, dict):
                detalles.extend([
                    "--- Datos del Visitante ---",
                    f"Nombre: {visita.get('nombre', 'N/A')}",
                    f"Apellido: {visita.get('apellido', 'N/A')}",
                    f"RUT: {visita.get('rut', 'No disponible')}"
                ])
            else:
                detalles.append("El vehículo no está asociado a un residente ni a una visita.")

            ultimo_resultado = detalles

        else:
            ultimo_resultado = ["No se encontró información del vehículo."]
    else:
        ultimo_resultado = ["No se encontró información del vehículo."]

    # Mostrar la información en la pantalla
    if ultimo_resultado:
        cv2.rectangle(frame, (10, 10), (600, 250), (0, 0, 0), -1)
        y_offset = 30
        for detalle in ultimo_resultado:
            cv2.putText(frame, detalle, (15, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
            y_offset += 25

def main():
    """Función principal para capturar video y detectar patentes."""
    global ultima_patente, ultimo_tiempo

    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    print("Iniciando la detección de patentes y consulta a la API...")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            break

        patente = detectar_patente(frame)

        # Consultar la API cada 5 segundos o cuando se detecte una nueva patente
        tiempo_actual = time.time()
        if patente and (patente != ultima_patente or tiempo_actual - ultimo_tiempo > 5):
            print(f"Patente detectada: {patente}")
            resultados = consultar_vehiculo(patente)
            imprimir_resultados(resultados, frame)
            ultima_patente = patente
            ultimo_tiempo = tiempo_actual

        # Muestra un cuadro de estado (verde si hay datos, rojo si no)
        color_cuadro = (0, 255, 0) if ultimo_resultado and "No se encontró" not in ultimo_resultado[0] else (0, 0, 255)
        cv2.rectangle(frame, (frame.shape[1] - 70, frame.shape[0] - 70), (frame.shape[1] - 10, frame.shape[0] - 10), color_cuadro, -1)

        # Mostrar el frame en tiempo real
        cv2.imshow('Detección de Patente', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
