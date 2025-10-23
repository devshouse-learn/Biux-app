# Guía: Configurar APNs para Notificaciones Push en iOS

## Paso 1: Generar APNs Authentication Key en Apple Developer

1. **Ir a Apple Developer Console:**
   - Abre: https://developer.apple.com/account/resources/authkeys/list
   - Inicia sesión con tu cuenta de Apple Developer

2. **Crear nueva Key:**
   - Click en el botón **"+"** (Create a key)
   - Dale un nombre: `Biux Push Notifications Key`
   - Marca la casilla: **☑️ Apple Push Notifications service (APNs)**
   - Click en **"Continue"**
   - Click en **"Register"**

3. **Descargar la Key:**
   - ⚠️ **IMPORTANTE**: Solo puedes descargar esta key UNA VEZ
   - Click en **"Download"**
   - Se descargará un archivo: `AuthKey_XXXXXXXXXX.p8`
   - **GUARDA ESTE ARCHIVO EN LUGAR SEGURO**
   - Anota estos valores que aparecen en la página:
     - **Key ID**: Un código de 10 caracteres (ej: `A1B2C3D4E5`)
     - **Team ID**: Tu ID de equipo (aparece arriba en la página)

## Paso 2: Subir APNs Key a Firebase Console

1. **Ir a Firebase Console:**
   - Abre: https://console.firebase.google.com/project/biux-1576614678644/settings/cloudmessaging
   - O navega: Project Settings → Cloud Messaging → Apple app configuration

2. **Subir la Key:**
   - En la sección **"APNs authentication key"**
   - Click en **"Upload"**
   - Selecciona el archivo `AuthKey_XXXXXXXXXX.p8` que descargaste
   - Ingresa:
     - **Key ID**: El código de 10 caracteres que anotaste
     - **Team ID**: Tu Team ID que anotaste
   - Click en **"Upload"**

## Paso 3: Habilitar Capabilities en Xcode

### Abrir el proyecto:
```bash
cd ios
open Runner.xcworkspace
```

### Habilitar Push Notifications:
1. En Xcode, selecciona el target **"Runner"** en el navegador izquierdo
2. Ve a la pestaña **"Signing & Capabilities"**
3. Click en **"+ Capability"** (arriba a la izquierda)
4. Busca y selecciona **"Push Notifications"**
5. Se agregará automáticamente la capability

### Habilitar Background Modes:
1. En la misma pestaña "Signing & Capabilities"
2. Click en **"+ Capability"** nuevamente
3. Busca y selecciona **"Background Modes"**
4. Marca las siguientes casillas:
   - ☑️ **Remote notifications**
   - ☑️ **Background fetch**

### Guardar cambios:
1. **Cmd + S** para guardar
2. Cierra Xcode
3. Los cambios se guardarán en `ios/Runner/Runner.entitlements`

## Paso 4: Verificar Bundle ID

1. En Xcode, verifica que el **Bundle Identifier** sea:
   ```
   com.ibacrea.biux
   ```

2. Este debe coincidir con:
   - El Bundle ID en Apple Developer Console
   - El Bundle ID en Firebase Console

## Paso 5: Probar las notificaciones

Después de hacer los pasos anteriores:

1. **Compilar y ejecutar en dispositivo físico:**
   ```bash
   flutter run --release
   ```
   ⚠️ Las notificaciones push NO funcionan en simulador

2. **Dar un like o comentar** para generar una notificación

3. **Verificar los logs de Cloud Functions:**
   ```bash
   firebase functions:log --only onPushNotificationCreated
   ```

## Troubleshooting

### ❌ Error: "APNs device token not set"
- Asegúrate de estar probando en dispositivo físico (no simulador)
- Verifica que el app tenga permisos de notificaciones

### ❌ Error: "Invalid APNs certificate"
- Verifica que el APNs Key no haya expirado
- Confirma que el Team ID y Key ID sean correctos

### ❌ No recibo notificaciones
1. Verifica que el FCM token se guarde correctamente en Firestore
2. Revisa los logs de Cloud Functions para errores
3. Asegura que el Bundle ID coincida en todos lados

## Notas Importantes

- ⚠️ El archivo `.p8` de APNs **SOLO SE PUEDE DESCARGAR UNA VEZ**
- ⚠️ Guarda el archivo en un lugar seguro (ej: 1Password, LastPass)
- ⚠️ Las notificaciones push NO funcionan en simulador iOS
- ⚠️ Necesitas un dispositivo físico iOS para probar
- ⚠️ El app debe estar firmado con el perfil correcto

## Referencias

- [Firebase Cloud Messaging iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Apple Push Notifications](https://developer.apple.com/documentation/usernotifications)
- [APNs Key vs Certificate](https://firebase.google.com/docs/cloud-messaging/ios/certs)
