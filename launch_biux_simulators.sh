#!/bin/bash

# 🚀 Script para lanzar Biux en diferentes simuladores iOS
# Uso: ./launch_biux_simulators.sh [dispositivo]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║                                           ║"
echo "║        🚴 Biux Simulator Launcher         ║"
echo "║                                           ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Función para obtener ID de dispositivo
get_device_id() {
    case "$1" in
        "promax") echo "D0BCD630-71C9-4042-943A-E9FD1A8572DD" ;;
        "pro") echo "8A60CA7F-41E8-484E-9E52-F0F06788A4B7" ;;
        "se") echo "B3906FB5-2AA6-488B-B16A-48212193E79C" ;;
        "standard") echo "1EDBA709-B5B4-4248-85EB-A967E6ADBDFC" ;;
        "plus") echo "F912C1B0-6784-4626-AB89-F7356840B58F" ;;
        *) echo "" ;;
    esac
}

# Función para obtener nombre de dispositivo
get_device_name() {
    case "$1" in
        "promax") echo "iPhone 16 Pro Max" ;;
        "pro") echo "iPhone 16 Pro" ;;
        "se") echo "iPhone 16e" ;;
        "standard") echo "iPhone 16" ;;
        "plus") echo "iPhone 16 Plus" ;;
        *) echo "" ;;
    esac
}

# Función para mostrar dispositivos disponibles
mostrar_dispositivos() {
    echo -e "${YELLOW}📱 Simuladores iOS disponibles:${NC}\n"
    echo -e "  ${GREEN}promax${NC}   → iPhone 16 Pro Max"
    echo -e "  ${GREEN}pro${NC}      → iPhone 16 Pro"
    echo -e "  ${GREEN}se${NC}       → iPhone 16e"
    echo -e "  ${GREEN}standard${NC} → iPhone 16"
    echo -e "  ${GREEN}plus${NC}     → iPhone 16 Plus"
    echo ""
    echo -e "${YELLOW}🤖 Emulador Android:${NC}"
    echo -e "  ${GREEN}android${NC} → Medium Phone API 36.0"
    echo ""
    echo -e "${YELLOW}🌐 Web:${NC}"
    echo -e "  ${GREEN}chrome${NC} → Google Chrome"
    echo ""
}

# Función para verificar si el simulador está encendido
verificar_simulador() {
    local device_id=$1
    local estado=$(xcrun simctl list devices | grep "$device_id" | grep -o "Booted" || echo "Shutdown")
    echo "$estado"
}

# Función para encender simulador
encender_simulador() {
    local device_id=$1
    local nombre=$2
    
    echo -e "${BLUE}🔌 Encendiendo $nombre...${NC}"
    xcrun simctl boot "$device_id" 2>/dev/null || echo "Simulador ya está encendido"
    open -a Simulator
    sleep 2
    echo -e "${GREEN}✅ $nombre listo${NC}"
}

# Función para lanzar Biux
lanzar_biux() {
    local device_id=$1
    local nombre=$2
    
    echo -e "${BLUE}🚀 Lanzando Biux en $nombre...${NC}\n"
    
    # Verificar si hay builds previos corriendo
    killall -9 xcodebuild 2>/dev/null || true
    sleep 1
    
    # Lanzar Flutter
    echo -e "${YELLOW}⏳ Compilando y lanzando (esto puede tomar 2-5 minutos)...${NC}\n"
    flutter run -d "$device_id"
}

# Función para lanzar en Android
lanzar_android() {
    echo -e "${BLUE}🤖 Lanzando emulador Android...${NC}"
    flutter emulators --launch Medium_Phone_API_36.0 &
    sleep 5
    echo -e "${BLUE}🚀 Lanzando Biux en Android...${NC}\n"
    flutter run -d emulator-5554
}

# Función para lanzar en Chrome
lanzar_chrome() {
    echo -e "${BLUE}🌐 Verificando servidor web...${NC}"
    
    # Verificar si el servidor está corriendo
    if lsof -Pi :9090 -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${GREEN}✅ Servidor web ya está corriendo en puerto 9090${NC}"
    else
        echo -e "${YELLOW}⚠️  Servidor no está corriendo. Iniciando...${NC}"
        cd build/web && python3 -m http.server 9090 &
        sleep 2
        echo -e "${GREEN}✅ Servidor iniciado en puerto 9090${NC}"
    fi
    
    echo -e "${BLUE}🚀 Abriendo Biux en Chrome...${NC}\n"
    open -a "Google Chrome" http://localhost:9090
}

# Función para limpiar y reconstruir
rebuild() {
    echo -e "${BLUE}🧹 Limpiando proyecto...${NC}"
    flutter clean
    
    echo -e "${BLUE}📦 Obteniendo dependencias...${NC}"
    flutter pub get
    
    echo -e "${BLUE}🔨 Construyendo para web...${NC}"
    flutter build web --release
    
    echo -e "${GREEN}✅ Reconstrucción completa${NC}"
}

# Función para mostrar estado de dispositivos
estado() {
    echo -e "${YELLOW}📊 Estado de dispositivos:${NC}\n"
    
    echo -e "${BLUE}iOS Simuladores:${NC}"
    
    # Lista de dispositivos
    local devices=("promax:iPhone 16 Pro Max" "pro:iPhone 16 Pro" "se:iPhone 16e" "standard:iPhone 16" "plus:iPhone 16 Plus")
    
    for device_info in "${devices[@]}"; do
        IFS=':' read -r key name <<< "$device_info"
        local device_id=$(get_device_id "$key")
        local estado=$(verificar_simulador "$device_id")
        if [ "$estado" == "Booted" ]; then
            echo -e "  ${GREEN}●${NC} $name (ID: $key) - ${GREEN}Encendido${NC}"
        else
            echo -e "  ${RED}○${NC} $name (ID: $key) - Apagado"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Servidor Web:${NC}"
    if lsof -Pi :9090 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "  ${GREEN}●${NC} http://localhost:9090 - ${GREEN}Corriendo${NC}"
    else
        echo -e "  ${RED}○${NC} http://localhost:9090 - Detenido"
    fi
    
    echo ""
    flutter devices
}

# Función para detener todo
stop() {
    echo -e "${RED}🛑 Deteniendo todos los procesos...${NC}"
    
    # Detener Xcode builds
    killall -9 xcodebuild 2>/dev/null || true
    
    # Detener servidor web
    lsof -ti:9090 | xargs kill -9 2>/dev/null || true
    
    # Apagar simuladores
    local devices=("promax" "pro" "se" "standard" "plus")
    for key in "${devices[@]}"; do
        local device_id=$(get_device_id "$key")
        xcrun simctl shutdown "$device_id" 2>/dev/null || true
    done
    
    echo -e "${GREEN}✅ Todos los procesos detenidos${NC}"
}

# Menú principal
main() {
    local dispositivo=$1
    
    case "$dispositivo" in
        "promax"|"pro"|"se"|"standard"|"plus")
            local device_id=$(get_device_id "$dispositivo")
            local nombre=$(get_device_name "$dispositivo")
            
            # Verificar estado
            local estado=$(verificar_simulador "$device_id")
            if [ "$estado" != "Booted" ]; then
                encender_simulador "$device_id" "$nombre"
            else
                echo -e "${GREEN}✅ $nombre ya está encendido${NC}"
            fi
            
            # Lanzar app
            lanzar_biux "$device_id" "$nombre"
            ;;
        
        "android")
            lanzar_android
            ;;
        
        "chrome"|"web")
            lanzar_chrome
            ;;
        
        "rebuild"|"build")
            rebuild
            ;;
        
        "estado"|"status")
            estado
            ;;
        
        "stop"|"detener")
            stop
            ;;
        
        "list"|"lista"|"")
            mostrar_dispositivos
            echo -e "${YELLOW}💡 Uso:${NC}"
            echo "  ./launch_biux_simulators.sh [dispositivo]"
            echo ""
            echo -e "${YELLOW}📋 Comandos especiales:${NC}"
            echo -e "  ${GREEN}estado${NC}   → Ver estado de todos los dispositivos"
            echo -e "  ${GREEN}rebuild${NC}  → Limpiar y reconstruir proyecto"
            echo -e "  ${GREEN}stop${NC}     → Detener todos los procesos"
            echo ""
            echo -e "${YELLOW}📖 Ejemplos:${NC}"
            echo "  ./launch_biux_simulators.sh promax"
            echo "  ./launch_biux_simulators.sh chrome"
            echo "  ./launch_biux_simulators.sh android"
            echo "  ./launch_biux_simulators.sh estado"
            ;;
        
        *)
            echo -e "${RED}❌ Dispositivo no reconocido: $dispositivo${NC}\n"
            mostrar_dispositivos
            ;;
    esac
}

# Ejecutar
main "$@"
