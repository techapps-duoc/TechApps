import cv2

def iniciar_camara(ancho=1280, alto=720, indice=0):
    """Inicia la cámara con el índice especificado y configura el tamaño de captura.

    Args:
        ancho (int): Ancho de la captura de video.
        alto (int): Alto de la captura de video.
        indice (int): Índice de la cámara a usar.

    Returns:
        cv2.VideoCapture: Objeto de la cámara si se abrió correctamente, None en caso contrario.
    """
    try:
        cap = cv2.VideoCapture(indice)

        if not cap.isOpened():
            print("No se pudo abrir la cámara.")
            return None
        
        # Configurar el tamaño del video
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, ancho)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, alto)

        return cap
    except Exception as e:
        print(f"Error al iniciar la cámara: {e}")
        return None

def leer_frame(camara):
    """Lee un frame de la cámara y maneja posibles errores de lectura.

    Args:
        camara (cv2.VideoCapture): Objeto de la cámara.

    Returns:
        np.ndarray: Frame capturado si se pudo leer, None en caso contrario.
    """
    try:
        ret, frame = camara.read()
        if not ret:
            print("No se pudo capturar el frame.")
            return None
        return frame
    except Exception as e:
        print(f"Error al leer el frame: {e}")
        return None

def mostrar_video(frame, ventana_nombre='Video en tiempo real'):
    """Muestra el frame en una ventana en tiempo real.

    Args:
        frame (np.ndarray): Frame a mostrar.
        ventana_nombre (str): Título de la ventana.
    """
    try:
        cv2.imshow(ventana_nombre, frame)
    except Exception as e:
        print(f"Error al mostrar el video: {e}")

def liberar_camara(camara):
    """Libera la cámara y cierra todas las ventanas abiertas de OpenCV.

    Args:
        camara (cv2.VideoCapture): Objeto de la cámara.
    """
    try:
        if camara is not None:
            camara.release()
        cv2.destroyAllWindows()
    except Exception as e:
        print(f"Error al liberar la cámara: {e}")
