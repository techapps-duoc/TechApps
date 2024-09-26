import cv2
import numpy as np
import pytesseract
import re

# ruta de Tesseract en tu sistema recordar instalar antes de usar
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'


# Rango de colores en HSV para blanco, amarillo y naranjo para resaltar busqueda patente
color_ranges = {
    'blanco': ([0, 0, 200], [180, 30, 255]),  # Blanco
    'amarillo': ([20, 100, 100], [30, 255, 255]),  # Amarillo
    'naranjo': ([10, 100, 100], [20, 255, 255])   # Naranjo
}

# Filtrar solo letras y números
def filtrar_patente(plate_text):
    # Usar expresiones eliminar simbolos y dejar solo letras y numeros
    return re.sub(r'[^A-Z0-9]', '', plate_text)

# Detectar colores de patente
def detectar_color_patente(frame):
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    
    for color, (lower, upper) in color_ranges.items():
        lower = np.array(lower, dtype=np.uint8)
        upper = np.array(upper, dtype=np.uint8)
        
        # Crear una mascara con el color seleccionado
        mask = cv2.inRange(hsv, lower, upper)
        
        # Aplicar la mascara a la imagen
        result = cv2.bitwise_and(frame, frame, mask=mask)
        
        # Retornar el frame y el color si hay coincidencia
        if np.any(result):
            return result, color
    return None, None

# Detectar las patentes en tiempo real desde la cámara
def detectar_patente(frame):
    # Detectar color patente
    color_frame, color = detectar_color_patente(frame)
    
    if color_frame is not None:
        # Convertir imagen a escala de grises
        gray = cv2.cvtColor(color_frame, cv2.COLOR_BGR2GRAY)
        
        # Suavizar imagen
        blur = cv2.GaussianBlur(gray, (5, 5), 0)
        
        # Detectar bordes
        edges = cv2.Canny(blur, 100, 200)
        
        # Encontrar contornos
        contours, _ = cv2.findContours(edges, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        
        # Almacenar la patente detectada
        detected_plate = ""

        for contour in contours:
            # Obtener el rectángulo contorno
            x, y, w, h = cv2.boundingRect(contour)

            # Filtrar por tamaño aproximado de una patente
            if 300 < w < 370 and 100 < h < 140:
                # Extraer el área de la posible patente
                plate_candidate = frame[y:y+h, x:x+w]
                
                # Usar OCR para leer la patente
                plate_text = pytesseract.image_to_string(plate_candidate, config='--psm 8')
                
                # Filtrar solo letras y números
                detected_plate = filtrar_patente(plate_text)

                # Dibujar el rectangulo alrededor de la patente detectada
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

                # Mostrar el texto detectado en la imagen
                cv2.putText(frame, f'Patente: {detected_plate}', (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (36, 255, 12), 2)
                
                return detected_plate

    return None