#!/bin/bash

# BIUX Deploy - Compile & Upload a TestFlight
# Sistema automatico para macOS local

set -e

BIUX_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_PATH="$BIUX_PATH/ios"
BUILD_LOG="/tmp/biux-build.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Setup
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="/Users/macmini/dev/flutter/bin:$PATH"

# Asegurar que CocoaPods esta disponible
if [ -x "/opt/homebrew/bin/pod" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

log() { echo -e "${BLUE}INFO${NC} $1"; }
success() { echo -e "${GREEN}OK${NC} $1"; }
error() { echo -e "${RED}ERROR${NC} $1" >&2; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }

compile_app() {
  log "Compilando para iOS (5-15 minutos)..."
  
  cd "$BIUX_PATH" || exit 1
  
  log "Limpiando builds anteriores..."
  rm -rf build/ 2>/dev/null || true
  rm -rf ios/build/ 2>/dev/null || true
  pkill -9 -f "xcodebuild" 2>/dev/null || true
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData/Runner-"* 2>/dev/null || true
  
  log "Ejecutando flutter build ios..."
  if ! flutter build ios --release 2>&1 | tee "$BUILD_LOG"; then
    error "Error en flutter build ios"
    tail -20 "$BUILD_LOG"
    exit 1
  fi
  
  if ! grep -q "Built an image" "$BUILD_LOG" 2>/dev/null; then
    error "Compilacion fallida"
    tail -20 "$BUILD_LOG"
    exit 1
  fi
  
  log "Archivando con xcodebuild..."
  cd "$IOS_PATH" || exit 1
  
  if ! xcodebuild \
    -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -derivedDataPath build/deriveddata \
    -archivePath "build/Runner.xcarchive" \
    -allowProvisioningUpdates \
    -skipPackagePluginValidation \
    clean archive >> "$BUILD_LOG" 2>&1; then
    
    error "Error archivando"
    tail -30 "$BUILD_LOG"
    exit 1
  fi
  
  if ! grep -q "ARCHIVE SUCCEEDED" "$BUILD_LOG" 2>/dev/null; then
    error "Archivado fallido"
    tail -30 "$BUILD_LOG"
    exit 1
  fi
  
  # Solo incrementar build number si TODO fue exitoso
  current_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
  agvtool next-version -all > /dev/null 2>&1
  new_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
  log "Build incrementado: $current_build -> $new_build"
  
  success "Compilacion y archivado completados"
}

export_ipa() {
  log "Exportando IPA..."
  
  cd "$IOS_PATH" || exit 1
  
  cat > ExportOptions.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>552JRWRZ88</string>
</dict>
</plist>
PLIST
  
  if ! xcodebuild \
    -exportArchive \
    -archivePath "build/Runner.xcarchive" \
    -exportOptionsPlist "ExportOptions.plist" \
    -exportPath "build/ipa" > "$BUILD_LOG" 2>&1; then
    
    error "Error exportando IPA"
    tail -10 "$BUILD_LOG"
    exit 1
  fi
  
  if [ ! -f "build/ipa/Runner.ipa" ]; then
    error "IPA no generado"
    exit 1
  fi
  
  success "IPA exportado: build/ipa/Runner.ipa"
}

upload_testflight() {
  log "Subiendo a TestFlight..."
  
  cd "$IOS_PATH" || exit 1
  
  IPA_PATH="$(pwd)/build/ipa/Runner.ipa"
  
  if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ]; then
    warn "Variables no configuradas: APPLE_ID, APPLE_PASSWORD"
    log "IPA disponible en: $IPA_PATH"
    log "Para automatizar, configura:"
    log "   export APPLE_ID='tu@email.com'"
    log "   export APPLE_PASSWORD='tu-app-password'"
    return 0
  fi
  
  if ! transporter \
    --upload-package "$IPA_PATH" \
    --username "$APPLE_ID" \
    --password "$APPLE_PASSWORD" \
    --output-format json > /dev/null 2>&1; then
    
    warn "Error con Transporter"
    log "IPA disponible en: $IPA_PATH"
    return 0
  fi
  
  success "Subida a TestFlight completada"
  log "La version estara disponible en ~30 minutos"
}

case "${1:-full}" in
  compile)
    compile_app
    ;;
  export)
    export_ipa
    ;;
  upload)
    upload_testflight
    ;;
  full)
    compile_app
    export_ipa
    upload_testflight
    success "Proceso completado!"
    ;;
  *)
    echo "Uso: $0 {compile|export|upload|full}"
    echo ""
    echo "Comandos:"
    echo "  compile  - Solo compilar"
    echo "  export   - Solo exportar IPA"
    echo "  upload   - Solo subir a TestFlight"
    echo "  full     - Hacer todo (default)"
    ;;
esac

rm -f "$BUILD_LOG"
