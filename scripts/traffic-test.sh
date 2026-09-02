#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${1:-http://localhost/api/instance}"
REQUESTS="${2:-10}"

echo "🚦 Probando balanceo de tráfico hacia: $TARGET_URL ($REQUESTS peticiones)"
echo "------------------------------------------------------------------"

for i in $(seq 1 "$REQUESTS"); do
  echo -n "Petición #$i: "
  curl -s "$TARGET_URL" || echo "Error de conexión"
  echo ""
  sleep 0.5
done

echo "------------------------------------------------------------------"
echo "✅ Prueba de tráfico finalizada."