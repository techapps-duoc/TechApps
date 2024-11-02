import os

# Define la URL de la API y la clave API
API_URL_VEHICULO = "http://localhost:8082/api/v2/vehiculo/"
API_URL_BITACORA = "http://localhost:8082/api/v1/bitacora/"

# Clave API
API_KEY = os.getenv("API_KEY") or "4bd07733-5c7b-456a-81f8-751b12e382b3"
