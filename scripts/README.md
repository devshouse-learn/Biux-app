# Scripts de Biux

Esta carpeta contiene scripts útiles para el desarrollo y mantenimiento del proyecto.

## Archivos

### Verificación
- `verificar-proyecto.sh` - Verifica la estructura y configuración general del proyecto
- `verify_firebase_phone_auth.sh` - Verifica la configuración de autenticación por teléfono de Firebase

### Datos de Prueba
- `seed_products.dart` - Script para poblar la base de datos con productos de prueba

## Uso

### Scripts Shell (.sh)
```bash
bash scripts/verificar-proyecto.sh
bash scripts/verify_firebase_phone_auth.sh
```

### Scripts Dart
```bash
dart run scripts/seed_products.dart
```

## Requisitos

- Bash o compatible para scripts .sh
- Dart SDK para scripts .dart
- Firebase configurado para scripts de verificación de Firebase
