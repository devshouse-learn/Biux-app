# 🧪 Guía de Testing - Deep Links y Story Management

## 🎯 Escenarios a Probar

### ESCENARIO 1: Eliminar una Historia

**Objetivo**: Verificar que el usuario propietario puede eliminar sus historias

**Pasos**:

1. Abre la app BIUX
2. Navega a "Stories" (primer tab)
3. Abre una historia que hayas creado (debes ser propietario)
4. **Esperado**: Deberías ver un botón 🗑️ rojo en la esquina superior derecha
5. Tap en el botón 🗑️
6. **Esperado**: Aparece un diálogo preguntando "¿Eliminar historia?"
7. Tap "Sí, eliminar"
8. **Esperado**: La historia desaparece y vuelves al feed

**Logging Esperado**:
```
✅ Story eliminada exitosamente
```

---

### ESCENARIO 2: NO Aparecer Botón Delete si No Eres Propietario

**Objetivo**: Verificar que solo el propietario ve el botón de eliminar

**Pasos**:

1. Abre historia de otro usuario
2. **Esperado**: NO deberías ver botón 🗑️
3. Verificar que la historia se ve normal sin opción de delete

**Logging Esperado**:
```
🔍 Usuario X no es propietario de historia Y
```

---

### ESCENARIO 3: Subir Múltiples Fotos (>3)

**Objetivo**: Verificar que se pueden subir ilimitadas fotos (antes maxeaba en 3)

**Pasos**:

1. Ve a Stories → Tap "+" para crear
2. Selecciona **5-6 fotos** (más que las 3 antiguas)
3. Agrega descripción o deja vacío (ahora es opcional)
4. Tap "Publicar"
5. **Esperado**: La historia se sube exitosamente con todas las fotos

**Logging Esperado**:
```
📤 Iniciando carga de 5 imágenes
📸 Cargando imagen 1: /path/to/photo1.jpg
✅ Imagen cargada: gs://bucket/story/123/photo1
📸 Cargando imagen 2: /path/to/photo2.jpg
✅ Imagen cargada: gs://bucket/story/123/photo2
... (repite para todas)
✅ Historia publicada exitosamente
```

---

### ESCENARIO 4: Descripción Opcional

**Objetivo**: Verificar que la descripción no es obligatoria

**Pasos**:

1. Ve a Stories → Tap "+"
2. Selecciona **1-2 fotos**
3. **NO escribas descripción** - deja el campo vacío
4. Tap "Publicar"
5. **Esperado**: Se sube la historia sin error

**Antes** (❌):
```
Error: "Descripción es requerida"
```

**Ahora** (✅):
```
✅ Publicada sin descripción
```

---

### ESCENARIO 5: Deep Link - Abrir Rodada desde Consola

**Objetivo**: Verificar que los deep links funcionan

**Prerequisito**: 
- Tener una rodada con ID conocido (ej: "ride123")
- Haber actualizado `assetlinks.json` con SHA256

**Pasos (Android)**:

1. Cierra la app BIUX completamente
2. Abre terminal y ejecuta:
   ```bash
   # Obtener una rodada real
   adb logcat | grep -i "ride"
   
   # O usar un ID conocido
   adb shell am start -a android.intent.action.VIEW -d "biux://ride/ride_test_123" com.devshouse.biux
   ```
3. **Esperado**: La app abre y navega directamente a esa rodada

**Logging Esperado**:
```
🔗 Intentando convertir deep link: biux://ride/ride_test_123
🔗 Detectado deep link con esquema biux://
✅ Ruta convertida: biux://ride/ride_test_123 → /rides/ride_test_123
🔍 Router Guard - Location: /rides/ride_test_123, isLoggedIn: true
✅ Usuario autenticado, permitiendo acceso
```

---

### ESCENARIO 6: Deep Link - HTTPS App Links

**Objetivo**: Probar app links con dominio personalizado

**Pasos**:

1. Cierra app completamente
2. Ejecuta en terminal:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/ride/ride_test_456" com.devshouse.biux
   ```
3. **Esperado**: App abre directo en rodada

**Logging Esperado**:
```
🔗 Intentando convertir deep link: https://biux.devshouse.org/ride/ride_test_456
🔗 Detectado app link de biux.devshouse.org
🔗 Path: /ride/ride_test_456, Segments: [, ride, ride_test_456]
✅ Ruta convertida: https://biux.devshouse.org/ride/ride_test_456 → /rides/ride_test_456
```

---

### ESCENARIO 7: Compartir Rodada a WhatsApp

**Objetivo**: Verificar que el share text incluye deep link

**Pasos**:

1. Ve a una rodada cualquiera
2. Busca botón "Compartir" o similar
3. Tap en compartir
4. Selecciona WhatsApp
5. **Esperado**: Mensaje con formato:
   ```
   🚴 ¡Únete a la rodada "Nombre Rodada"!
   
   📍 Tap para ver detalles e inscribirte:
   https://biux.devshouse.org/ride/{rideId}
   ```
6. Copia el link
7. En terminal Android:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/ride/{rideId}" com.devshouse.biux
   ```
8. **Esperado**: App abre en esa rodada

---

### ESCENARIO 8: Sin Autenticación + Deep Link

**Objetivo**: Verificar que si NO estás logueado, te pide login primero

**Pasos**:

1. Cierra sesión (logout de la app)
2. Cierra app completamente
3. Abre desde terminal:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "biux://ride/ride_test_789" com.devshouse.biux
   ```
4. **Esperado**: 
   - App abre en pantalla de Login
   - Una vez logueado → navega a la rodada

**Logging Esperado**:
```
🚫 Usuario no autenticado, redirigiendo al login
[Usuario se loguea]
✅ Usuario autenticado, redirigiendo a ruta convertida: /rides/ride_test_789
```

---

## 🔧 Comandos de Debugging

### Ver Logs en Tiempo Real

```bash
# Terminal 1: Ver todos los logs
adb logcat | grep -i "deep\|route\|guard"

# Terminal 2: Ejecutar comando
adb shell am start -a android.intent.action.VIEW -d "biux://ride/123" com.devshouse.biux
```

### Ver Logs de Específicamente la App

```bash
adb logcat | grep "com.devshouse.biux\|flutter\|🔗\|✅\|❌"
```

### Limpiar Logs Anteriores

```bash
adb logcat -c
```

### Guardar Logs en Archivo

```bash
adb logcat > biux_logs.txt
# Luego ejecutar test...
# Después analizar archivo
cat biux_logs.txt | grep -i "deep\|route"
```

---

## 📋 Test Report Template

Cuando completes los tests, reporta así:

```markdown
## Test Results - [Fecha]

### ✅ Passed
- [x] Eliminar historia (propietario)
- [x] NO mostrar delete (no propietario)
- [x] 5 fotos subidas
- [x] Descripción opcional
- [x] Deep link biux://
- [x] App link https://
- [x] Compartir a WhatsApp
- [x] Login requerido

### ❌ Failed
- [ ] (ningún fallo)

### ⚠️ Issues Encontrados
- (ninguno)

### 📊 Device Info
- Device: [Nombre del device]
- Android: [Versión]
- App Version: [Versión]

### 📝 Notas
- (observaciones adicionales)
```

---

## 🐛 Si Algo NO Funciona

### Problema: Botón Delete No Aparece

**Debugging**:
1. Verifica que la historia sea tuya
2. Revisa logs: `adb logcat | grep "propietario"`
3. Compila de nuevo: `flutter clean && flutter run`

### Problema: Crash Subiendo 5 Fotos

**Debugging**:
1. Verifica que no sea por storage lleno
2. Revisa logs: `adb logcat | grep "photo\|Error"`
3. Compila de nuevo

### Problema: Deep Link No Abre App

**Debugging**:
1. Verifica que assetlinks.json esté accesible:
   ```bash
   curl https://biux.devshouse.org/.well-known/assetlinks.json
   ```
2. Revisa que SHA256 sea correcto:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -storepass android
   ```
3. Verifica logs: `adb logcat | grep "deep\|route"`

### Problema: Deep Link Abre App Pero No Navega

**Debugging**:
1. Ver logs: `adb logcat | grep "convertDeepLink\|Guard"`
2. Verificar que esté autenticado (¿requiere login primero?)
3. Probar con URL diferente

---

## ✅ Completado Correctamente Si:

- ✅ Ves el botón 🗑️ en tus historias
- ✅ Puedes eliminar historias con confirmación
- ✅ Subes 5+ fotos sin crash
- ✅ La descripción es opcional
- ✅ Compartir crea links válidos
- ✅ Links abren app en pantalla correcta
- ✅ Si no estás logueado, primero va a login

---

**Fecha**: 25 de Noviembre 2024
**Status**: ✅ Listo para Testing
