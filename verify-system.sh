#!/bin/bash

echo "🔍 VERIFICACIÓN DEL SISTEMA DE DEPLOY"
echo "========================================="
echo ""

# 1. Daemon
echo "1️⃣ DAEMON"
if launchctl list | grep -q "com.biux.deploy"; then
  echo "   ✅ Daemon registrado en launchd"
else
  echo "   ❌ Daemon NO registrado"
fi

# 2. CocoaPods
echo ""
echo "2️⃣ COCOAPODS"
if which pod > /dev/null 2>&1; then
  POD_VERSION=$(pod --version)
  echo "   ✅ CocoaPods instalado (v$POD_VERSION)"
else
  echo "   ❌ CocoaPods NO encontrado"
fi

# 3. Flutter
echo ""
echo "3️⃣ FLUTTER"
if which flutter > /dev/null 2>&1; then
  FLUTTER_VERSION=$(flutter --version | head -1)
  echo "   ✅ $FLUTTER_VERSION"
else
  echo "   ❌ Flutter NO encontrado"
fi

# 4. Xcode
echo ""
echo "4️⃣ XCODE"
if which xcodebuild > /dev/null 2>&1; then
  XCODE_VERSION=$(xcodebuild -version | head -1)
  echo "   ✅ $XCODE_VERSION"
else
  echo "   ❌ Xcode NO encontrado"
fi

# 5. Scripts deploy
echo ""
echo "5️⃣ SCRIPTS DEPLOY"
for script in deploy.sh deploy-worker.sh deploy-daemon.sh deploy-now.sh deploy-gui.sh; do
  if [ -x "/Users/macmini/biux/$script" ]; then
    echo "   ✅ $script (ejecutable)"
  else
    echo "   ❌ $script (NO ejecutable o no existe)"
  fi
done

# 6. Build number actual
echo ""
echo "6️⃣ BUILD NUMBER"
cd /Users/macmini/biux/ios 2>/dev/null
if [ $? -eq 0 ]; then
  BUILD=$(agvtool what-version -terse 2>/dev/null | tail -1)
  echo "   ✅ Build actual: $BUILD"
else
  echo "   ❌ No se pudo obtener build number"
fi

# 7. Último log
echo ""
echo "7️⃣ ÚLTIMO LOG"
if [ -f "/Users/macmini/biux/.deploy-daemon.log" ]; then
  LAST_LINE=$(tail -1 /Users/macmini/biux/.deploy-daemon.log)
  echo "   ✅ $LAST_LINE"
else
  echo "   ⚠️  No hay log aún (normal si es primer deploy)"
fi

# 8. Credenciales
echo ""
echo "8️⃣ CREDENCIALES"
if grep -q "APPLE_PASSWORD" /Users/macmini/biux/deploy-worker.sh; then
  echo "   ✅ Credenciales embebidas en deploy-worker.sh"
else
  echo "   ❌ Credenciales NO embebidas"
fi

echo ""
echo "========================================="
echo "✅ VERIFICACIÓN COMPLETADA"
echo ""
echo "Próximos pasos:"
echo "  1. Haz un commit: git commit -m 'test'"
echo "  2. Mira logs: bash deploy-daemon.sh tail"
echo "  3. Dashboard: bash deploy-gui.sh"
echo ""
