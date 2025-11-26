# Configuración Final de Deep Links - BIUX App

## 📋 Resumen de Cambios

Se ha completado la implementación de deep links para permitir que los usuarios compartan enlaces que redirijan directamente a la app en la pantalla correcta.

### Archivos Modificados:

1. **`lib/core/config/router/app_router.dart`** ✅
   - Agregada función `_convertDeepLinkToRoute()` que convierte URLs de dominio personalizado a rutas internas
   - Mejorado guard de autenticación `_guard()` para interceptar y procesar deep links
   - Soporte para dos esquemas de deep links:
     - `biux://` - Esquema de deep link personalizado
     - `https://biux.devshouse.org/` - App links con dominio personalizado

2. **`lib/core/services/deep_link_service.dart`** ✅
   - Mejorado con mejor logging y manejo de errores
   - Agregados métodos generadores de share text para cada tipo de contenido
   - Métodos de análisis de deep links más robustos
   - Soporte para parseadores URI más precisos

---

## 🔗 Esquemas Soportados

### Esquema `biux://` (Deep Links)

```
biux://ride/{rideId}          → Navega a detalles de rodada
biux://group/{groupId}        → Navega a detalles de grupo
biux://user/{userId}          → Navega a perfil del usuario
biux://user-profile/{userId}  → Navega a perfil del usuario
```

### Esquema `https://biux.devshouse.org/` (App Links)

```
https://biux.devshouse.org/ride/{rideId}       → /rides/{rideId}
https://biux.devshouse.org/rides/{rideId}      → /rides/{rideId}
https://biux.devshouse.org/posts/{postId}      → /stories
https://biux.devshouse.org/stories/{storyId}   → /stories
https://biux.devshouse.org/group/{groupId}     → /groups/{groupId}
https://biux.devshouse.org/user/{userId}       → /user-profile/{userId}
```

---

## 🛠️ Cómo Funciona

### Flujo de Procesamiento de Deep Links:

1. **App Launch**: Cuando el usuario abre un link (de WhatsApp, email, etc.), el sistema operativo abre la app con la URI en `state.uri`

2. **Router Guard**: El guard de autenticación `_guard()` intercepta la solicitud

3. **Conversión de Deep Link**: Se ejecuta `_convertDeepLinkToRoute()` que:
   - Parsea la URL/deep link
   - Identifica el tipo (ride, group, user, posts, stories)
   - Convierte a una ruta interna reconocida por GoRouter
   - Retorna la ruta convertida (ej: `/rides/123`)

4. **Validación de Autenticación**: 
   - Si no está autenticado → redirige al login
   - Si está autenticado → redirige a la ruta convertida

5. **Navegación**: GoRouter navega a la ruta final (ej: `/rides/123`)

---

## 📊 Configuración Android (`assetlinks.json`)

**Ubicación**: `/.well-known/assetlinks.json` en tu servidor

**Contenido actual** (⚠️ REQUIERE CONFIGURACIÓN):

```json
[
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
]
```

**Pasos para obtener tu fingerprint SHA256**:

```bash
# Primero, crear/obtener tu keystore de firma
# Para obtener el fingerprint del keystore local de debug:
keytool -list -v -keystore ~/.android/debug.keystore -storepass android -keypass android

# Para obtener el fingerprint del keystore de producción:
keytool -list -v -keystore /ruta/a/tu/keystore.jks -storepass tu_password
```

**Actualizar el fingerprint**:

```bash
# 1. Obtener el SHA256 (saldrá algo como: XX:XX:XX:XX:...)
# 2. Copiar SOLO los caracteres después de "SHA256:" quitando los dos puntos
# 3. Reemplazar en assetlinks.json

# Ejemplo: Si obtienes:
# SHA256: 1A:2B:3C:4D:5E:6F:7G:8H:9I:0J:1K:2L:3M:4N:5O:6P:7Q:8R:9S:0T

# En assetlinks.json pondrías:
"sha256_cert_fingerprints": [
  "1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T"
]
```

**AndroidManifest.xml** (ya debería estar configurado):

Debe tener las intent-filters para biux:// y https://biux.devshouse.org:

```xml
<activity android:name=".MainActivity" android:launchMode="singleTop">
  <!-- Deep link para biux:// -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="biux"
      android:host="ride" />
  </intent-filter>

  <!-- App Links para https://biux.devshouse.org -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="https"
      android:host="biux.devshouse.org"
      android:pathPrefix="/ride" />
  </intent-filter>
</activity>
```

---

## 📲 Configuración iOS (`apple-app-site-association`)

**Ubicación**: `/.well-known/apple-app-site-association` en tu servidor

**Contenido**:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.devshouse.biux",
        "paths": [
          "/ride/*",
          "/rides/*",
          "/group/*",
          "/posts/*",
          "/stories/*",
          "/user/*"
        ]
      }
    ]
  }
}
```

**Nota**: En iOS, también necesitas configurar en `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>biux.devshouse.org</key>
    <dict>
      <key>NSIncludesSubdomains</key>
      <true/>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSTemporaryExceptionRequiresForwardSecrecy</key>
      <false/>
    </dict>
  </dict>
</dict>
```

---

## 🧪 Cómo Probar Deep Links

### 1️⃣ Test Local (en simulador/emulador)

**Android**:
```bash
# Abrir un deep link desde terminal
adb shell am start -a android.intent.action.VIEW -d "biux://ride/123" com.devshouse.biux

# Abrir un app link desde terminal
adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/ride/123" com.devshouse.biux
```

**iOS**:
```bash
# Abrir un deep link desde terminal
xcrun simctl openurl booted "biux://ride/123"

# Abrir un app link desde terminal
xcrun simctl openurl booted "https://biux.devshouse.org/ride/123"
```

### 2️⃣ Test con Compartir (desde la app)

**Compartir una rodada**:

```dart
// En ride_detail_screen.dart o similar
ElevatedButton(
  onPressed: () {
    final shareText = DeepLinkService.generateShareText(
      rideName: ride.name,
      rideId: ride.id,
      groupName: ride.groupName,
    );
    Share.share(shareText);
  },
  child: Text('Compartir'),
)
```

**Compartir una historia**:

```dart
final shareText = DeepLinkService.generateStoryShareText(
  userName: story.user.name,
  storyId: story.id,
);
Share.share(shareText);
```

### 3️⃣ Test WhatsApp

1. Compartir desde la app al chat de WhatsApp
2. Ver el mensaje en WhatsApp
3. Tap en el link
4. Debería abrir la app directamente en la pantalla correcta

**Esperado**:
- ✅ Mensaje con link: "🚴 ¡Únete a la rodada..."
- ✅ Tap en link abre la app
- ✅ Navega a `/rides/123` directamente
- ✅ Si no está logueado: primero login, luego la pantalla

### 4️⃣ Test con Scanning QR

Si tienes QR codes que apunten a tus links:
```
https://biux.devshouse.org/ride/xyz123
```

Escanear con cámara debería:
1. Abrir Safari con el link
2. Safari detecta el app link
3. Redirige a la app BIUX
4. DeepLinkService lo procesa
5. Navega a la pantalla correcta

---

## 🐛 Debugging y Logging

El código tiene logging detallado. En Logcat/Xcode verás:

```
🔗 Intentando convertir deep link: https://biux.devshouse.org/ride/123
🔗 Detectado app link de biux.devshouse.org
🔗 Path: /ride/123, Segments: [, ride, 123]
✅ Ruta convertida: https://biux.devshouse.org/ride/123 → /rides/123
🔍 Router Guard - Location: /rides/123, isLoggedIn: true, uid: user123
✅ Usuario autenticado, permitiendo acceso
```

---

## ✅ Checklist de Implementación

- [x] DeepLinkService mejorado con mejor logging
- [x] app_router.dart con conversión de deep links
- [x] Guard de autenticación intercepta deep links
- [x] Soporte para `biux://` scheme
- [x] Soporte para `https://biux.devshouse.org/` app links
- [x] Redirección correcta después de autenticación
- [ ] Configurar assetlinks.json con fingerprint real
- [ ] Verificar apple-app-site-association en servidor
- [ ] Probar compartir desde app en WhatsApp
- [ ] Probar abrir links en simulador/emulador
- [ ] Publicar en Google Play/App Store

---

## 📝 Notas Importantes

1. **Server Configuration**: Los archivos `assetlinks.json` y `apple-app-site-association` **DEBEN** estar públicamente accesibles en tu servidor:
   - `https://biux.devshouse.org/.well-known/assetlinks.json`
   - `https://biux.devshouse.org/.well-known/apple-app-site-association`

2. **HTTPS Obligatorio**: Los app links SOLO funcionan con HTTPS (excepto localhost en Android)

3. **Fingerprint**: Diferentes keystores = diferentes fingerprints. Configurar el correcto para tu entorno (debug/producción)

4. **Timing**: A veces los navegadores cachean los archivos JSON. Si cambias, espera unos minutos o limpia cache

5. **Verificación**: Para verificar que el archivo está accesible:
   ```bash
   curl https://biux.devshouse.org/.well-known/assetlinks.json
   ```

---

## 🔧 Próximos Pasos

1. **Obtener SHA256 Fingerprint**: Ejecutar `keytool` para tu keystore
2. **Actualizar assetlinks.json**: Reemplazar placeholder con fingerprint real
3. **Publicar archivos**: Asegurar que `.well-known/` esté accesible en servidor
4. **Probar en Simulador**: Usar comandos `adb shell am start` o `xcrun simctl`
5. **Probar en Device Real**: Compartir con WhatsApp y validar
6. **Publicar Build**: Usar el mismo keystore que configuraste en assetlinks.json

---

## 📚 Referencias

- GoRouter Documentation: https://pub.dev/packages/go_router
- Android App Links: https://developer.android.com/training/app-links
- iOS Universal Links: https://developer.apple.com/ios/universal-links/
- Digital Asset Links: https://developers.google.com/digital-asset-links

---

**Status**: ✅ Implementación Completada - Listo para Testing
**Última Actualización**: 25 de Noviembre 2024
