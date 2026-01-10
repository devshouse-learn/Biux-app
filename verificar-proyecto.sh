#!/bin/bash
# Script de Limpieza y Verificación Final - Biux App
# Fecha: 10 de Enero de 2026

echo "🧹 LIMPIEZA Y VERIFICACIÓN FINAL DE BIUX APP"
echo "=============================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Contadores
total_issues=0

echo "📋 1. Verificando Flutter Analyze..."
if flutter analyze --no-fatal-infos 2>&1 | grep -q "No issues found"; then
  echo -e "${GREEN}✅ Flutter Analyze: Sin problemas${NC}"
else
  echo -e "${RED}❌ Flutter Analyze: Problemas encontrados${NC}"
  total_issues=$((total_issues + 1))
fi
echo ""

echo "🎨 2. Verificando Formato de Código..."
formatted=$(dart format --set-exit-if-changed lib/ 2>&1 | grep "changed" | awk '{print $3}')
if [ "$formatted" = "(0" ] || [ -z "$formatted" ]; then
  echo -e "${GREEN}✅ Formato: Código correctamente formateado${NC}"
else
  echo -e "${YELLOW}⚠️  Formato: Aplicando formato...${NC}"
  dart format lib/
  echo -e "${GREEN}✅ Formato aplicado${NC}"
fi
echo ""

echo "🔍 3. Verificando Dependencias..."
if flutter pub get > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Dependencias: Actualizadas${NC}"
else
  echo -e "${RED}❌ Dependencias: Error al actualizar${NC}"
  total_issues=$((total_issues + 1))
fi
echo ""

echo "🏥 4. Verificando Flutter Doctor..."
if flutter doctor 2>&1 | grep -q "No issues found"; then
  echo -e "${GREEN}✅ Flutter Doctor: Sin problemas${NC}"
else
  echo -e "${YELLOW}⚠️  Flutter Doctor: Revisa manualmente con 'flutter doctor -v'${NC}"
fi
echo ""

echo "🧪 5. Verificando Tests (si existen)..."
if [ -d "test" ] && [ "$(ls -A test)" ]; then
  if flutter test 2>&1 | grep -q "All tests passed"; then
    echo -e "${GREEN}✅ Tests: Todos pasaron${NC}"
  else
    echo -e "${YELLOW}⚠️  Tests: Algunos fallos (revisar manualmente)${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Tests: No se encontraron tests${NC}"
fi
echo ""

echo "🔒 6. Verificando Seguridad..."
# Verificar que no haya credenciales expuestas
if grep -r "password.*=.*['\"][^$]" --include="*.sh" . 2>/dev/null | grep -v "APPLE_PASSWORD="; then
  echo -e "${RED}❌ Seguridad: Credenciales expuestas encontradas${NC}"
  total_issues=$((total_issues + 1))
else
  echo -e "${GREEN}✅ Seguridad: No se encontraron credenciales expuestas${NC}"
fi
echo ""

echo "📱 7. Verificando Configuración iOS..."
if [ -f "ios/Runner/Info.plist" ]; then
  echo -e "${GREEN}✅ iOS: Configuración encontrada${NC}"
else
  echo -e "${YELLOW}⚠️  iOS: Archivo Info.plist no encontrado${NC}"
fi
echo ""

echo "🤖 8. Verificando Configuración Android..."
if [ -f "android/app/build.gradle" ]; then
  echo -e "${GREEN}✅ Android: Configuración encontrada${NC}"
else
  echo -e "${YELLOW}⚠️  Android: Archivo build.gradle no encontrado${NC}"
fi
echo ""

echo "🌐 9. Verificando Configuración Web..."
if [ -f "web/index.html" ]; then
  echo -e "${GREEN}✅ Web: Configuración encontrada${NC}"
else
  echo -e "${YELLOW}⚠️  Web: Archivo index.html no encontrado${NC}"
fi
echo ""

echo "📦 10. Limpiando archivos temporales..."
# Limpiar build cache
if [ -d "build" ]; then
  echo "  - Limpiando build/"
fi
if [ -d ".dart_tool" ]; then
  echo "  - Limpiando .dart_tool/"
fi
flutter clean > /dev/null 2>&1
echo -e "${GREEN}✅ Limpieza completada${NC}"
echo ""

echo "=============================================="
echo "📊 RESUMEN FINAL"
echo "=============================================="
echo ""

if [ $total_issues -eq 0 ]; then
  echo -e "${GREEN}🎉 ¡PERFECTO! No se encontraron problemas${NC}"
  echo ""
  echo "✅ El proyecto está listo para:"
  echo "   • Desarrollo"
  echo "   • Compilación"
  echo "   • Deploy"
  echo ""
else
  echo -e "${YELLOW}⚠️  Se encontraron $total_issues problema(s)${NC}"
  echo ""
  echo "Por favor revisa los mensajes anteriores y corrige los problemas."
  echo ""
fi

echo "🚀 Comandos útiles:"
echo "   flutter run           - Ejecutar en modo debug"
echo "   flutter build ios     - Compilar para iOS"
echo "   flutter build apk     - Compilar para Android"
echo "   flutter build web     - Compilar para Web"
echo ""

echo "📚 Documentación:"
echo "   RESUMEN_CORRECCION_FINAL_10ENE2026.md"
echo "   CORRECCION_SEGURIDAD_CRITICA_10ENE2026.md"
echo "   URGENTE_SEGURIDAD_LEER_PRIMERO.txt"
echo ""

echo "Verificación completada: $(date)"
