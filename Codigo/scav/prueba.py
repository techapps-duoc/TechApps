import cv2
import requests
import time
from activacionCamara import iniciar_camara, leer_frame, mostrar_video, liberar_camara
from detectarPatente import detectar_patente

API_URL_VEHICULO = "http://localhost:8080/api/v1/vehiculo/patente/"
API_URL_RESIDENTE = "http://localhost:8080/api/v1/residente/"

def obtener_informacion_residente(residente_id):
    """Consulta los datos del residente según su ID y los imprime."""
    url_residente = f"{API_URL_RESIDENTE}{residente_id}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    try:
        response = requests.get(url_residente, headers=headers, timeout=10)
        if response.status_code == 200:
            residente_data = response.json().get('data', {})
            if residente_data:
                print("\n--- Información del Residente Asociado ---")
                for key, value in residente_data.items():
                    print(f"{key}: {value}")
                print("\nAcceso permitido. El portón se abrirá.")  # Simulación de apertura
            else:
                print("No se encontró información del residente.")
        else:
            print(f"Error al consultar residente. Estado: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error en la solicitud al consultar residente: {e}")

def imprimir_detalles_vehiculo(vehiculo_data):
    """Imprime los detalles del vehículo de forma clara."""
    print("\n--- Detalles del Vehículo ---")
    for key, value in vehiculo_data.items():
        if key != "residente":  # Evitar imprimir residente como diccionario completo
            print(f"{key}: {value}")

    # Si el vehículo tiene un residente asociado, mostrar los detalles
    residente_data = vehiculo_data.get('residente')
    if residente_data and isinstance(residente_data, dict):
        print("\n--- Información del Residente Asociado ---")
        for key, value in residente_data.items():
            print(f"{key}: {value}")
    else:
        print("No se encontró residente asociado al vehículo.")

def consultar_patente(patente):
    """Consulta los datos del vehículo por patente y muestra información del residente si existe."""
    url_vehiculo = f"{API_URL_VEHICULO}{patente}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    try:
        response = requests.get(url_vehiculo, headers=headers, timeout=10)
        if response.status_code == 200:
            vehiculo_data = response.json().get('data', {})
            if vehiculo_data:
                imprimir_detalles_vehiculo(vehiculo_data)

                # Verificar si tiene un residente asociado
                residente_id = vehiculo_data.get('residenteId')
                if residente_id:
                    obtener_informacion_residente(residente_id)
                else:
                    print("Este vehículo no pertenece a un residente. Esperando confirmación manual.")
            else:
                print("No se encontró información del vehículo.")
        elif response.status_code == 404:
            print(f"No se encontró ningún vehículo con la patente: {patente}")
        else:
            print(f"Error al consultar vehículo. Estado: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error en la solicitud al consultar vehículo: {e}")

def main():
    """Función principal para detectar patentes en tiempo real desde la cámara."""
    camara = iniciar_camara()

    if not camara:
        print("Error al iniciar la cámara.")
        return

    while True:
        frame = leer_frame(camara)
        if frame is None:
            break

        patente = detectar_patente(frame)

        if patente:
            print(f"Patente detectada: {patente}")
            consultar_patente(patente)

        mostrar_video(frame)

        # Esperar 3 segundos antes de volver a escanear para evitar repeticiones rápidas
        time.sleep(3)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    liberar_camara(camara)

if __name__ == '__main__':
    main()
