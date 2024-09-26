import cv2
from activacionCamara import iniciar_camara, leer_frame, mostrar_video, liberar_camara
from detectarPatente import detectar_patente

def main():
    # Iniciar la camara
    camara = iniciar_camara()
    
    if not camara:
        print("Error al iniciar la cámara.")
        return
    
    # almacenar patente 
    patente = ""

    while True:
        # Leer cámara
        frame = leer_frame(camara)
        if frame is None:
            break
        
        # Detectar patente en el frame 
        patente_detectada = detectar_patente(frame)

        # Si detecta patente almacena
        if patente_detectada:
            patente = patente_detectada
            print(f"Patente almacenada: {patente}")
        
        # Mostrar video tiempo real
        mostrar_video(frame)

        # Presionar 'q' pa salir
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Liberar camara y cerrar
    liberar_camara(camara)

if __name__ == '__main__':
    main()
