#!/bin/bash

# 🔥 Script de Verificación de Firebase Phone Authentication
# Este script verifica la configuración de Firebase y habilita Phone Auth

set -e

echo "🔥 =================================="
echo "🔥 VERIFICACIÓN DE FIREBASE PHONE AUTH"
echo "🔥 =================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ID="biux-1576614678644"

echo -e "${BLUE}📋 Proyecto Firebase:${NC} $PROJECT_ID"
echo ""

# 1. Verificar Firebase CLI
echo -e "${YELLOW}[1/5]${NC} Verificando Firebase CLI..."
if command -v firebase &> /dev/null; then
    echo -e "${GREEN}✅ Firebase CLI instalado${NC}"
    firebase --version
else
    echo -e "${RED}❌ Firebase CLI NO instalado${NC}"
    echo -e "${YELLOW}Instalar con: npm install -g firebase-tools${NC}"
    exit 1
fi
echo ""

# 2. Verificar login en Firebase
echo -e "${YELLOW}[2/5]${NC} Verificando autenticación..."
if firebase projects:list &> /dev/null; then
    echo -e "${GREEN}✅ Autenticado en Firebase${NC}"
    firebase projects:list | grep "$PROJECT_ID" || echo -e "${RED}⚠️  Proyecto $PROJECT_ID no encontrado${NC}"
else
    echo -e "${RED}❌ No autenticado en Firebase${NC}"
    echo -e "${YELLOW}Ejecutar: firebase login${NC}"
    exit 1
fi
echo ""

# 3. Verificar archivo firebase.json
echo -e "${YELLOW}[3/5]${NC} Verificando firebase.json..."
if [ -f "firebase.json" ]; then
    echo -e "${GREEN}✅ firebase.json encontrado${NC}"
    cat firebase.json | grep -q "hosting" && echo "   - Hosting configurado"
    cat firebase.json | grep -q "functions" && echo "   - Functions configurado"
else
    echo -e "${YELLOW}⚠️  firebase.json no encontrado${NC}"
fi
echo ""

# 4. Verificar GoogleService-Info.plist (iOS)
echo -e "${YELLOW}[4/5]${NC} Verificando configuración iOS..."
IOS_PLIST="ios/Runner/GoogleService-Info.plist"
if [ -f "$IOS_PLIST" ]; then
    echo -e "${GREEN}✅ GoogleService-Info.plist encontrado${NC}"
    grep -q "$PROJECT_ID" "$IOS_PLIST" && echo -e "${GREEN}   ✓ Project ID correcto${NC}" || echo -e "${RED}   ✗ Project ID incorrecto${NC}"
else
    echo -e "${RED}❌ GoogleService-Info.plist NO encontrado${NC}"
    echo -e "${YELLOW}   Descargar desde: https://console.firebase.google.com/project/$PROJECT_ID/settings/general/ios:2f33fcae8fbaeb5f6dc464${NC}"
fi
echo ""

# 5. Verificar google-services.json (Android)
echo -e "${YELLOW}[5/5]${NC} Verificando configuración Android..."
ANDROID_JSON="android/app/google-services.json"
if [ -f "$ANDROID_JSON" ]; then
    echo -e "${GREEN}✅ google-services.json encontrado${NC}"
    grep -q "$PROJECT_ID" "$ANDROID_JSON" && echo -e "${GREEN}   ✓ Project ID correcto${NC}" || echo -e "${RED}   ✗ Project ID incorrecto${NC}"
else
    echo -e "${RED}❌ google-services.json NO encontrado${NC}"
    echo -e "${YELLOW}   Descargar desde: https://console.firebase.google.com/project/$PROJECT_ID/settings/general/android:e33e776147e7458b6dc464${NC}"
fi
echo ""

# Resumen
echo -e "${BLUE}=================================="
echo -e "📋 RESUMEN DE CONFIGURACIÓN"
echo -e "==================================${NC}"
echo ""

# Instrucciones para habilitar Phone Auth
echo -e "${GREEN}✅ SIGUIENTE PASO: Habilitar Phone Authentication${NC}"
echo ""
echo -e "${YELLOW}📱 OPCIÓN 1: Desde la Consola Web${NC}"
echo "1. Abre: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
echo "2. Click en 'Phone'"
echo "3. Habilita el toggle"
echo "4. Click en 'Save'"
echo ""

echo -e "${YELLOW}📱 OPCIÓN 2: Desde Firebase CLI (EXPERIMENTAL)${NC}"
echo "firebase auth:import --project $PROJECT_ID --provider phone"
echo ""

echo -e "${GREEN}🍎 CONFIGURAR APNs (iOS - PRODUCCIÓN)${NC}"
echo "1. Ve a: https://console.firebase.google.com/project/$PROJECT_ID/settings/cloudmessaging"
echo "2. Click en la app iOS"
echo "3. Sube tu APNs Authentication Key (.p8)"
echo "   - Key ID: Tu Apple Developer Key ID"
echo "   - Team ID: Tu Apple Developer Team ID"
echo ""

echo -e "${GREEN}🧪 NÚMERO DE PRUEBA (TESTING)${NC}"
echo "Para testing sin SMS real:"
echo "1. Ve a: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
echo "2. Click en 'Phone' → 'Phone numbers for testing'"
echo "3. Agrega: +57 123 456 7890 → Código: 123456"
echo ""

echo -e "${BLUE}=================================="
echo -e "✅ VERIFICACIÓN COMPLETA"
echo -e "==================================${NC}"
echo ""
echo -e "${YELLOW}📖 Para más información, revisa: FIREBASE_PHONE_AUTH_SETUP.md${NC}"
echo ""
