#!/bin/bash

# Script de configuración inicial del proyecto
# Copia los archivos maestros de root-config/ a la raíz
# Ejecutar una sola vez después de clonar el repositorio

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT_CONFIG="$PROJECT_ROOT/root-config"

echo "🔧 Configurando archivos del proyecto..."
echo ""

# Copiar archivos de configuración de root-config a raíz
cp "$ROOT_CONFIG/analysis_options.yaml" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/devtools_options.yaml" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/firebase.json" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/flutter_launcher_icons.yaml" "$PROJECT_ROOT/"
cp "$ROOT_CONFIG/README.md" "$PROJECT_ROOT/"

echo "✅ Archivos de configuración copiados a la raíz"
echo ""
echo "📝 Nota importante:"
echo "   - Los archivos maestros están en: root-config/"
echo "   - Las copias en raíz son generadas por este script"
echo "   - Siempre edita los archivos en root-config/"
echo "   - Luego ejecuta: ./scripts/sync-config.sh"
