
import cv2
import numpy as np
import pytesseract
import re

pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

def filtrar_patente(plate_text):
    return re.sub(r'[^A-Z0-9]', '', plate_text)

def aumentar_contraste_y_reducir_ruido(gray):
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)
    return cv2.fastNlMeansDenoising(enhanced, None, 30, 7, 21)

def preprocesar_imagen(frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    enhanced = aumentar_contraste_y_reducir_ruido(gray)
    thresh = cv2.adaptiveThreshold(enhanced, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                   cv2.THRESH_BINARY, 11, 2)
    return thresh

def detectar_contornos(frame):
    edges = cv2.Canny(frame, 100, 200)
    contours, _ = cv2.findContours(edges, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    return contours

def es_patente_contorno(contour):
    x, y, w, h = cv2.boundingRect(contour)
    aspect_ratio = w / h
    area = cv2.contourArea(contour)
    return 2.5 < aspect_ratio < 5.5 and 500 < area < 20000

def extraer_texto_patente(roi):
    roi = cv2.resize(roi, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
    roi = cv2.GaussianBlur(roi, (5, 5), 0)
    plate_text = pytesseract.image_to_string(roi, config='--psm 7').strip()
    return filtrar_patente(plate_text)

def detectar_patente(frame, return_intermediate=False):
    """
    Detecta la patente en la imagen dada, opcionalmente retornando imágenes intermedias.
    """
    # Reducir la resolución para mejorar el rendimiento
    frame = cv2.resize(frame, (640, 480))

    # Convertir a escala de grises y aplicar preprocesamiento
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray = cv2.blur(gray, (3, 3))
    canny = cv2.Canny(gray, 150, 200)
    canny = cv2.dilate(canny, None, iterations=1)

    # Mostrar la imagen de bordes para depuración
    if return_intermediate:
        cv2.imshow('Bordes (Canny)', canny)

    # Encontrar contornos
    contours, _ = cv2.findContours(canny, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    roi = None
    for contour in contours:
        area = cv2.contourArea(contour)
        x, y, w, h = cv2.boundingRect(contour)
        epsilon = 0.09 * cv2.arcLength(contour, True)
        approx = cv2.approxPolyDP(contour, epsilon, True)

        # Filtrar contornos con forma rectangular y tamaño adecuado
        if len(approx) == 4 and area > 5000:
            aspect_ratio = float(w) / h
            if aspect_ratio > 2.0:
                # Recortar la región de la patente
                roi = gray[y:y + h, x:x + w]

                # Reducir el tamaño de la región antes de OCR
                roi = cv2.resize(roi, (200, 50))

                # Reconocer texto con Tesseract
                text = pytesseract.image_to_string(roi, config='--psm 8 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')

                # Filtrar solo caracteres alfanuméricos
                filtered_text = re.sub(r'[^A-Za-z0-9]', '', text).upper()

                # Mostrar la ROI solo si se detecta texto válido
                if return_intermediate and filtered_text:
                    cv2.imshow('Patente Detectada', roi)

                if filtered_text:
                    return (filtered_text, canny, roi) if return_intermediate else filtered_text

    return (None, canny, roi) if return_intermediate else None

