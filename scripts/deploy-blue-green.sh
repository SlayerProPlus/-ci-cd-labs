#!/usr/bin/env bash
set -euo pipefail

APP_NAME="python-calculator-app"
APP_DIR="/home/osboxes/opt/python-app"

BLUE_PORT=8080
GREEN_PORT=8081

NEW_ZIP_PATH="${1:-}"

if [[ -z "$NEW_ZIP_PATH" ]]; then
  echo "Uso: ./deploy-blue-green.sh <ruta-al-archivo-zip>"
  exit 1
fi

mkdir -p "$APP_DIR"
cd "$APP_DIR"

echo "======================================"
echo "🚀 Despliegue Blue-Green (Python/Flask)"
echo "======================================"
echo "➡️  Nuevo paquete: $NEW_ZIP_PATH"

# 1. Detectar entorno activo
if [[ -f "active-environment" ]]; then
    ACTIVE=$(cat active-environment)
else
    ACTIVE="blue"
fi

echo "🔵 Entorno activo actual: $ACTIVE"

# 2. Determinar entorno destino
if [[ "$ACTIVE" == "blue" ]]; then
    TARGET="green"
    TARGET_PORT="$GREEN_PORT"
else
    TARGET="blue"
    TARGET_PORT="$BLUE_PORT"
fi

echo "🟢 Entorno destino a desplegar: $TARGET (Puerto $TARGET_PORT)"

# 3. Detener instancia anterior del entorno destino
echo "🛑 Deteniendo instancia anterior de $TARGET..."
PID=$(pgrep -f "FLASK_RUN_PORT=$TARGET_PORT" || true)

if [[ -n "$PID" ]]; then
    kill "$PID" || true
    sleep 2
    if kill -0 "$PID" 2>/dev/null; then
        kill -9 "$PID"
    fi
    echo "✅ Instancia anterior detenida."
else
    echo "ℹ️ No había ninguna instancia previa corriendo en $TARGET_PORT."
fi

# 4. Desplegar nuevo código
echo "📦 Instalando nuevo paquete..."
mkdir -p "$APP_DIR/$TARGET"
mkdir -p "$APP_DIR/versions"
mkdir -p "$APP_DIR/logs"

# Backup
TIMESTAMP=$(date +%Y%m%d%H%M%S)
cp "$NEW_ZIP_PATH" "$APP_DIR/versions/${APP_NAME}-${TARGET}-${TIMESTAMP}.zip"

# Extraer en la carpeta destino
unzip -o "$NEW_ZIP_PATH" -d "$APP_DIR/$TARGET"

# 5. Iniciar entorno virtual y ejecutar la app en background
cd "$APP_DIR/$TARGET"

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install -r requirements.txt > /dev/null 2>&1

echo "▶️ Iniciando instancia $TARGET en puerto $TARGET_PORT..."
export INSTANCE_NAME="$(echo "$TARGET" | tr '[:lower:]' '[:upper:]')"
export FLASK_RUN_PORT="$TARGET_PORT"

nohup flask --app app/api.py run --host=0.0.0.0 --port="$TARGET_PORT" > "$APP_DIR/logs/app-${TARGET}.log" 2>&1 &
TARGET_PID=$!
echo "PID: $TARGET_PID"

# 6. Health Check
echo "🔍 Verificando salud de la nueva instancia en puerto $TARGET_PORT..."
HEALTHY=false

for i in {1..20}; do
    if curl -sf "http://localhost:${TARGET_PORT}/health" > /dev/null; then
        echo "✅ La instancia $TARGET está saludable."
        HEALTHY=true
        break
    fi
    sleep 2
done

# 7. Si falla el Health Check -> Rollback
if [[ "$HEALTHY" != "true" ]]; then
    echo "❌ Error: La instancia $TARGET no superó el health check."
    echo "🛑 Cancelando despliegue y apagando proceso defectuoso..."
    kill "$TARGET_PID" 2>/dev/null || true
    exit 1
fi

# 8. Marcar nuevo entorno activo
echo "$TARGET" > "$APP_DIR/active-environment"

echo "======================================"
echo "✅ Despliegue Blue-Green completado con éxito"
echo "======================================"
echo "Ambiente activo actual: $TARGET"
echo "Puerto activo: $TARGET_PORT"