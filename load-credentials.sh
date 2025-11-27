#!/bin/bash

# 🔑 Script para cargar credenciales BIUX Deploy

BIUX_PATH="/Users/macmini/biux"
ENV_FILE="$BIUX_PATH/.env.deploy"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Archivo .env.deploy no encontrado"
  echo "Crea uno con: cp .env.deploy.example .env.deploy"
  exit 1
fi

# Cargar variables
source "$ENV_FILE"

echo "✅ Credenciales cargadas"
echo "   APPLE_ID: $APPLE_ID"
echo "   TEAM_ID: $TEAM_ID"
echo ""
echo "Ahora puedes ejecutar:"
echo "   bash $BIUX_PATH/deploy.sh full"
