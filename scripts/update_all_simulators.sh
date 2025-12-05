#!/bin/bash
# Script para actualizar todos los simuladores con los cambios más recientes
# Fecha: 4 de diciembre de 2025

echo "🚀 Actualizando TODOS los simuladores de Biux"
echo "=============================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directorio del proyecto
PROJECT_DIR="/Users/macmini/biux"
cd "$PROJECT_DIR"

echo ""
echo "${BLUE}📱 FASE 1: Simuladores iOS${NC}"
echo "----------------------------"

# Lista de simuladores iOS
IOS_SIMULATORS=(
    "8A60CA7F-41E8-484E-9E52-F0F06788A4B7:iPhone 16 Pro"
    "D0BCD630-71C9-4042-943A-E9FD1A8572DD:iPhone 16 Pro Max"
    "B3906FB5-2AA6-488B-B16A-48212193E79C:iPhone 16e"
    "1EDBA709-B5B4-4248-85EB-A967E6ADBDFC:iPhone 16"
    "F912C1B0-6784-4626-AB89-F7356840B58F:iPhone 16 Plus"
    "443E8752-207C-43B8-B8CC-AA89F927EA52:iPad Pro 11-inch (M4)"
    "BEAB732C-85B2-424F-A9C3-2990DF899998:iPad Pro 13-inch (M4)"
)

# Paso 1: Construir para iOS
echo "${BLUE}🔨 Construyendo para simuladores iOS...${NC}"
flutter build ios --simulator --debug

if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Build de iOS exitoso${NC}"
    
    # Paso 2: Instalar en cada simulador
    echo ""
    echo "${BLUE}📲 Instalando en simuladores iOS...${NC}"
    
    for sim in "${IOS_SIMULATORS[@]}"; do
        IFS=':' read -r UDID NAME <<< "$sim"
        echo ""
        echo "  → ${NAME}..."
        
        # Encender simulador si está apagado
        xcrun simctl boot "$UDID" 2>/dev/null
        
        # Instalar app
        xcrun simctl install "$UDID" build/ios/iphonesimulator/Runner.app
        
        if [ $? -eq 0 ]; then
            echo "    ${GREEN}✅ Instalado en ${NAME}${NC}"
        else
            echo "    ${RED}❌ Error en ${NAME}${NC}"
        fi
    done
else
    echo "${RED}❌ Error en build de iOS${NC}"
fi

echo ""
echo "${BLUE}🤖 FASE 2: Emulador Android${NC}"
echo "----------------------------"

# Construir para Android
echo "${BLUE}🔨 Construyendo para Android...${NC}"
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Build de Android exitoso${NC}"
    
    # Verificar si hay emulador corriendo
    ANDROID_DEVICE=$(flutter devices | grep "emulator" | head -1 | awk '{print $5}' | tr -d '•')
    
    if [ -n "$ANDROID_DEVICE" ]; then
        echo ""
        echo "${BLUE}📲 Instalando en Android...${NC}"
        flutter install -d "$ANDROID_DEVICE"
        
        if [ $? -eq 0 ]; then
            echo "${GREEN}✅ Instalado en Android${NC}"
        else
            echo "${RED}❌ Error en Android${NC}"
        fi
    else
        echo "${RED}⚠️  No hay emulador Android corriendo${NC}"
        echo "   Ejecuta: \$ANDROID_HOME/emulator/emulator -avd Medium_Phone_API_36.0"
    fi
else
    echo "${RED}❌ Error en build de Android${NC}"
fi

echo ""
echo "${BLUE}💻 FASE 3: macOS${NC}"
echo "----------------------------"

# Construir para macOS
echo "${BLUE}🔨 Construyendo para macOS...${NC}"
flutter build macos --debug

if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Build de macOS exitoso${NC}"
    echo "${GREEN}   App ubicada en: build/macos/Build/Products/Debug/biux.app${NC}"
    
    # Ejecutar app de macOS
    echo ""
    echo "${BLUE}🚀 Ejecutando app de macOS...${NC}"
    open build/macos/Build/Products/Debug/biux.app
    
    if [ $? -eq 0 ]; then
        echo "${GREEN}✅ App de macOS ejecutada${NC}"
    fi
else
    echo "${RED}❌ Error en build de macOS${NC}"
fi

echo ""
echo "=============================================="
echo "${GREEN}✅ PROCESO COMPLETADO${NC}"
echo ""
echo "📊 Resumen de cambios instalados:"
echo "  ✅ Sistema de tienda completo"
echo "  ✅ Subida de medios (fotos/videos)"
echo "  ✅ Funcionalidad 'Comprar ahora'"
echo "  ✅ Control de acceso por roles"
echo "  ✅ Búsqueda de productos"
echo "  ✅ Videos con reproducción (max 30s)"
echo ""
echo "🔍 Para verificar:"
echo "  1. Abre cualquier simulador"
echo "  2. Busca la app 'biux'"
echo "  3. Ve a la pestaña 'Tienda'"
echo "  4. Verifica las nuevas funcionalidades"
echo ""
