#!/bin/bash

# ================================================
# 🔐 SETUP API TOKENS - FASTLANE BIUX
# Asistente interactivo para configurar tokens
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

print_header() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}🔐 $1${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ==================================================
# 1. MENÚ PRINCIPAL
# ==================================================

print_header "CONFIGURACIÓN DE AUTENTICACIÓN"

echo "Elige método de autenticación:"
echo ""
echo "1️⃣  API Token (RECOMENDADO) - Más seguro"
echo "2️⃣  App-Specific Password - Más rápido"
echo "3️⃣  Xcode/Keychain (AUTOMÁTICO) - Sin configuración"
echo ""
read -p "Opción (1/2/3): " choice

# ==================================================
# 2. CONFIGURACIÓN POR MÉTODO
# ==================================================

case $choice in
    1)
        # API Token
        print_header "CONFIGURACIÓN API TOKEN"
        
        echo "📋 Pasos:"
        echo "1. Ve a: https://appstoreconnect.apple.com/access/api"
        echo "2. Haz clic en 'Generate API Key'"
        echo "3. Selecciona 'App Manager' como rol"
        echo "4. Descarga el archivo AuthKey_XXXXXXXXXX.p8"
        echo ""
        
        # Verificar archivo AuthKey
        print_warning "Buscar archivo AuthKey en Descargas..."
        AUTH_KEY_FILE=$(find ~/Downloads -name "AuthKey_*.p8" -type f 2>/dev/null | head -1)
        
        if [ -z "$AUTH_KEY_FILE" ]; then
            print_error "No se encontró AuthKey.p8 en Descargas"
            echo ""
            echo "📝 Pasos para obtenerlo:"
            echo "1. Abre: https://appstoreconnect.apple.com/access/api"
            echo "2. Haz clic en 'Generate API Key'"
            echo "3. Descarga y guarda el archivo"
            exit 1
        fi
        
        print_success "Archivo encontrado: $(basename $AUTH_KEY_FILE)"
        
        # Copiar archivo
        cp "$AUTH_KEY_FILE" "$FASTLANE_DIR/AuthKey.p8"
        chmod 600 "$FASTLANE_DIR/AuthKey.p8"
        print_success "AuthKey.p8 copiado y asegurado"
        
        echo ""
        echo "📝 Ahora ingresa los IDs:"
        read -p "Key ID (ej: ABC123DEF45): " key_id
        read -p "Issuer ID (ej: 12345678-1234-1234-1234-123456789012): " issuer_id
        read -p "Team ID (ej: XXXXXXXXXX): " team_id
        
        # Crear .env.local
        cat > "$ENV_LOCAL" << EOF
# API Token Configuration
APP_STORE_CONNECT_KEY_ID=$key_id
APP_STORE_CONNECT_ISSUER_ID=$issuer_id

# Team Configuration
TEAM_ID=$team_id
APP_IDENTIFIER=org.devshouse.biux
EOF
        
        print_success "Configuración guardada en $ENV_LOCAL"
        ;;
        
    2)
        # App-Specific Password
        print_header "CONFIGURACIÓN APP-SPECIFIC PASSWORD"
        
        echo "📋 Pasos:"
        echo "1. Ve a: https://appleid.apple.com/account/manage"
        echo "2. Seguridad → Contraseña de app"
        echo "3. Selecciona 'fastlane' como nombre"
        echo "4. Copia la contraseña generada"
        echo ""
        
        read -p "Correo Apple ID: " apple_email
        read -sp "Contraseña de app (no se mostrará): " app_password
        echo ""
        read -p "Team ID: " team_id
        
        # Crear .env.local
        cat > "$ENV_LOCAL" << EOF
# App-Specific Password Configuration
FASTLANE_USER=$apple_email
FASTLANE_PASSWORD=$app_password

# Team Configuration
TEAM_ID=$team_id
APP_IDENTIFIER=org.devshouse.biux
EOF
        
        print_success "Configuración guardada en $ENV_LOCAL"
        ;;
        
    3)
        # Xcode/Keychain
        print_header "CONFIGURACIÓN XCODE/KEYCHAIN"
        
        echo "🔍 Verificando configuración de Xcode..."
        
        # Verificar que Xcode está configurado
        if xcode-select -p &>/dev/null; then
            print_success "Xcode encontrado"
        else
            print_error "Xcode no está configurado"
            echo "Ejecuta: xcode-select --install"
            exit 1
        fi
        
        # Crear .env.local minimal
        read -p "Team ID: " team_id
        
        cat > "$ENV_LOCAL" << EOF
# Xcode/Keychain Configuration (Automático)
# Fastlane detectará automáticamente credenciales de Xcode

TEAM_ID=$team_id
APP_IDENTIFIER=org.devshouse.biux
EOF
        
        print_success "Configuración para Xcode/Keychain lista"
        print_warning "Asegúrate de tener Xcode configurado con tu Apple ID"
        ;;
        
    *)
        print_error "Opción no válida"
        exit 1
        ;;
esac

# ==================================================
# 3. VERIFICACIÓN FINAL
# ==================================================

print_header "VERIFICACIÓN"

# Verificar .env.local
if [ -f "$ENV_LOCAL" ]; then
    print_success ".env.local creado"
    echo ""
    echo "Contenido:"
    head -n 10 "$ENV_LOCAL"
else
    print_error ".env.local no se creó"
    exit 1
fi

# Verificar AuthKey.p8 si se usa API Token
if grep -q "APP_STORE_CONNECT_KEY_ID" "$ENV_LOCAL" 2>/dev/null; then
    if [ -f "$FASTLANE_DIR/AuthKey.p8" ]; then
        print_success "AuthKey.p8 disponible"
    else
        print_error "AuthKey.p8 no encontrado"
    fi
fi

# ==================================================
# 4. PROBAR CONFIGURACIÓN
# ==================================================

print_header "PROBANDO CONFIGURACIÓN"

cd "$iOS_DIR"

# Cargar variables de entorno
export $(cat "$ENV_LOCAL" | grep -v '^#' | xargs)

echo "Ejecutando fastlane version_info..."
if /opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane version_info 2>&1 | grep -q "Version:"; then
    print_success "¡Configuración funcionando!"
else
    print_warning "Verifica manualmente: cd ios && fastlane version_info"
fi

# ==================================================
# 5. RESUMEN
# ==================================================

print_header "¡CONFIGURACIÓN COMPLETADA!"

echo "📝 Resumen:"
echo "  ✅ Autenticación configurada"
echo "  ✅ Variables de entorno guardadas"
echo "  ✅ Fastlane listo para usar"
echo ""

echo "📚 Próximos pasos:"
echo "  1. Revisar: cat $ENV_LOCAL"
echo "  2. Probar: ./deploy.sh version"
echo "  3. Desplegar: ./deploy.sh testflight"
echo ""

print_success "¡Listo para desplegar!"

cd "$SCRIPT_DIR"
