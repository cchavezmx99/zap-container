#!/bin/bash
set -e
set -x

echo "🕸️ Iniciando escaneo ZAP..."

SITIOS_FILE="sitios.json"
CONFIG_FILE="zap-config.conf"
REPORT_DIR="/zap/wrk/reportes"
FULL_SCAN_SCRIPT="/zap/docker/zap-full-scan.py"

mkdir -p "$REPORT_DIR"

if [ ! -f "$SITIOS_FILE" ]; then
  echo "❌ No se encontró el archivo $SITIOS_FILE"
  exit 1
fi

# ⚙️ Generar zap-config.conf manualmente (sin conexión al demonio)
echo "📄 Creando zap-config.conf a mano (formato TSV)..."
cat <<EOF > "$CONFIG_FILE"
10017	WARN	IGNORE
10096	WARN	IGNORE
10021	WARN	IGNORE
10027	WARN	IGNORE
10103	WARN	IGNORE
10109	WARN	IGNORE
EOF

# ▶ Escaneo por cada URL en sitios.json
for URL in $(jq -r '.sitios[]' "$SITIOS_FILE"); do
  echo "🚀🚀🚀🚀🚀Escaneando: $URL"
  TIMESTAMP=$(date +%Y%m%d_%H%M)
  HOST=$(echo "$URL" | sed 's|https\?://||; s|/||g' | tr '@' '_' | tr ':' '_' )
  REPORT_HTML="$REPORT_DIR/zap-report-${HOST}-$TIMESTAMP.html"

  if python3 "$FULL_SCAN_SCRIPT" -t "$URL" -r "$REPORT_HTML" -c "$CONFIG_FILE"; then
    echo "✅ Reporte generado: $REPORT_HTML"
  else
    echo "❌ Falló el escaneo de $URL"
  fi
  echo "-------------------------------"
done

