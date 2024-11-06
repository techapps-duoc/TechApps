import cv2 
import time
import requests
import config
from detectarPatente import detectar_patente  # Importa la función desde detectarPatente.py
from datetime import datetime

# Variables globales para la última patente y resultados
ultima_patente = None
ultimo_resultado = None
ultimo_tiempo = 0
patentes_registradas = set()  # Conjunto para almacenar patentes ya registradas en la sesión

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

def registrar_entrada_bitacora(vehiculo):
    """Registra la entrada del vehículo en la bitácora con fecha de entrada y fecha de salida como null."""
    url = "http://35.226.113.153:30050/api/v2/bitacoras"
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': config.API_KEY
    }
    data = {
        "fechain": datetime.now().isoformat(),  # Fecha y hora actuales en formato ISO
        "fechaout": None,  # Fecha de salida inicializada en null
        "vehiculo": {
            "id": vehiculo.get("id"),
            "patente": vehiculo.get("patente"),
            "marca": vehiculo.get("marca"),
            "modelo": vehiculo.get("modelo"),
            "visita": vehiculo.get("visita"),
            "residente": vehiculo.get("residente"),
            "estacionamientoId": vehiculo.get("estacionamientoId")
        }
    }

    print("Datos enviados a la bitácora:", data)  # Imprime los datos para depuración

    try:
        response = requests.post(url, json=data, headers=headers)
        response.raise_for_status()
        if response.status_code == 201:
            print(f"Registro de entrada exitoso para vehículo ID: {vehiculo['id']}")
            patentes_registradas.add(vehiculo["id"])  # Añade la patente a las registradas
        else:
            print(f"Error al registrar la entrada: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar la entrada en bitácora: {e}")
        if response is not None:
            print("Detalles del error:", response.text)  # Muestra el mensaje de error del servidor si existe

def imprimir_resultados(resultados, frame):
    """Imprime los resultados de la consulta y los muestra en la pantalla."""
    global ultimo_resultado

    if resultados:
        vehiculo = resultados.get('data')
        if vehiculo:
            # Datos del vehículo
            detalles = [
                f"Patente: {vehiculo.get('patente', 'N/A')}",
                f"Marca: {vehiculo.get('marca', 'N/A')}",
                f"Modelo: {vehiculo.get('modelo', 'N/A')}",
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

            # Guarda el resultado para mostrarlo de forma persistente
            ultimo_resultado = detalles

            # Registrar la entrada del vehículo en la bitácora si no ha sido registrada
            if vehiculo.get('id') not in patentes_registradas:
                registrar_entrada_bitacora(vehiculo)

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

        # Mostrar la información persistente en el frame
        if ultimo_resultado:
            cv2.rectangle(frame, (10, 10), (600, 250), (0, 0, 0), -1)
            y_offset = 30
            for detalle in ultimo_resultado:
                cv2.putText(frame, detalle, (15, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
                y_offset += 25

        # Mostrar el frame en tiempo real
        cv2.imshow('Detección de Patente', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
