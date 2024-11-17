FROM public.ecr.aws/docker/library/amazoncorretto:17-alpine-jdk
# Añadir la zona horaria para América/Santiago
RUN apk --no-cache add tzdata
ENV TZ=America/Santiago
# Crear y usar un directorio temporal
VOLUME /tmp
# Copiar el archivo JAR desde el target al contenedor
COPY target/*.jar /tmp/app.jar
# Usar un usuario sin privilegios
USER 185
# Definir opciones de Java
ENV JAVA_OPTS=""
# Exponer el puerto para que Kubernetes pueda enrutar al contenedor
EXPOSE 8080
# Configurar el punto de entrada
ENTRYPOINT exec java -Dspring.profiles.active=kubernetes $JAVA_OPTS -jar /tmp/app.jar
