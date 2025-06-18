FROM ghcr.io/zaproxy/zaproxy:latest

USER root

# Instala herramientas necesarias
RUN apt update && apt install -y python3-pip jq wkhtmltopdf

# Librerías para envío de correos
RUN pip3 install --no-cache-dir --break-system-packages python-dotenv \
    google-api-python-client google-auth google-auth-httplib2 google-auth-oauthlib beautifulsoup4

# Copia los scripts ZAP necesarios
COPY zaproxy/docker/zap-full-scan.py /zap/docker/zap-full-scan.py
COPY zaproxy/docker/zap_common.py    /zap/docker/zap_common.py

# Copia tus scripts personalizados y archivos de configuración
COPY sitios.json zap-scan.sh send_report.py clean_reports.py /zap/wrk/

# Prepara el entorno de trabajo
RUN mkdir -p /zap/wrk/reportes && chmod -R 777 /zap/wrk
RUN chmod +x /zap/wrk/zap-scan.sh && chown -R zap:zap /zap/wrk

USER zap
WORKDIR /zap/wrk

# Ejecuta escaneo y luego el envío de correos
CMD ["bash", "-c", "./zap-scan.sh && echo '🔁 Ejecutando envío...' && python3 send_report.py || echo '❌ Falló alguna parte del flujo'"]

