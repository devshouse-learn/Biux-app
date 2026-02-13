# 📱 Guía: Habilitar Firebase Phone Authentication (MANUAL)

## ⚠️ IMPORTANTE
**Copilot NO tiene acceso a Firebase Console.** Debes hacer esto manualmente en tu navegador.

---

## 🔥 PASO A PASO (5 minutos)

### 1️⃣ **Abrir Firebase Console**

Abre en tu navegador:
```
https://console.firebase.google.com/project/biux-1576614678644/authentication/providers
```

O navega manualmente:
1. Ve a https://console.firebase.google.com
2. Selecciona el proyecto **biux-1576614678644**
3. Click en **Authentication** (en el menú lateral izquierdo)
4. Click en **Sign-in method** (pestaña superior)

---

### 2️⃣ **Encontrar "Phone"**

En la lista de proveedores de autenticación, busca:

```
✉️ Email/Password
🔒 Phone            ← ESTE
🌐 Google
📘 Facebook
🍎 Apple
...
```

---

### 3️⃣ **Habilitar Phone Authentication**

1. **Click** en la fila "Phone"
2. Verás un modal/pantalla que dice:
   ```
   Phone
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   ⚪ Disabled
   🟢 Enabled  ← Seleccionar ESTE
   
   Test phone numbers (optional)
   ┌─────────────────────────────┐
   │ Phone number  │ SMS code    │
   └─────────────────────────────┘
   [+ Add phone number]
   ```

3. **Habilita** el toggle/switch para activarlo (de ⚪ a 🟢)

4. **Click en "Save"** (botón azul en la parte inferior)

---

### 4️⃣ **Verificar que quedó habilitado**

Regresa a la lista de proveedores. Ahora deberías ver:

```
Provider          Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phone             🟢 Enabled  ← ✅ LISTO
```

---

## ✅ **¡ESO ES TODO!**

Firebase Phone Authentication ahora está habilitado. La app puede:
- ✅ Enviar códigos SMS automáticamente
- ✅ Verificar números de teléfono
- ✅ Autenticar usuarios

---

## 🧪 **OPCIONAL: Agregar Número de Prueba (Testing)**

Si quieres probar sin enviar SMS reales:

1. En la pantalla de Phone settings
2. Scroll hasta **"Phone numbers for testing"**
3. Click **"Add phone number"**
4. Agrega:
   - **Phone number**: `+57 123 456 7890`
   - **SMS code**: `123456`
5. Click **"Add"**

Ahora cuando uses `+57 123 456 7890` en la app, NO se enviará SMS real. El código siempre será `123456`.

---

## 📊 **Después de Habilitar**

### ¿Qué Cambia?

**ANTES (Phone Auth Disabled):**
```
App → Firebase.verifyPhoneNumber() → ❌ ERROR
"Phone authentication is not enabled for this project"
```

**DESPUÉS (Phone Auth Enabled):**
```
App → Firebase.verifyPhoneNumber() → ✅ SMS ENVIADO
Usuario recibe: "Tu código es 123456"
App → validateCode("123456") → ✅ AUTENTICADO
```

---

## 🔧 **Comandos para Verificar** (Opcional)

Si quieres verificar que la app está lista, ejecuta:

```bash
cd /Users/macmini/biux
./scripts/verify_firebase_phone_auth.sh
```

---

## 🚨 **Si Tienes Problemas**

### Error: "Session Expired"
- **Causa**: iOS Simulator sin APNs configurado
- **Solución**: Usa número de prueba (ver arriba) O configura APNs para dispositivo físico

### Error: "Invalid Phone Number"
- **Causa**: Formato incorrecto
- **Solución**: Asegurar formato E.164: `+573001234567`

### Error: "Too Many Requests"
- **Causa**: Demasiados intentos
- **Solución**: Esperar 1 hora O usar número de prueba

---

## 📱 **Prueba en la App**

Después de habilitar:

1. **Abre** la app en el simulador (ya está compilándose)
2. **Ingresa** un número: `3001234567`
3. **Click** "Enviar código"
4. **Verifica** que:
   - ✅ No hay errores
   - ✅ Pantalla cambia a ingresar código
   - ✅ (Si usas número real) Recibes SMS

---

## 🔗 **Enlaces Útiles**

- **Firebase Console**: https://console.firebase.google.com/project/biux-1576614678644
- **Phone Auth Docs**: https://firebase.google.com/docs/auth/ios/phone-auth
- **Troubleshooting**: Ver `FIREBASE_PHONE_AUTH_SETUP.md`

---

## 📸 **Captura de Pantalla Esperada**

Después de habilitar, verás esto en Firebase Console:

```
╔══════════════════════════════════════════╗
║  Sign-in method                          ║
╠══════════════════════════════════════════╣
║  Provider          Status                ║
║  ────────────────────────────────────    ║
║  📧 Email/Password  Enabled              ║
║  📱 Phone           Enabled ← ✅         ║
║  🌐 Google          Disabled             ║
║  📘 Facebook        Disabled             ║
║  🍎 Apple           Disabled             ║
╚══════════════════════════════════════════╝
```

---

**Tiempo estimado: ⏱️ 2-3 minutos**

¡Avísame cuando lo hayas habilitado para continuar con las pruebas! 🚀
