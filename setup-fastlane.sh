#!/bin/bash

# ================================================
# 🔧 SETUP INICIAL - FASTLANE BIUX
# Ejecutar una sola vez para configurar todo
# ================================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
iOS_DIR="$SCRIPT_DIR/ios"
FASTLANE_DIR="$iOS_DIR/fastlane"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}🔧 $1${NC}"
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

# ==================================================
# 1. VERIFICAR REQUISITOS
# ==================================================

print_header "VERIFICANDO REQUISITOS"

# Verificar Xcode
if ! xcode-select -p &>/dev/null; then
    print_error "Xcode no está instalado"
    echo "Instálalo desde App Store o:"
    echo "xcode-select --install"
    exit 1
fi
print_success "Xcode instalado"

# Verificar CocoaPods
if ! command -v pod &> /dev/null; then
    print_warning "CocoaPods no instalado, instalando..."
    sudo gem install cocoapods
fi
print_success "CocoaPods disponible"

# Verificar Ruby
if ! command -v ruby &> /dev/null; then
    print_error "Ruby no instalado"
    exit 1
fi
RUBY_VERSION=$(ruby --version)
print_success "Ruby: $RUBY_VERSION"

# Verificar Fastlane
if [ ! -f "/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane" ]; then
    print_warning "Fastlane no instalado, instalando..."
    sudo gem install fastlane -NV
fi
print_success "Fastlane instalado"

# ==================================================
# 2. CONFIGURAR DIRECTORIO iOS
# ==================================================

print_header "CONFIGURANDO DIRECTORIO iOS"

# CocoaPods
cd "$iOS_DIR"
print_warning "Ejecutando 'pod install'..."
if [ ! -d "Pods" ]; then
    pod install --repo-update
else
    pod repo update
    pod install
fi
print_success "CocoaPods configurado"

cd "$SCRIPT_DIR"

# ==================================================
# 3. CREAR ARCHIVOS DE CONFIGURACIÓN
# ==================================================

print_header "CREAR CONFIGURACIÓN"

# .env
if [ ! -f "$FASTLANE_DIR/.env" ]; then
    print_warning "Creando .env..."
    cat > "$FASTLANE_DIR/.env" << 'EOF'
fastlane_version "2.229.1"
default_platform(:ios)
opt_out_usage
ENV["FASTLANE_SKIP_UPDATE_CHECK"] = "true"
ENV["FASTLANE_HIDE_CHANGELOG"] = "true"
EOF
    print_success ".env creado"
else
    print_success ".env ya existe"
fi

# Copiar .env.example si no existe .env personalizado
if [ ! -f "$FASTLANE_DIR/.env.local" ]; then
    print_warning "Creando plantilla .env.local..."
    cp "$FASTLANE_DIR/.env.example" "$FASTLANE_DIR/.env.local"
    print_warning "Edita $FASTLANE_DIR/.env.local con tus datos"
fi

# ==================================================
# 4. CONFIGURAR GIT HOOKS
# ==================================================

print_header "CONFIGURANDO GIT HOOKS"

GIT_HOOKS_DIR="$SCRIPT_DIR/.git/hooks"

if [ -d "$GIT_HOOKS_DIR" ]; then
    if [ ! -f "$GIT_HOOKS_DIR/post-commit" ]; then
        print_warning "Creando post-commit hook..."
        cp "$SCRIPT_DIR/.git/hooks/post-commit" "$GIT_HOOKS_DIR/post-commit"
        chmod +x "$GIT_HOOKS_DIR/post-commit"
        print_success "post-commit hook creado"
    else
        print_success "post-commit hook ya existe"
    fi
else
    print_warning "Directorio .git/hooks no encontrado"
fi

# ==================================================
# 5. HACER SCRIPT EJECUTABLE
# ==================================================

print_header "FINALIZANDO"

chmod +x "$SCRIPT_DIR/deploy.sh"
print_success "deploy.sh es ejecutable"

# ==================================================
# 6. VERIFICACIÓN FINAL
# ==================================================

print_header "VERIFICACIÓN FINAL"

echo "Verificando estructura..."
[ -d "$FASTLANE_DIR" ] && print_success "Fastlane configurado" || print_error "Fastlane no configurado"
[ -f "$SCRIPT_DIR/deploy.sh" ] && print_success "Script deploy.sh existe" || print_error "deploy.sh no existe"
[ -f "$FASTLANE_DIR/Fastfile" ] && print_success "Fastfile existe" || print_error "Fastfile no existe"

# ==================================================
# 7. INSTRUCCIONES FINALES
# ==================================================

print_header "PRÓXIMOS PASOS"

echo "1. Edita tu configuración:"
echo "   nano $FASTLANE_DIR/.env.local"
echo ""
echo "2. Asegúrate de que tienes:"
echo "   ✅ Team ID correcto"
echo "   ✅ Certificados actualizados en Xcode"
echo "   ✅ Provisioning profiles configurados"
echo ""
echo "3. Prueba el setup:"
echo "   ./deploy.sh version"
echo ""
echo "4. Enviando a TestFlight:"
echo "   ./deploy.sh testflight"
echo ""

print_success "¡Setup completado!"
print_success "Listo para desplegar"

echo ""
