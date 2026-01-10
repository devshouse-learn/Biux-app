#!/bin/bash

# 🚀 Activar Deploy Inmediato
# Carga credenciales y compila + sube a TestFlight

BIUX_PATH="/Users/macmini/biux"

# Cargar credenciales desde variables de entorno del sistema
# NUNCA incluir credenciales directamente en este archivo
if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ] || [ -z "$TEAM_ID" ]; then
  echo "❌ ERROR: Credenciales no configuradas"
  echo ""
  echo "Configura las variables de entorno antes de ejecutar:"
  echo "  export APPLE_ID='tu-email@icloud.com'"
  echo "  export APPLE_PASSWORD='tu-app-specific-password'"
  echo "  export TEAM_ID='552JRWRZ88'"
  echo ""
  echo "O agrégalas a ~/.zprofile para uso permanente"
  exit 1
fi

echo "🚀 Iniciando Deploy..."
echo "📝 Contraseña: local deploy"
echo ""

# Ejecutar deploy completo
bash "$BIUX_PATH/deploy.sh" full

echo ""
echo "✅ Deploy completado"
