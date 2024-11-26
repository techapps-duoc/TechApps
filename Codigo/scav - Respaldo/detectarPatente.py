import cv2
import numpy as np
import pytesseract
import re

# Ruta de Tesseract en tu sistema (asegúrate de tenerlo instalado)
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Rango de colores en HSV para blanco, amarillo, naranjo y negro
COLOR_RANGES = {
    'blanco': ([0, 0, 200], [180, 30, 255]),  # Blanco
    'amarillo': ([20, 100, 100], [30, 255, 255]),  # Amarillo
    'naranjo': ([10, 100, 100], [20, 255, 255]),   # Naranjo
    'negro': ([0, 0, 0], [180, 255, 50])  # Negro
}

def filtrar_patente(plate_text):
    """Filtra solo letras y números de la cadena OCR."""
    return re.sub(r'[^A-Z0-9]', '', plate_text)

def detectar_color_patente(frame):
    """Detecta el color predominante de la patente (blanco, amarillo, naranjo o negro)."""
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    for color, (lower, upper) in COLOR_RANGES.items():
        mask = cv2.inRange(hsv, np.array(lower, dtype=np.uint8), np.array(upper, dtype=np.uint8))
        if np.count_nonzero(mask) > 500:  # Ajustar para evitar falsos positivos
            return color
    return None

def preprocesar_imagen(frame):
    """Convierte la imagen a escala de grises y aplica suavizado y umbral adaptativo."""
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    thresh = cv2.adaptiveThreshold(blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                cv2.THRESH_BINARY, 11, 2)
    return thresh

def detectar_contornos(frame):
    """Detecta los contornos relevantes en la imagen."""
    edges = cv2.Canny(frame, 50, 150)
    contours, _ = cv2.findContours(edges, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def es_patente_contorno(contour):
    """Filtra contornos por tamaño aproximado de una patente."""
    x, y, w, h = cv2.boundingRect(contour)
    aspect_ratio = w / h
    area = cv2.contourArea(contour)
    return 2.0 < aspect_ratio < 5.5 and 250 < area < 15000

def extraer_texto_patente(roi):
    """Aplica OCR en la región seleccionada y retorna el texto filtrado."""
    plate_text = pytesseract.image_to_string(roi, config='--psm 8').strip()
    return filtrar_patente(plate_text)

def detectar_patente(frame):
    """Detecta la patente en la imagen dada."""
    preprocessed_frame = preprocesar_imagen(frame)
    contours = detectar_contornos(preprocessed_frame)

    for contour in contours:
        if es_patente_contorno(contour):
            x, y, w, h = cv2.boundingRect(contour)
            roi = frame[y:y + h, x:x + w]
            patente = extraer_texto_patente(roi)

            if patente:
                color = detectar_color_patente(roi)
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
                cv2.putText(frame, f'Patente: {patente}', (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (36, 255, 12), 2)
                if color:
                    cv2.putText(frame, f'Color: {color}', (x, y + h + 20), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
                return patente

    return None

# Prueba en tiempo real con la cámara
def main():
    cap = cv2.VideoCapture(0)  # Asegúrate de que la cámara esté conectada
    if not cap.isOpened():
        print("Error al abrir la cámara.")
        return

    while True:
        ret, frame = cap.read()
        if not ret:
            print("No se pudo obtener el frame de la cámara.")
            break

        patente = detectar_patente(frame)
        if patente:
            print(f"Patente detectada: {patente}")

        cv2.imshow('Detección de Patente', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
