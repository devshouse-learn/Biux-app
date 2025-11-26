#!/bin/bash

# ================================================
# 🚀 SETUP AUTOMATIZADO FASTLANE - SIN PREGUNTAS
# Configura todo en un paso
# ================================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
iOS_DIR="$SCRIPT_DIR/ios"
FASTLANE_DIR="$iOS_DIR/fastlane"
ENV_LOCAL="$FASTLANE_DIR/.env.local"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}➜${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# ==================================================
# 1. VERIFICAR REQUISITOS
# ==================================================

print_status "Verificando requisitos..."

# Verificar Xcode
if ! xcode-select -p &>/dev/null; then
    print_error "Xcode no instalado. Ejecuta: xcode-select --install"
fi
print_success "Xcode disponible"

# Verificar Fastlane
if [ ! -f "/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane" ]; then
    print_error "Fastlane no instalado. Ejecuta: sudo gem install fastlane"
fi
print_success "Fastlane disponible"

# ==================================================
# 2. CREAR CONFIGURACIÓN AUTOMÁTICA
# ==================================================

print_status "Creando configuración..."

# Obtener Team ID de Xcode
cd "$iOS_DIR"
TEAM_ID=$(grep -m1 'DEVELOPMENT_TEAM' Runner.xcodeproj/project.pbxproj | sed 's/.*= //;s/;.*//' | tr -d ' ')

if [ -z "$TEAM_ID" ]; then
    print_error "No se encontró Team ID en Xcode. Asegúrate de tener configurado en: Runner → Build Settings → Development Team"
fi

print_success "Team ID encontrado: $TEAM_ID"

# ==================================================
# 3. CREAR .env.local
# ==================================================

print_status "Creando .env.local..."

cat > "$ENV_LOCAL" << EOF
# ============================================
# AUTOGENERADO - Fastlane Configuration
# Usando Xcode Keychain (Automático)
# ============================================

# Team Configuration (obtenido automáticamente)
TEAM_ID=$TEAM_ID
APP_IDENTIFIER=org.devshouse.biux
APP_NAME=BIUX
TEAM_NAME=Devshouse

# Build Configuration
CONFIGURATION=Release
SCHEME=Runner
WORKSPACE=Runner.xcworkspace
XCODEPROJ=Runner.xcodeproj

# TestFlight Configuration
TESTFLIGHT_BETA_FEEDBACK_EMAIL=soporte@devshouse.com
TESTFLIGHT_GROUPS=Internal Testers

# Logging
FASTLANE_HIDE_CHANGELOG=true
FASTLANE_SKIP_UPDATE_CHECK=true

# Notas:
# - Autenticación: Xcode Keychain (automática)
# - No requiere contraseñas en este archivo
# - Xcode debe estar logueado con tu Apple ID
EOF

print_success ".env.local creado"

# ==================================================
# 4. VERIFICAR FASTFILE
# ==================================================

print_status "Verificando Fastfile..."

if [ ! -f "$FASTLANE_DIR/Fastfile" ]; then
    print_error "Fastfile no encontrado en $FASTLANE_DIR"
fi

print_success "Fastfile disponible"

# ==================================================
# 5. VERIFICAR PERMISOS
# ==================================================

print_status "Configurando permisos..."

chmod 755 "$FASTLANE_DIR"
chmod 644 "$ENV_LOCAL"

print_success "Permisos configurados"

# ==================================================
# 6. PROBAR CONFIGURACIÓN
# ==================================================

print_status "Probando configuración..."

cd "$iOS_DIR"

# Exportar variables
export $(cat "$ENV_LOCAL" | grep -v '^#' | grep -v '^$' | xargs)

# Probar fastlane
TEST_OUTPUT=$(/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane version_info 2>&1)

if echo "$TEST_OUTPUT" | grep -q "Version:"; then
    print_success "Fastlane funcionando correctamente"
    echo "$TEST_OUTPUT"
else
    print_error "Error probando fastlane. Verifica Xcode está logueado"
fi

# ==================================================
# 7. CREAR ARCHIVO DE ALIAS
# ==================================================

print_status "Creando alias..."

cat > "$SCRIPT_DIR/.alias-deploy" << 'EOF'
# Alias para deploy (agregar a ~/.zshrc si deseas)
alias deploy="$SCRIPT_DIR/deploy.sh"
alias deploy-tf="$SCRIPT_DIR/deploy.sh testflight"
alias deploy-status="$SCRIPT_DIR/deploy.sh status"
EOF

print_success "Aliases creados (opcional)"

# ==================================================
# 8. RESUMEN FINAL
# ==================================================

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}✨ CONFIGURACIÓN COMPLETADA${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

print_success "Sistema listo para usar"
echo ""
echo "📋 Resumen:"
echo "  ✅ Team ID: $TEAM_ID"
echo "  ✅ Config: $ENV_LOCAL"
echo "  ✅ Fastfile: $FASTLANE_DIR/Fastfile"
echo "  ✅ Autenticación: Xcode Keychain (automática)"
echo ""

echo "🚀 Próximos comandos:"
echo "  cd $SCRIPT_DIR"
echo "  ./deploy.sh version      # Ver versión actual"
echo "  ./deploy.sh build        # Compilar"
echo "  ./deploy.sh testflight   # Enviar a TestFlight"
echo ""

cd "$SCRIPT_DIR"

print_success "¡Listo!"
