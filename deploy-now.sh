#!/bin/bash

# 🚀 Activar Deploy Inmediato
# Carga credenciales y compila + sube a TestFlight

BIUX_PATH="/Users/macmini/biux"

# Cargar credenciales
export APPLE_ID="tu-email@icloud.com"
export APPLE_PASSWORD="oecd-jqgg-kpxv-bqmb"
export TEAM_ID="552JRWRZ88"

echo "🚀 Iniciando Deploy..."
echo "📝 Contraseña: local deploy"
echo ""

# Ejecutar deploy completo
bash "$BIUX_PATH/deploy.sh" full

echo ""
echo "✅ Deploy completado"
