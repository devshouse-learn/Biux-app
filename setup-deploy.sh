#!/bin/bash

# 🚀 Setup Final - BIUX Deploy System
# Configura todo automáticamente

BIUX_PATH="/Users/macmini/biux"
ENV_FILE="$BIUX_PATH/.env.deploy"

echo "=========================================="
echo "🚀 BIUX Deploy - Setup Final"
echo "=========================================="
echo ""

# Step 1: Verificar scripts
echo "1️⃣ Verificando scripts..."
for script in deploy.sh deploy-daemon.sh deploy-worker.sh; do
  if [ -f "$BIUX_PATH/$script" ]; then
    if [ -x "$BIUX_PATH/$script" ]; then
      echo "   ✅ $script (ejecutable)"
    else
      chmod +x "$BIUX_PATH/$script"
      echo "   ✅ $script (hecho ejecutable)"
    fi
  else
    echo "   ❌ $script NO EXISTE"
    exit 1
  fi
done

echo ""
echo "2️⃣ Configurando credenciales..."
echo ""
echo "Necesitas configurar:"
echo "   1. APPLE_ID (tu email de Apple)"
echo "   2. APPLE_PASSWORD (app-specific password)"
echo ""
echo "Para generar App Password:"
echo "   → https://appleid.apple.com"
echo "   → Security"
echo "   → App Passwords"
echo "   → Elige 'Other (Custom name)' y escribe 'BIUX Deploy'"
echo ""

read -p "¿Ingresa tu Apple ID (email): " APPLE_ID
read -s -p "¿Ingresa tu App Password (no se mostrará): " APPLE_PASSWORD
echo ""

# Guardar credenciales
cat > "$ENV_FILE" << EOF
# 🔐 Credenciales BIUX Deploy
# Generado: $(date)

export APPLE_ID="$APPLE_ID"
export APPLE_PASSWORD="$APPLE_PASSWORD"
export TEAM_ID="552JRWRZ88"
EOF

chmod 600 "$ENV_FILE"  # Solo lectura para propietario

echo "✅ Credenciales guardadas en: $ENV_FILE"

echo ""
echo "3️⃣ Instalando daemon..."

# Cargar credenciales
source "$ENV_FILE" 2>/dev/null

# Instalar daemon
bash "$BIUX_PATH/deploy-daemon.sh" start 2>&1 | grep -E "Instalando|Daemon|activo|Log" || true

echo ""
echo "=========================================="
echo "✅ Setup Completado"
echo "=========================================="
echo ""
echo "📝 Próximos pasos:"
echo ""
echo "1. Para desplegar:"
echo "   git commit -m 'mensaje [testflight]'"
echo ""
echo "2. El daemon compilará automáticamente en 1-2 minutos"
echo ""
echo "3. Ver logs:"
echo "   bash $BIUX_PATH/deploy-daemon.sh tail"
echo ""
echo "4. Estado del daemon:"
echo "   bash $BIUX_PATH/deploy-daemon.sh status"
echo ""
echo "=========================================="
