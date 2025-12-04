#!/bin/bash

# Script para instalar Biux en todos los simuladores iPhone 16
# Actualizado: 4 de diciembre de 2025

echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║   🚴 Instalando Biux en Todos los Simuladores        ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# UUIDs de los simuladores iPhone 16
declare -A SIMULATORS=(
    ["iPhone 16 Pro Max"]="D0BCD630-71C9-4042-943A-E9FD1A8572DD"
    ["iPhone 16 Pro"]="8A60CA7F-41E8-484E-9E52-F0F06788A4B7"
    ["iPhone 16e"]="B3906FB5-2AA6-488B-B16A-48212193E79C"
    ["iPhone 16"]="1EDBA709-B5B4-4248-85EB-A967E6ADBDFC"
    ["iPhone 16 Plus"]="F912C1B0-6784-4626-AB89-F7356840B58F"
)

APP_PATH="build/ios/iphonesimulator/Runner.app"

# Verificar que existe el build
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: No se encontró el build en $APP_PATH"
    echo "   Ejecuta primero: flutter build ios --simulator --debug"
    exit 1
fi

echo "📦 App encontrada: $APP_PATH"
echo ""

# Contador de instalaciones
INSTALLED=0
FAILED=0

# Instalar en cada simulador
for NAME in "${!SIMULATORS[@]}"; do
    UUID="${SIMULATORS[$NAME]}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 Instalando en: $NAME"
    echo "   UUID: $UUID"
    echo ""
    
    # Verificar estado del simulador
    STATUS=$(xcrun simctl list devices | grep "$UUID" | grep -o "(Booted)\|(Shutdown)")
    
    if [[ $STATUS == *"Shutdown"* ]]; then
        echo "   🔵 Iniciando simulador..."
        xcrun simctl boot "$UUID" 2>/dev/null
        sleep 3
    fi
    
    # Desinstalar versión anterior si existe
    echo "   🗑️  Desinstalando versión anterior..."
    xcrun simctl uninstall "$UUID" org.devshouse.biux 2>/dev/null
    
    # Instalar nueva versión
    echo "   📥 Instalando nueva versión con cambios..."
    if xcrun simctl install "$UUID" "$APP_PATH"; then
        echo "   ✅ Instalación exitosa en $NAME"
        ((INSTALLED++))
    else
        echo "   ❌ Error al instalar en $NAME"
        ((FAILED++))
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 RESUMEN DE INSTALACIÓN"
echo "   ✅ Exitosas: $INSTALLED"
echo "   ❌ Fallidas: $FAILED"
echo "   📱 Total: ${#SIMULATORS[@]}"
echo ""

if [ $INSTALLED -eq ${#SIMULATORS[@]} ]; then
    echo "✨ ¡Todos los simuladores actualizados exitosamente!"
    echo ""
    echo "🎯 CAMBIOS APLICADOS:"
    echo "   • Prefijo +57 fijo y visible"
    echo "   • Solo acepta números (0-9)"
    echo "   • Máximo 10 dígitos"
    echo "   • Validación estricta"
    echo "   • Envío automático con +57"
    echo ""
    echo "💡 Para abrir un simulador:"
    echo "   ./launch_biux_simulators.sh promax"
    echo "   ./launch_biux_simulators.sh pro"
    echo "   ./launch_biux_simulators.sh se"
    echo "   ./launch_biux_simulators.sh standard"
    echo "   ./launch_biux_simulators.sh plus"
else
    echo "⚠️  Algunas instalaciones fallaron. Revisa los errores arriba."
fi

echo ""
echo "╚═══════════════════════════════════════════════════════╝"
