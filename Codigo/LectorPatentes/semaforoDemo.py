import cv2

# Inicializar los colores
color_green = (0, 255, 0)
color_red = (0, 0, 255)

# Definir el color de los cuadros del semáforo
semaforo_colors = [color_green,color_red]
current_color = color_red  # Comenzar con el rojo encendido

face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    # Cambiar el color del semáforo dependiendo de la detección
    if len(faces) > 0:
        current_color = color_green  # Si hay rostros, verde
    else:
        current_color = color_red  # Si no hay rostros, rojo

    # Dibujar el semáforo
    height, width, _ = frame.shape
    semaforo_x = width - 60  # Posición del semáforo (esquina superior derecha)
    semaforo_y = 30
    semaforo_width = 60
    semaforo_height = 120  # Altura total del semáforo

    # Dibujar los rectángulos del semáforo
    for i in range(2):
        top_left_y = semaforo_y + i * (semaforo_height // 2)
        bottom_right_y = top_left_y + (semaforo_height // 2)
        color = semaforo_colors[i] if current_color == semaforo_colors[i] else (50, 50, 50)  # Encender solo el color actual
        cv2.rectangle(frame, (semaforo_x, top_left_y), (semaforo_x + semaforo_width, bottom_right_y), color, -1)

    # Dibujar los cuadros alrededor de los rostros detectados
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)

    # Mostrar la imagen con el semáforo
    cv2.imshow('Deteccion de Rostros con Semaforo', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
