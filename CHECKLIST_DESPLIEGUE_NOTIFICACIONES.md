# ✅ Checklist de Despliegue - Sistema de Notificaciones

## 📋 Estado Actual

### ✅ Frontend Completado

#### **1. NotificationService**
- [x] Inicialización automática en `main.dart`
- [x] Solicitud de permisos (`_requestPermissions()`)
- [x] Obtención y guardado de token FCM (`_saveDeviceToken()`)
- [x] Escucha de actualización de tokens (`onTokenRefresh`)
- [x] **NUEVO**: `reinitializeAfterLogin()` - Se ejecuta después del login
- [x] **NUEVO**: `_ensureNotificationSettings()` - Crea preferencias por defecto
- [x] Manejo de notificaciones en foreground
- [x] Manejo de notificaciones en background
- [x] Manejo de tap en notificaciones
- [x] Guardado de notificaciones en Firestore

**Ubicación**: `lib/shared/services/notification_service.dart`

#### **2. AuthProvider con Notificaciones**
- [x] Importa `NotificationService`
- [x] **NUEVO**: Llama a `reinitializeAfterLogin()` después del login exitoso
- [x] Guarda token FCM automáticamente para usuario autenticado
- [x] Inicializa preferencias de notificación si no existen

**Flujo del Login**:
```dart
1. Usuario ingresa código OTP
2. Se valida con backend
3. Se autentica con Firebase (signInWithCustomToken)
4. ✨ Se ejecuta NotificationService().reinitializeAfterLogin()
   - Guarda token FCM en users/{userId}/fcmTokens
   - Crea preferencias por defecto si no existen
5. Usuario autenticado ✅
```

#### **3. Preferencias de Notificación**
- [x] Entidad `NotificationSettingsEntity` con 10 campos
- [x] Repositorio con Firestore
- [x] Provider con state management
- [x] Pantalla completa con UI
- [x] Ruta configurada en router
- [x] **NUEVO**: Inicialización automática con defaults después del login

#### **4. NotificationListener**
- [x] Widget que envuelve la app
- [x] Escucha stream de notificaciones
- [x] Navegación automática según tipo de notificación

**Ubicación**: `lib/shared/widgets/notification_listener_widget.dart`

#### **5. Estructura de Firestore**

```javascript
users/{userId} {
  fcmTokens: ["token1", "token2"],  // ✅ Se guarda después del login
  lastTokenUpdate: Timestamp,
  
  notificationSettings: {  // ✅ Se crea automáticamente si no existe
    enablePushNotifications: true,
    enableLikes: true,
    enableComments: true,
    enableFollows: true,
    enableRideInvitations: true,
    enableGroupInvitations: true,
    enableStories: true,
    enableRideReminders: true,
    enableGroupUpdates: true,
    enableSystemNotifications: true
  }
}

// También en subcolección para UI
users/{userId}/settings/notifications {
  // Mismos campos que arriba
}

// Notificaciones recibidas
users/{userId}/notifications/{notificationId} {
  title: "Título",
  body: "Mensaje",
  type: "like|comment|follow|...",
  senderId: "user123",
  relatedId: "experience456",
  timestamp: Timestamp,
  read: false
}
```

---

### ✅ Backend Completado

#### **1. Cloud Functions**
- [x] `functions/notifications.js` con 8 triggers
- [x] `isNotificationEnabled()` - Verifica preferencias
- [x] `sendNotificationToUser()` - Envía y guarda notificación
- [x] Limpieza automática de tokens inválidos
- [x] Guardado de notificaciones en Firestore
- [x] Exportados en `index.js`

#### **2. Triggers Implementados**

| Trigger | Colección | Tipo | Descripción |
|---------|-----------|------|-------------|
| `onLikeCreated` | `experiences/{id}/likes/{id}` | onCreate | Like en publicación |
| `onCommentCreated` | `experiences/{id}/comments/{id}` | onCreate | Comentario en publicación |
| `onFollowCreated` | `users/{id}/followers/{id}` | onCreate | Nuevo seguidor |
| `onRideInvitationCreated` | `rides/{id}/invitations/{id}` | onCreate | Invitación a rodada |
| `onGroupInvitationCreated` | `groups/{id}/invitations/{id}` | onCreate | Invitación a grupo |
| `onStoryCreated` | `stories/{id}` | onCreate | Nueva historia (notifica seguidores) |
| `sendRideReminders` | N/A | Scheduled (24h) | Recordatorio de rodadas |
| `onGroupUpdate` | `groups/{id}/posts/{id}` | onCreate | Publicación en grupo |

#### **3. Verificación de Preferencias**

Cada trigger verifica antes de enviar:

```javascript
// En cada función
const enabled = await isNotificationEnabled(recipientId, 'like');
if (!enabled) {
  console.log(`Notification disabled for user: ${recipientId}`);
  return;
}
```

#### **4. Configuración**
- [x] `firebase.json` configurado
- [x] `.firebaserc` con proyecto
- [x] `package.json` con dependencias correctas
- [x] Node.js v22
- [x] Firebase Admin SDK v13.5.0
- [x] Firebase Functions v6.4.0

---

## 🚀 Proceso de Despliegue

### **Paso 1: Verificar Configuración Local**

```powershell
# 1. Verificar que estás en el proyecto correcto
cd biux-cloud
firebase use

# Deberías ver: biux-1576614678644 (default)
```

### **Paso 2: Instalar Dependencias**

```powershell
cd functions
npm install
cd ..
```

### **Paso 3: Verificar Autenticación**

```powershell
firebase login:list

# Si no estás autenticado:
firebase login
```

### **Paso 4: Desplegar con Script**

```powershell
.\deploy.ps1
```

**O manualmente**:

```powershell
firebase deploy --only functions
```

### **Paso 5: Verificar Despliegue**

```powershell
# Ver funciones desplegadas
firebase functions:list

# Ver logs en tiempo real
firebase functions:log --only onLikeCreated
```

### **Paso 6: Habilitar Cloud Scheduler (para sendRideReminders)**

1. Ve a: https://console.firebase.google.com/project/biux-1576614678644/functions
2. Encuentra `sendRideReminders`
3. Si aparece un mensaje para habilitar Cloud Scheduler API, haz clic en "Enable"
4. La función se ejecutará automáticamente cada 24 horas

---

## 🧪 Testing End-to-End

### **Test 1: Verificar Token FCM después del Login**

1. **Borra la app del dispositivo** (instalación fresca)
2. **Instala y abre la app**
3. **Completa el login** con tu número de teléfono
4. **Verifica en Firebase Console**:
   - Ve a: Firestore → users → {tu userId}
   - Deberías ver: `fcmTokens: ["token..."]`
   - Deberías ver: `notificationSettings: {...}`

**Logs esperados**:
```
✅ NotificationService inicializado correctamente
✅ Token FCM guardado: ...
✅ NotificationService reinicializado para usuario: ...
✅ Preferencias de notificación inicializadas
```

### **Test 2: Verificar Preferencias por Defecto**

1. **Después del login**, ve a: Settings → Notifications
2. **Todas las notificaciones deberían estar habilitadas** por defecto
3. **Desactiva "Likes"**
4. **Verifica en Firestore**:
   - users/{userId}/notificationSettings
   - `enableLikes: false`

### **Test 3: Test de Like (Preferencias Habilitadas)**

1. **Usuario A**: Publica una experiencia
2. **Usuario B**: Da like a la publicación
3. **Verificar**:
   - ✅ Usuario A recibe notificación push
   - ✅ Notificación aparece en la app
   - ✅ Se guarda en Firestore: users/{userId}/notifications

**Verificar en logs del backend**:
```bash
firebase functions:log --only onLikeCreated
```

Deberías ver:
```
✅ Notification like enabled for user: {userId}
📧 Sending notification to user: {userId}
✅ Notification sent successfully
```

### **Test 4: Test de Like (Preferencias Deshabilitadas)**

1. **Usuario A**: Va a Settings → Notifications
2. **Desactiva "Me gusta"**
3. **Usuario B**: Da like a una publicación de Usuario A
4. **Verificar**:
   - ❌ Usuario A NO recibe notificación
   - ❌ No se guarda en Firestore

**Verificar en logs**:
```
⚠️ Notification like disabled for user: {userId}
```

### **Test 5: Test de Comentario**

1. **Usuario A**: Publica experiencia
2. **Usuario B**: Comenta en la publicación
3. **Usuario A**: Recibe notificación con preview del comentario

**Estructura esperada en Firestore**:
```javascript
experiences/{experienceId}/comments/{commentId} {
  userId: "userB_id",
  text: "¡Qué genial!",
  createdAt: Timestamp,
  experienceOwnerId: "userA_id"  // ← Debe existir
}
```

### **Test 6: Test de Seguidor**

1. **Usuario B**: Sigue a Usuario A
2. **Usuario A**: Recibe notificación "Usuario B comenzó a seguirte"

**Estructura esperada**:
```javascript
users/{userA_id}/followers/{userB_id} {
  followerId: "userB_id",
  followerName: "Usuario B",
  followedAt: Timestamp
}
```

### **Test 7: Test de Invitación a Rodada**

1. **Usuario A**: Crea rodada
2. **Usuario A**: Invita a Usuario B
3. **Usuario B**: Recibe notificación con título de la rodada

**Estructura esperada**:
```javascript
rides/{rideId}/invitations/{invitationId} {
  inviterId: "userA_id",
  inviterName: "Usuario A",
  invitedUserId: "userB_id",
  rideTitle: "Rodada al cerro",
  createdAt: Timestamp
}
```

### **Test 8: Test de Historia (Notifica Seguidores)**

1. **Usuario A**: Publica historia
2. **Todos los seguidores de Usuario A**: Reciben notificación

**Estructura esperada**:
```javascript
stories/{storyId} {
  userId: "userA_id",
  username: "Usuario A",
  createdAt: Timestamp
}

users/{userA_id}/followers/ {
  // Lista de seguidores que recibirán la notificación
}
```

### **Test 9: Test de Token Inválido**

1. **Desinstala la app** de un dispositivo (token queda inválido)
2. **Otro usuario** le envía una notificación
3. **Backend detecta token inválido** y lo elimina automáticamente

**Logs esperados**:
```
⚠️ Invalid FCM token, removing: {token}
```

### **Test 10: Test de Recordatorio de Rodada (Scheduled)**

**Nota**: Esta función se ejecuta cada 24 horas automáticamente

1. **Crea rodada** para mañana (startDate = tomorrow)
2. **Espera 24 horas** (o prueba manualmente desde Firebase Console)
3. **Usuarios invitados reciben recordatorio**: "La rodada X es mañana"

**Probar manualmente**:
```bash
# Desde Firebase Console → Functions → sendRideReminders → Test
```

---

## 📊 Monitoreo Post-Despliegue

### **Firebase Console**

1. **Functions**: https://console.firebase.google.com/project/biux-1576614678644/functions
   - Ver funciones activas
   - Ver logs en tiempo real
   - Ver métricas (invocaciones, errores, tiempo de ejecución)

2. **Firestore**: https://console.firebase.google.com/project/biux-1576614678644/firestore
   - Verificar que se guardan las notificaciones
   - Verificar tokens FCM en users
   - Verificar preferencias de usuarios

3. **Cloud Messaging**: https://console.firebase.google.com/project/biux-1576614678644/notification
   - Ver notificaciones enviadas
   - Ver tasa de entrega

### **Comandos Útiles**

```powershell
# Ver logs en tiempo real de todas las funciones
firebase functions:log

# Ver logs de función específica
firebase functions:log --only onLikeCreated

# Ver logs con filtro de tiempo
firebase functions:log --since 1h

# Ver solo errores
firebase functions:log --only onCommentCreated | Select-String "error"

# Desplegar solo una función específica
firebase deploy --only functions:onLikeCreated

# Ver estado de las funciones
firebase functions:list
```

---

## ⚠️ Troubleshooting

### **Problema 1: Usuario no recibe notificación después del login**

**Diagnóstico**:
```powershell
# Verificar en Firestore
# users/{userId} debe tener:
# - fcmTokens: [...]
# - notificationSettings: {...}
```

**Solución**:
- Verifica que `NotificationService().reinitializeAfterLogin()` se ejecuta
- Revisa logs de la app: `✅ Token FCM guardado: ...`
- Verifica permisos de notificación en configuración del dispositivo

### **Problema 2: Cloud Function no se ejecuta**

**Diagnóstico**:
```powershell
firebase functions:log --only onLikeCreated
```

**Solución**:
- Verifica que la función está desplegada: `firebase functions:list`
- Verifica que el trigger coincide con la ruta de Firestore
- Revisa logs para ver errores específicos

### **Problema 3: Preferencias no se respetan**

**Diagnóstico**:
- Verifica en Firestore: `users/{userId}/notificationSettings`
- Debe tener todos los campos (10 total)

**Solución**:
- Borra el campo `notificationSettings` del usuario
- Cierra sesión y vuelve a iniciar
- Se crearán automáticamente con defaults

### **Problema 4: Token FCM no se guarda**

**Diagnóstico**:
```dart
// En la app, después del login
final token = await NotificationService().getToken();
print('Token: $token');
```

**Solución**:
- Verifica permisos en AndroidManifest.xml
- Verifica google-services.json
- Verifica que Firebase está inicializado

### **Problema 5: sendRideReminders no se ejecuta**

**Diagnóstico**:
- Ve a Firebase Console → Functions
- Busca `sendRideReminders`

**Solución**:
- Habilita Cloud Scheduler API
- Verifica que la función tiene schedule configurado
- Prueba manualmente desde Firebase Console

---

## 📝 Checklist Final Pre-Producción

### **Frontend**
- [ ] NotificationService se inicializa en main.dart ✅
- [ ] Token FCM se guarda después del login ✅
- [ ] Preferencias se crean automáticamente ✅
- [ ] NotificationListener funciona correctamente ✅
- [ ] Navegación desde notificaciones funciona ✅
- [ ] Pantalla de settings accesible desde la app ⚠️ (falta agregar en menú)

### **Backend**
- [ ] Funciones desplegadas exitosamente
- [ ] Logs sin errores
- [ ] Cloud Scheduler habilitado (para reminders)
- [ ] Tokens inválidos se limpian automáticamente

### **Testing**
- [ ] Test 1: Token después del login ✅
- [ ] Test 2: Preferencias por defecto ✅
- [ ] Test 3: Like con preferencias habilitadas
- [ ] Test 4: Like con preferencias deshabilitadas
- [ ] Test 5: Comentario
- [ ] Test 6: Seguidor
- [ ] Test 7: Invitación a rodada
- [ ] Test 8: Historia (múltiples seguidores)
- [ ] Test 9: Token inválido
- [ ] Test 10: Recordatorio de rodada

### **UI/UX**
- [ ] Agregar botón en perfil/settings para acceder a NotificationSettingsScreen
- [ ] Badge en icono de notificaciones (contador de no leídas)
- [ ] Pantalla de historial de notificaciones

---

## 🎯 Próximos Pasos Después del Despliegue

1. **Desplegar Cloud Functions**:
   ```powershell
   cd biux-cloud
   .\deploy.ps1
   ```

2. **Probar en dispositivo real** con instalación fresca

3. **Agregar navegación** a NotificationSettingsScreen desde el menú principal

4. **Implementar historial de notificaciones**:
   - Pantalla para ver todas las notificaciones recibidas
   - Marcar como leídas
   - Eliminar notificaciones

5. **Analytics**:
   - Trackear cuántas notificaciones se envían
   - Trackear tasa de apertura
   - Trackear cuáles tipos son más populares

6. **Optimizaciones**:
   - Rate limiting (evitar spam)
   - Agrupar notificaciones del mismo tipo
   - Notificaciones ricas con imágenes

---

**Estado**: ✅ Sistema completo y listo para desplegar  
**Última actualización**: 22 de octubre de 2025  
**Próxima acción**: Ejecutar `.\deploy.ps1` en `biux-cloud/`
