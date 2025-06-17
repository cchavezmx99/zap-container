#!/bin/bash

REPORT_DIR="/zap/wrk/reportes"
mkdir -p "$REPORT_DIR"

echo $REPORT_DIR
echo "🕸️ Iniciando escaneo ZAP..."

while read -r URL; do
  DOMAIN=$(echo "$URL" | awk -F/ '{print $3}')
  OUTFILE="$REPORT_DIR/${DOMAIN}.html"
  echo "🔍 Escaneando $URL..."
  zap.sh -cmd -quickurl "$URL" -quickout "$OUTFILE"
  echo "✅ Reporte guardado en $OUTFILE"
done < <(jq -r '.[]' /zap/wrk/sitios.json)

echo "📦 Todos los escaneos completados."
