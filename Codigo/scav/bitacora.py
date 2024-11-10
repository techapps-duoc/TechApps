import requests
from datetime import datetime
import config

def registrar_entrada(vehiculo_id):
    url = f"{config.API_URL_BASE}/bitacora"
    headers = {
        'Content-Type': 'application/json',
        'x-api-key': config.API_KEY
    }
    data = {
        "vehiculoId": vehiculo_id,
        "fechain": datetime.now().isoformat(),
        "fechaout": None
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        response.raise_for_status()
        print(f"Registro de entrada exitoso para vehículo ID: {vehiculo_id}")
    except requests.exceptions.RequestException as e:
        print(f"Error al registrar en bitácora: {e}")

def consultar_vehiculo(patente):
    url = f"{config.API_URL_VEHICULO}patente/{patente}"
    headers = {
        'Content-Type': 'application/json',
        'x-api-key': config.API_KEY
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error al consultar el vehículo: {e}")
        return None
