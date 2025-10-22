# Configuración de Deep Links con Dominio Personalizado

## Resumen
Se ha configurado el dominio personalizado `biux.devshouse.org` para todos los deep links de la aplicación Biux.

## 🎯 Funcionalidad
Cuando un usuario comparte un link como `https://biux.devshouse.org/posts/{id}`:
- **Si la app está instalada**: Se abre directamente en la aplicación
- **Si NO está instalada**: Se abre en el navegador (donde puedes mostrar landing page o redirect a stores)

## 📱 Rutas Soportadas

### Deep Links (biux://)
- `biux://ride/{id}` → Abre rodada específica
- `biux://posts/{id}` → Abre publicación específica
- `biux://group/{id}` → Abre grupo específico
- `biux://user/{id}` → Abre perfil de usuario

### Universal Links (https://)
- `https://biux.devshouse.org/ride/{id}`
- `https://biux.devshouse.org/posts/{id}`
- `https://biux.devshouse.org/group/{id}`
- `https://biux.devshouse.org/user/{id}`

## ✅ Cambios Realizados

### 1. Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Deep Links (biux://) -->
<intent-filter>
    <data android:scheme="biux" android:host="ride"/>
    <data android:scheme="biux" android:host="posts"/>
    <data android:scheme="biux" android:host="group"/>
    <data android:scheme="biux" android:host="user"/>
</intent-filter>

<!-- App Links (HTTPS) -->
<intent-filter android:autoVerify="true">
    <data android:scheme="https" android:host="biux.devshouse.org"/>
</intent-filter>
```

### 2. iOS (`ios/Runner/Runner.entitlements`)
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:biux.devshouse.org</string>
</array>
```

### 3. Servicio de Deep Links (`lib/core/services/deep_link_service.dart`)
- ✅ `generateRideAppLink()` → usa biux.devshouse.org
- ✅ `generatePostAppLink()` → usa biux.devshouse.org
- ✅ `handleDeepLink()` → reconoce biux.devshouse.org
- ✅ Todas las rutas configuradas

## 🚀 Pasos Pendientes para Producción

### 1. Obtener SHA-256 Fingerprint (Android)

#### Para Debug:
```bash
cd android
./gradlew signingReport
```

#### Para Release:
```bash
keytool -list -v -keystore path/to/your/keystore.jks -alias your-key-alias
```

Busca la línea `SHA256:` y copia el valor.

### 2. Actualizar `assetlinks.json`
Reemplaza `REPLACE_WITH_YOUR_SHA256_FINGERPRINT` con tu SHA-256 real (con dos puntos).

Ejemplo:
```json
"sha256_cert_fingerprints": [
  "14:6D:E9:83:C5:73:06:50:D8:EE:B9:95:2F:34:FC:64:16:A0:83:42:E6:1D:BE:A8:8A:04:96:B2:3F:CF:44:E5"
]
```

### 3. Obtener Team ID (iOS)
1. Ve a [Apple Developer Portal](https://developer.apple.com/account)
2. En "Membership" encontrarás tu **Team ID**
3. Actualiza `apple-app-site-association`:
   ```json
   "appID": "TU_TEAM_ID.com.ibacrea.biux"
   ```

### 4. Subir Archivos al Servidor Web
Debes colocar estos archivos en tu servidor `biux.devshouse.org`:

#### Android:
```
https://biux.devshouse.org/.well-known/assetlinks.json
```

#### iOS:
```
https://biux.devshouse.org/.well-known/apple-app-site-association
https://biux.devshouse.org/apple-app-site-association
```

**Importante:**
- Sin extensión `.json` para el archivo de Apple
- Content-Type: `application/json`
- Accesible por HTTPS (SSL requerido)
- Sin redirects

### 5. Configurar Xcode (iOS)
1. Abre el proyecto en Xcode: `ios/Runner.xcworkspace`
2. Selecciona el target "Runner"
3. Ve a "Signing & Capabilities"
4. Agrega "Associated Domains" si no está
5. El archivo `Runner.entitlements` debe aparecer automáticamente

### 6. Verificar Configuración

#### Android:
```bash
# Verificar que el archivo sea accesible
curl https://biux.devshouse.org/.well-known/assetlinks.json
```

#### iOS:
```bash
# Verificar ambas ubicaciones
curl https://biux.devshouse.org/.well-known/apple-app-site-association
curl https://biux.devshouse.org/apple-app-site-association
```

### 7. Probar Deep Links

#### Desde Terminal (Android):
```bash
# Probar con ADB
adb shell am start -a android.intent.action.VIEW -d "https://biux.devshouse.org/posts/123" com.ibacrea.biux
```

#### Desde Safari (iOS):
1. Abre Safari en el simulador/dispositivo
2. Navega a: `https://biux.devshouse.org/posts/123`
3. Debe preguntar si abrir en la app

## 📝 Validación de Links en Producción

### Android:
- Google tarda ~24 horas en verificar los App Links
- Usa [App Links Assistant](https://developer.android.com/studio/write/app-link-indexing) en Android Studio

### iOS:
- Apple verifica los links al instalar la app
- Usa [Apple's validator](https://search.developer.apple.com/appsearch-validation-tool/)

## 🔧 Troubleshooting

### "Los links no abren la app"
1. Verifica que los archivos estén en el servidor
2. Verifica que sean accesibles por HTTPS
3. En Android, limpia la caché: Settings > Apps > Biux > Open by default > Clear defaults
4. En iOS, reinstala la app

### "Error de verificación en Android"
- Verifica el SHA-256 fingerprint
- Asegúrate de tener `android:autoVerify="true"`
- Verifica que el package name sea correcto

### "No funciona en iOS"
- Verifica el Team ID
- Asegúrate de tener el entitlement configurado
- El dominio debe tener SSL válido

## 📚 Referencias
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)
