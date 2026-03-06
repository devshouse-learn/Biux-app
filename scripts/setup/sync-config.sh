#!/bin/bash

# Script para sincronizar archivos de configuración
# Copia cambios desde root-config/ a la raíz
# Ejecutar después de editar archivos en root-config/

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_CONFIG="$PROJECT_ROOT/root-config"

echo "🔄 Sincronizando archivos de configuración..."
echo ""

# Copiar archivos de root-config/ a raíz
cp "$ROOT_CONFIG/analysis_options.yaml" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/devtools_options.yaml" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/firebase.json" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/flutter_launcher_icons.yaml" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/README.md" "$PROJECT_ROOT/"

echo "✅ Sincronización completada"
echo ""
echo "Los siguientes archivos han sido actualizados en raíz:"
echo "   - analysis_options.yaml"
echo "   - devtools_options.yaml"
echo "   - firebase.json"
echo "   - flutter_launcher_icons.yaml"
echo "   - README.md"
