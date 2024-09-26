import cv2

def iniciar_camara(ancho=1280, alto=720, indice=0):
    # Iniciar la cámara
    cap = cv2.VideoCapture(indice)

    # Verificar si camara abrio correctamente
    if not cap.isOpened():
        print("No se pudo abrir la cámara.")
        return None
    
    # Configurar el tamaño del video
    cap.set(3, ancho)  # Ancho
    cap.set(4, alto)   # Alto

    return cap

def leer_frame(camara):
    # Leer frame de la cámara
    ret, frame = camara.read()
    if not ret:
        print("No se pudo capturar el frame.")
        return None
    return frame

def mostrar_video(frame, ventana_nombre='Video en tiempo real'):
    # Mostrar video tiempo real
    cv2.imshow(ventana_nombre, frame)
    
def liberar_camara(camara):
    # Liberar la camara y cerrar ventanas
    camara.release()
    cv2.destroyAllWindows()
