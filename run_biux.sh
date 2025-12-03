#!/bin/bash

# Script para lanzar Biux en diferentes plataformas
# Uso: ./run_biux.sh [chrome|ios|android|web]

echo "🚴 Biux - Script de Lanzamiento"
echo "================================"

PLATFORM=${1:-chrome}

case $PLATFORM in
  chrome|web)
    echo "📱 Lanzando en Chrome..."
    echo ""
    
    # Verificar si el servidor ya está corriendo
    if lsof -Pi :9090 -sTCP:LISTEN -t >/dev/null ; then
        echo "✅ Servidor ya corriendo en puerto 9090"
    else
        echo "🔄 Iniciando servidor HTTP..."
        cd build/web && python3 -m http.server 9090 > /dev/null 2>&1 &
        SERVER_PID=$!
        echo "✅ Servidor iniciado (PID: $SERVER_PID)"
        sleep 2
    fi
    
    echo "🌐 Abriendo Chrome en http://localhost:9090"
    open -a "Google Chrome" "http://localhost:9090"
    echo ""
    echo "✅ App lista en Chrome!"
    echo "   URL: http://localhost:9090"
    ;;
    
  ios)
    echo "📱 Lanzando en iOS Simulator..."
    echo ""
    
    # Listar simuladores disponibles
    echo "Simuladores disponibles:"
    xcrun simctl list devices | grep "iPhone"
    echo ""
    
    # Lanzar en el simulador por defecto
    flutter run -d "iPhone 15 Pro"
    ;;
    
  android)
    echo "📱 Lanzando en Android Emulator..."
    echo ""
    
    # Verificar si hay emuladores corriendo
    if adb devices | grep -q "emulator"; then
        echo "✅ Emulador detectado"
    else
        echo "⚠️  No hay emulador corriendo"
        echo "Iniciando emulador..."
        emulator -avd Pixel_7_API_34 &
        sleep 10
    fi
    
    flutter run -d emulator-5554
    ;;
    
  build)
    echo "🔨 Reconstruyendo la app..."
    echo ""
    
    echo "1️⃣ Limpiando builds anteriores..."
    flutter clean
    
    echo "2️⃣ Obteniendo dependencias..."
    flutter pub get
    
    echo "3️⃣ Construyendo para web..."
    flutter build web --release
    
    echo ""
    echo "✅ Build completado!"
    echo "Ejecuta: ./run_biux.sh chrome"
    ;;
    
  stop)
    echo "🛑 Deteniendo servidor..."
    lsof -ti:9090 | xargs kill -9 2>/dev/null
    echo "✅ Servidor detenido"
    ;;
    
  *)
    echo "❌ Plataforma no reconocida: $PLATFORM"
    echo ""
    echo "Uso: ./run_biux.sh [chrome|ios|android|build|stop]"
    echo ""
    echo "Opciones:"
    echo "  chrome   - Lanza en Chrome (web)"
    echo "  ios      - Lanza en iOS Simulator"
    echo "  android  - Lanza en Android Emulator"
    echo "  build    - Reconstruye la app"
    echo "  stop     - Detiene el servidor web"
    exit 1
    ;;
esac

echo ""
echo "🎉 ¡Listo!"
