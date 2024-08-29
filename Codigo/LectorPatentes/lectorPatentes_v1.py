import cv2
import numpy as np

# Captura de video desde la cámara
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    
    if not ret:
        break
    
    # Convertir la imagen a escala de grises
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # Aplicar desenfoque para reducir el ruido
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # Aplicar detección de bordes usando Canny
    edged = cv2.Canny(blurred, 50, 150)
    
    # Encontrar contornos en la imagen con bordes detectados
    contours, _ = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    for contour in contours:
        # Aproximar la forma del contorno
        approx = cv2.approxPolyDP(contour, 0.02 * cv2.arcLength(contour, True), True)
        # Verificar si el contorno tiene 4 vértices (es un rectángulo)
        if len(approx) == 4:
            
            # Obtener el área del contorno
            area = cv2.contourArea(contour)
            # Filtro por área mínima para evitar ruido
            if area > 1000:
                print('Area: ',area)
                # Verificar si el contorno es aproximadamente un rectángulo
                x, y, w, h = cv2.boundingRect(approx)
                aspectRatio = float(w) / h
                print('aspectRatio: ',aspectRatio)
                if 0.5 <= aspectRatio <= 2.0:  # Ajustar esto según tus necesidades (casi cuadrados)
                    x, y, w, h = cv2.boundingRect(approx)
                    # Dibujar el contorno del rectángulo en verde
                    cv2.drawContours(frame, [approx], 0, (0, 255, 0), 3)
    
    # Mostrar la imagen con el rectángulo detectado
    cv2.imshow("Deteccion de rectangulo", frame)
    
    # Presionar 'q' para salir
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
