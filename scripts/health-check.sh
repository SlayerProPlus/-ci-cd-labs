#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"
HOST="${2:-localhost}"

echo "🔍 Ejecutando Health Check en http://${HOST}:${PORT}/health ..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://${HOST}:${PORT}/health" || echo "000")

if [ "$HTTP_CODE" -eq 200 ]; then
  echo "✅ Servicio saludable (HTTP 200) en el puerto ${PORT}"
  curl -s "http://${HOST}:${PORT}/health"
  echo ""
  exit 0
else
  echo "❌ Error: El servicio respondió con código HTTP ${HTTP_CODE}"
  exit 1
fi