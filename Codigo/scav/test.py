import cv2
import pytesseract
import re

# Configurar la ruta de Tesseract
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Inicializar la cámara web
cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

if not cap.isOpened():
    print("Error: No se pudo acceder a la cámara.")
    exit()

def es_patente_valida(texto):
    """
    Verifica si el texto cumple con el formato de una patente chilena (2 letras + 4 números).
    """
    return bool(re.fullmatch(r'[A-Z]{4}[0-9]{2}', texto))

while True:
    ret, frame = cap.read()
    if not ret:
        print("Error: No se pudo leer el cuadro de la cámara.")
        break

    # Reducir la resolución para mejorar el rendimiento
    frame = cv2.resize(frame, (640, 480))

    # Convertir a escala de grises y aplicar preprocesamiento
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray = cv2.blur(gray, (3, 3))
    canny = cv2.Canny(gray, 150, 200)
    canny = cv2.dilate(canny, None, iterations=1)

    # Mostrar la imagen de bordes para depuración
    cv2.imshow('Canny', canny)

    # Encontrar contornos
    cnts, _ = cv2.findContours(canny, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    for c in cnts:
        area = cv2.contourArea(c)
        x, y, w, h = cv2.boundingRect(c)
        epsilon = 0.09 * cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, epsilon, True)

        # Filtrar contornos con forma rectangular y tamaño adecuado
        if len(approx) == 4 and area > 5000:  # Ajuste del área mínima
            aspect_ratio = float(w) / h
            if aspect_ratio > 2.0:  # Relajar el aspecto inicial
                # Recortar la región de la patente
                placa = gray[y:y + h, x:x + w]
                
                # Reducir el tamaño de la región antes de OCR
                placa = cv2.resize(placa, (200, 50))

                # Reconocer texto con Tesseract
                text = pytesseract.image_to_string(placa, config='--psm 8 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')

                # Filtrar solo caracteres alfanuméricos
                filtered_text = re.sub(r'[^A-Za-z0-9]', '', text).upper()

                # Mostrar la placa recortada para depuración
                cv2.imshow('Placa Recortada', placa)

                if filtered_text:  # Si se detectó texto
                    if es_patente_valida(filtered_text):
                        print(f"PATENTE VÁLIDA ENCONTRADA: {filtered_text}")
                        # Dibujar el rectángulo y mostrar el texto
                        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 3)
                        cv2.putText(frame, filtered_text, (x, y - 10), 1, 2.2, (0, 255, 0), 3)
                    else:
                        print(f"TEXTO ENCONTRADO (NO ES PATENTE): {filtered_text}")
                else:
                    print("No se detectó texto válido en la región.")

    # Mostrar el cuadro procesado
    cv2.imshow('Cámara', frame)

    # Salir con la tecla 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Liberar la cámara y cerrar ventanas
cap.release()
cv2.destroyAllWindows()
