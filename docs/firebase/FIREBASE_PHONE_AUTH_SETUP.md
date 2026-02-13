# 🔥 Configuración de Firebase Phone Authentication

## 📋 Proyecto Firebase
- **Project ID**: `biux-1576614678644`
- **Console**: https://console.firebase.google.com/project/biux-1576614678644

---

## ✅ PASO 1: Habilitar Phone Authentication en Firebase Console

### 🌐 Accede a Firebase Console:
```
https://console.firebase.google.com/project/biux-1576614678644/authentication/providers
```

### 📱 Configuración:
1. Ve a **Authentication** → **Sign-in method**
2. Encuentra **Phone** en la lista de proveedores
3. Click en **Phone**
4. Habilita el toggle **Enable**
5. Click en **Save**

✅ **LISTO** - Firebase Phone Auth habilitado

---

## ✅ PASO 2: Configurar APNs para iOS (Notificaciones Push)

### 🍎 Por qué es necesario:
Firebase usa Silent Push Notifications para verificar que el dispositivo es legítimo durante Phone Auth en iOS.

### 📝 Opciones de Configuración:

#### **Opción A: APNs Authentication Key (Recomendado)**
1. Ve a **Apple Developer** → **Certificates, Identifiers & Profiles**
2. Click en **Keys** → **+** (Create a new key)
3. Nombre: "Biux APNs Key"
4. Marca: ✅ **Apple Push Notifications service (APNs)**
5. Click **Continue** → **Register**
6. **DESCARGA** el archivo `.p8` (solo se puede descargar una vez)
7. Anota el **Key ID** (ejemplo: `ABC123DEF4`)
8. Anota tu **Team ID** (esquina superior derecha de Apple Developer)

**En Firebase Console:**
```
https://console.firebase.google.com/project/biux-1576614678644/settings/cloudmessaging/ios:2f33fcae8fbaeb5f6dc464
```
1. Click en **Upload APNs Authentication Key**
2. Sube el archivo `.p8`
3. Ingresa **Key ID**
4. Ingresa **Team ID**
5. Click **Upload**

#### **Opción B: APNs Certificate (Legacy)**
Si prefieres usar certificados:
1. Ve a **Apple Developer** → **Certificates**
2. Crea un **Apple Push Notification service SSL Certificate**
3. Descarga el `.p12`
4. Súbelo a Firebase Console

---

## ✅ PASO 3: Configurar reCAPTCHA para Web (OPCIONAL - solo si usas web)

### 🌐 Solo necesario si:
- Usas la versión web de Biux
- Quieres habilitar Phone Auth en navegadores

### 📝 Configuración:
```
https://console.firebase.google.com/project/biux-1576614678644/authentication/settings
```
1. Ve a **Authentication** → **Settings**
2. Scroll hasta **App verification**
3. Agrega tu dominio (ejemplo: `biux.app`, `localhost`)
4. Firebase genera automáticamente reCAPTCHA site key

---

## 🧪 TESTING EN DESARROLLO (Sin APNs)

### ⚠️ Importante:
Para testing en **iOS Simulator** SIN APNs configurado, Firebase puede fallar silenciosamente.

### 🔧 Solución para Testing:
Agrega números de prueba en Firebase Console:

```
https://console.firebase.google.com/project/biux-1576614678644/authentication/providers
```

1. Click en **Phone** → **Phone numbers for testing**
2. Agrega:
   - **Phone Number**: `+57 123 456 7890`
   - **Verification Code**: `123456`
3. Usa este número para testing sin SMS real

---

## 📲 VERIFICAR QUE TODO FUNCIONA

### ✅ Checklist:
- [ ] Phone Authentication habilitado en Firebase Console
- [ ] APNs Key/Certificate subido (para producción iOS)
- [ ] reCAPTCHA configurado (si usas web)
- [ ] Número de prueba agregado (para testing)

### 🧪 Prueba:
```bash
# Compilar y ejecutar
flutter run -d 8A60CA7F-41E8-484E-9E52-F0F06788A4B7
```

### 📊 Logs esperados:
```
✅ [NativePhoneAuth] Verificando número: +573001234567
✅ [Firebase] SMS enviado - Verification ID: xxxxx
✅ [NativePhoneAuth] Código recibido por usuario
✅ [Firebase] Sign-in exitoso
```

---

## 🔥 CONFIGURACIÓN ACTUAL DEL CÓDIGO

### ✅ Ya implementado:
- ✅ `NativePhoneAuthProvider` - Firebase Phone Auth nativo
- ✅ `native_login_phone.dart` - UI de login
- ✅ Provider registrado en `main.dart`
- ✅ Ruta configurada en `app_router.dart`
- ✅ Auto-navegación después de login
- ✅ Sistema de permisos (admin: phone_573132332038)

### 🔧 Código clave:
```dart
// lib/features/authentication/presentation/providers/native_phone_auth_provider.dart
await _auth.verifyPhoneNumber(
  phoneNumber: phoneNumber, // +573001234567
  verificationCompleted: (credential) => signInWithCredential(),
  verificationFailed: (e) => handleError(e),
  codeSent: (verificationId, resendToken) => saveVerificationId(),
  codeAutoRetrievalTimeout: (verificationId) => timeout(),
);
```

---

## ⚠️ ERRORES COMUNES Y SOLUCIONES

### 1. "Session Expired" (iOS Simulator sin APNs)
**Causa**: Firebase no puede enviar Silent Push
**Solución**: Usar número de prueba O configurar APNs

### 2. "Invalid Phone Number"
**Causa**: Formato incorrecto
**Solución**: Asegurar formato E.164: `+573001234567`

### 3. "Too Many Requests"
**Causa**: Demasiados intentos de verificación
**Solución**: Esperar 1 hora O usar número de prueba

### 4. "Missing APNs Token"
**Causa**: No hay APNs configurado (producción iOS)
**Solución**: Subir APNs key/certificate a Firebase

---

## 🚀 DEPLOYMENT A PRODUCCIÓN

### iOS:
1. ✅ APNs Key/Certificate configurado
2. ✅ Bundle ID correcto: `com.example.biux2`
3. ✅ GoogleService-Info.plist actualizado
4. Build → Archive → Upload to TestFlight

### Android:
1. ✅ SHA-1/SHA-256 fingerprints en Firebase
2. ✅ google-services.json actualizado
3. Build → Generate Signed APK

### Web:
1. ✅ reCAPTCHA configurado
2. ✅ Dominios autorizados agregados
3. Deploy → Hosting

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisa Firebase Console → Authentication → Users (ver intentos)
2. Revisa logs de Flutter: `flutter logs`
3. Verifica Firebase Console → Authentication → Sign-in method → Phone (enabled)

**Proyecto Firebase**: https://console.firebase.google.com/project/biux-1576614678644
