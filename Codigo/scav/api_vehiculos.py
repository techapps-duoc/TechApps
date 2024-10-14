import requests

API_URL_VEHICULO = "http://localhost:8080/api/v1/vehiculo/patente/"
API_URL_RESIDENTE = "http://localhost:8080/api/v1/residente/"

def obtener_informacion_residente(residente_id):
    """Consulta los datos del residente por ID."""
    url_residente = f"{API_URL_RESIDENTE}{residente_id}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    try:
        response = requests.get(url_residente, headers=headers, timeout=10)
        if response.status_code == 200:
            residente_data = response.json().get('data', {})
            if residente_data:
                print("\n--- Información del Residente ---")
                for key, value in residente_data.items():
                    print(f"{key}: {value}")
            else:
                print("No se encontró información del residente.")
        else:
            print(f"Error al consultar residente: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error en la solicitud al consultar residente: {e}")

def consultar_patente(patente):
    """Consulta la información del vehículo y del residente asociado."""
    url_vehiculo = f"{API_URL_VEHICULO}{patente}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

    try:
        response = requests.get(url_vehiculo, headers=headers, timeout=10)
        if response.status_code == 200:
            vehiculo_data = response.json().get('data', {})
            if vehiculo_data:
                print("\n--- Detalles del Vehículo ---")
                for key, value in vehiculo_data.items():
                    print(f"{key}: {value}")

                # Consultar residente si existe el ID
                residente_id = vehiculo_data.get('residenteId')
                if residente_id:
                    obtener_informacion_residente(residente_id)
                else:
                    print("No se encontró residente asociado al vehículo.")
            else:
                print("No se encontró información del vehículo.")
        elif response.status_code == 404:
            print(f"No se encontró ningún vehículo con la patente: {patente}")
        else:
            print(f"Error al consultar vehículo: {response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error en la solicitud al consultar vehículo: {e}")
