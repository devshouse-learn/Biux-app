# 📋 Comandos Copy-Paste para Testing

## 🔧 Setup Inicial

### Limpiar Build y Compilar Fresh

```bash
cd /Users/macmini/biux

# Limpiar todo
flutter clean

# Descargar dependencias
flutter pub get

# Analizar (verifica que no hay errores)
flutter analyze --no-fatal-infos

# Correr en device/emulador
flutter run
```

---

## 📱 Testing Deep Links - Android

### Pre-requisito: Device/Emulador Conectado

```bash
# Verificar que el device esté conectado
adb devices
```

### Test 1: Deep Link con Esquema biux://

```bash
# Opción 1: ID conocido
adb shell am start -a android.intent.action.VIEW -d "biux://ride/test123" com.devshouse.biux

# Opción 2: Con grupo
adb shell am start -a android.intent.action.VIEW -d "biux://group/grupo456" com.devshouse.biux

# Opción 3: Perfil de usuario
adb shell am start -a android.intent.action.VIEW -d "biux://user/user789" com.devshouse.biux
```

### Test 2: App Link con HTTPS (biux.devshouse.org)

```bash
# Rodada
adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/ride/test123" com.devshouse.biux

# Grupo
adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/group/grupo456" com.devshouse.biux

# Usuario
adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/user/user789" com.devshouse.biux
```

### Test 3: Ver Logs en Tiempo Real

```bash
# Terminal 1: Iniciar logcat
adb logcat | grep -E "deep|route|Guard|🔗|✅|❌"

# Terminal 2 (en otra terminal): Ejecutar comando deep link
adb shell am start -a android.intent.action.VIEW -d "biux://ride/test123" com.devshouse.biux
```

### Test 4: Verificar assetlinks.json Accesible

```bash
# Verificar que archivo existe en servidor
curl -I https://biux.devshouse.org/.well-known/assetlinks.json

# Ver contenido completo
curl https://biux.devshouse.org/.well-known/assetlinks.json | jq .
```

---

## 🔑 Obtener SHA256 Fingerprint

### Debug Keystore (desarrollo)

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -storepass android \
  -keypass android \
  | grep "SHA256"
```

**Output esperado**:
```
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

Copiar SOLO los caracteres entre SHA256 y salto de línea, quitando los dos puntos:
```
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Production Keystore

```bash
# Necesitas el path a tu keystore y la password
keytool -list -v -keystore /path/to/your/keystore.jks \
  -storepass YOUR_PASSWORD \
  | grep "SHA256"
```

---

## 📝 Actualizar assetlinks.json

### 1. Obtener el Fingerprint

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -storepass android \
  -keypass android \
  | grep "SHA256" | head -1
```

### 2. Copiar Output (ejemplo)

```
SHA256: 1A:2B:3C:4D:5E:6F:7A:8B:9C:0D:1E:2F:3A:4B:5C:6D:7E:8F:9A:0B
```

### 3. Remover Dos Puntos

```
1A2B3C4D5E6F7A8B9C0D1E2F3A4B5C6D7E8F9A0B
```

### 4. Editar assetlinks.json

```bash
# Abrir archivo
nano /Users/macmini/biux/assetlinks.json

# O con editor favorito
code /Users/macmini/biux/assetlinks.json
```

### 5. Reemplazar Placeholder

**ANTES**:
```json
{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.devshouse.biux",
    "sha256_cert_fingerprints": [
      "REPLACE_WITH_YOUR_SHA256_FINGERPRINT"
    ]
  }
}
```

**DESPUÉS** (con tu fingerprint):
```json
{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.devshouse.biux",
    "sha256_cert_fingerprints": [
      "1A2B3C4D5E6F7A8B9C0D1E2F3A4B5C6D7E8F9A0B"
    ]
  }
}
```

### 6. Guardar y Publicar

```bash
# Copiar a servidor en .well-known
# Necesitas acceso SSH a tu servidor
scp /Users/macmini/biux/assetlinks.json \
  user@biux.devshouse.org:/var/www/html/.well-known/

# Verificar que está accesible
curl https://biux.devshouse.org/.well-known/assetlinks.json
```

---

## 🧪 Tests de Funcionalidad

### Test: Eliminar Historia

```dart
// En la app:
1. Stories tab
2. Abre una historia tuya
3. Tap botón 🗑️
4. Confirma
5. Esperado: Historia desaparece
```

### Test: 5+ Fotos

```dart
// En la app:
1. Stories tab → "+"
2. Selecciona 5-6 fotos
3. Descripción: opcional (deja vacío)
4. Publicar
5. Esperado: Se sube exitosamente
```

---

## 🏗️ Build para Producción

### Build APK (Android)

```bash
cd /Users/macmini/biux

# APK Debug (para testing)
flutter build apk --debug

# APK Release (para tienda)
flutter build apk --release
```

### Build Bundle (Google Play)

```bash
flutter build appbundle --release
```

---

## 📊 Verificación Final

### Verificar Compilación

```bash
flutter analyze --no-fatal-infos
```

**Esperado**: 143 warnings (solo deprecaciones)

### Verificar Web Build

```bash
flutter build web --release
```

**Esperado**: `✓ Built build/web`

### Ejecutar Pruebas

```bash
flutter test
```

---

## 🐛 Debugging Avanzado

### Ver Todos los Logs

```bash
adb logcat
```

### Filtrar por la App

```bash
adb logcat | grep "com.devshouse.biux\|flutter"
```

### Guardar Logs a Archivo

```bash
adb logcat > /tmp/biux_debug.log

# Después ejecutar test...

# Analizar
cat /tmp/biux_debug.log | grep "deep\|route\|Guard"
```

### Ver Last 100 Lines

```bash
adb logcat | tail -100
```

### Clear Logs

```bash
adb logcat -c
```

---

## 📱 iOS Testing (si necesario)

### Test Deep Link en iOS

```bash
# Conectar device iOS

# Build debug
flutter run -d <device_id>

# Desde otra terminal, abrir deep link
xcrun simctl openurl booted "biux://ride/test123"

# O en device real (necesita URL scheme configurado)
```

---

## 🔍 Verificar Cambios Hechos

### Ver Archivos Modificados

```bash
cd /Users/macmini/biux

# Ver qué archivos se modificaron
git status

# Ver cambios en específico
git diff lib/core/config/router/app_router.dart
git diff lib/core/services/deep_link_service.dart
git diff lib/features/stories/data/repositories/stories_firebase_repository.dart
```

### Ver Commits Recientes

```bash
git log --oneline -5
```

---

## ✅ Checklist Final

```bash
# 1. Limpiar
cd /Users/macmini/biux
flutter clean

# 2. Descargar dependencias
flutter pub get

# 3. Analizar (sin errores)
flutter analyze --no-fatal-infos

# 4. Compilar web (verificar)
flutter build web --release

# 5. Run en device
flutter run

# 6. Probar deep links en terminal diferente
adb shell am start -a android.intent.action.VIEW -d "biux://ride/test" com.devshouse.biux

# 7. Revisar logs
adb logcat | grep "deep\|route"
```

---

## 🚀 Deployment Steps

```bash
# 1. Obtener SHA256
keytool -list -v -keystore ~/.android/debug.keystore \
  -storepass android | grep SHA256

# 2. Actualizar assetlinks.json
nano /Users/macmini/biux/assetlinks.json

# 3. Publicar en servidor
scp /Users/macmini/biux/assetlinks.json \
  user@biux.devshouse.org:/var/www/html/.well-known/

# 4. Verificar acceso
curl https://biux.devshouse.org/.well-known/assetlinks.json

# 5. Build app bundle
flutter build appbundle --release

# 6. Upload a Google Play Console
```

---

**Última Actualización**: 25 de Noviembre 2024
**Status**: ✅ Ready to Copy-Paste
