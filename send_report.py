import os
import subprocess
import smtplib
from email.message import EmailMessage

EMAIL_ORIGEN = os.environ.get("SMTP_USER")
EMAIL_DESTINO = os.environ.get("SMTP_TO", EMAIL_ORIGEN).split(',')
CONTRASENA = os.environ.get("SMTP_PASS")

REPORTE_DIR = "/zap/wrk/reportes"

msg = EmailMessage()
msg['Subject'] = '📊 Reporte de Seguridad ZAP'
msg['From'] = EMAIL_ORIGEN
msg['To'] = ', '.join(EMAIL_DESTINO)

cuerpo = ["Se adjuntan los reportes de seguridad generados por ZAP.\n"]
reportes_adjuntados = 0

# Convertir HTML → PDF
for archivo in os.listdir(REPORTE_DIR):
    if archivo.endswith('.html'):
        html_path = os.path.join(REPORTE_DIR, archivo)
        pdf_path = html_path.replace('.html', '.pdf')

        try:
            subprocess.run(['wkhtmltopdf', html_path, pdf_path], check=True)
            if os.path.getsize(pdf_path) < 5000:
                cuerpo.append(f"⚠️ Reporte vacío: {archivo}")
                continue  # No adjuntes este PDF
            reportes_adjuntados += 1
        except Exception as e:
            cuerpo.append(f"❌ Error al convertir {archivo}: {e}")

if reportes_adjuntados == 0:
    cuerpo.append("\n❌ No se adjuntó ningún reporte válido.")

# ✅ Establecer el contenido ANTES de añadir los adjuntos
msg.set_content("\n".join(cuerpo))

# 🔗 Ahora adjuntar los PDFs
for archivo in os.listdir(REPORTE_DIR):
    if archivo.endswith('.pdf'):
        ruta = os.path.join(REPORTE_DIR, archivo)
        with open(ruta, 'rb') as f:
            msg.add_attachment(
                f.read(),
                maintype='application',
                subtype='pdf',
                filename=os.path.basename(ruta)
            )

# Enviar correo
try:
    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login(EMAIL_ORIGEN, CONTRASENA)
        smtp.send_message(msg)
        print("✅ Correo enviado con PDF(s) adjunto(s)")
except Exception as e:
    print(f"❌ Error al enviar correo: {e}")

