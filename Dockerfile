FROM ghcr.io/zaproxy/zaproxy:latest

USER root

# Instala herramientas necesarias
RUN apt update && apt install -y python3-pip jq wkhtmltopdf
# Librerías para envío de correos
RUN pip3 install --no-cache-dir --break-system-packages python-dotenv \
    google-api-python-client google-auth google-auth-httplib2 google-auth-oauthlib beautifulsoup4

# Crea el directorio de trabajo y establece permisos
RUN mkdir -p /zap/wrk/reportes && chmod -R 777 /zap/wrk

# Copia los archivos necesarios al contenedor
COPY sitios.json zap-scan.sh send_report.py clean_reports.py /zap/wrk/

# Permisos
RUN chmod +x /zap/wrk/zap-scan.sh && chown -R zap:zap /zap/wrk


USER zap
WORKDIR /zap/wrk

# Ejecuta el escaneo, convierte y envía por correo
CMD ["bash", "-c", "./zap-scan.sh && python3 clean_reports.py && python3 send_report.py"]

