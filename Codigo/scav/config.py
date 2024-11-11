import os

# Define la URL de la API y la clave API
API_URL_VEHICULO = "http://34.55.12.174:30040/api/v2/vehiculo/"
API_URL_BITACORA_ENTRADA = "http://34.55.12.174:30040/api/v2/bitacora"
API_URL_BITACORA_SALIDA = "http://34.55.12.174:30040/api/v2/bitacora/salida"

# Clave API
API_KEY = os.getenv("API_KEY") or "4bd07733-5c7b-456a-81f8-751b12e382b3"
