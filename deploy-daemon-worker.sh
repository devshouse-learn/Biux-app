#!/bin/bash

# 🚀 BIUX Deploy Worker - Sin FastLane (xcodebuild directo)
# Compila y sube a TestFlight de forma simple y robusta

BIUX_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
LAST_COMMIT_FILE="$BIUX_PATH/.last-deployed-commit"
IOS_PATH="$BIUX_PATH/ios"

# Setup locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

log_message() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $1" >> "$DAEMON_LOG"
}

cd "$BIUX_PATH" || exit 1

# Obtener último commit
current_commit=$(git rev-parse HEAD 2>/dev/null)
if [ -z "$current_commit" ]; then
  exit 0
fi

# Obtener último commit desplegado
last_deployed=""
if [ -f "$LAST_COMMIT_FILE" ]; then
  last_deployed=$(cat "$LAST_COMMIT_FILE")
fi

# Si son diferentes, desplegar
if [ "$current_commit" != "$last_deployed" ]; then
  log_message "📦 Nuevo commit: ${current_commit:0:8}"
  
  commit_msg=$(git log -1 --pretty=%B 2>/dev/null | head -1)
  
  if [[ "$commit_msg" =~ \[testflight\]|\[deploy\] ]]; then
    log_message "🚀 Desplegando: $commit_msg"
    
    cd "$IOS_PATH" || exit 1
    
    # Obtener y incrementar build number
    current_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
    log_message "🔢 Build actual: $current_build"
    
    agvtool next-version -all > /dev/null 2>&1
    
    new_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
    log_message "✅ Build incrementado a: $new_build"
    
    # Limpiar builds viejos con problemas de permisos
    log_message "🧹 Limpiando builds previos..."
    rm -rf "build/" 2>/dev/null || true
    rm -rf "$HOME/Library/Developer/Xcode/DerivedData/Runner-"* 2>/dev/null || true
    
    # Compilar para iOS
    log_message "🔨 Compilando para iOS (esto puede tomar 5-15 minutos)..."
    
    xcodebuild_output=$(mktemp)
    
    xcodebuild \
      -workspace Runner.xcworkspace \
      -scheme Runner \
      -configuration Release \
      -derivedDataPath build/ \
      -destination "generic/platform=iOS" \
      -archivePath "build/Runner.xcarchive" \
      archive > "$xcodebuild_output" 2>&1
    
    BUILD_EXIT=$?
    
    # Procesar output
    if grep -q "ARCHIVE SUCCEEDED" "$xcodebuild_output" 2>/dev/null; then
      log_message "✅ Archivo creado exitosamente"
      
      # Crear ExportOptions.plist si no existe
      cat > ExportOptions.plist << 'EOF'
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
EOF
      
      log_message "📦 Exportando IPA..."
      
      xcodebuild \
        -exportArchive \
        -archivePath "build/Runner.xcarchive" \
        -exportOptionsPlist "ExportOptions.plist" \
        -exportPath "build/ipa" > "$xcodebuild_output" 2>&1
      
      EXPORT_EXIT=$?
      
      if [ -f "build/ipa/Runner.ipa" ]; then
        log_message "✅ IPA exportado correctamente"
        log_message "📍 Ubicación: build/ipa/Runner.ipa"
        log_message "ℹ️ Usa Xcode Organizer o TestFlight web para subir manualmente"
        log_message "✅ ¡Compilación completada exitosamente!"
        
        echo "$current_commit" > "$LAST_COMMIT_FILE"
        rm -f "$xcodebuild_output"
      else
        log_message "❌ Error: IPA no se generó"
        cat "$xcodebuild_output" >> "$DAEMON_LOG"
        rm -f "$xcodebuild_output"
      fi
    else
      log_message "❌ Error compilando"
      tail -20 "$xcodebuild_output" >> "$DAEMON_LOG"
      rm -f "$xcodebuild_output"
    fi
  fi
fi
