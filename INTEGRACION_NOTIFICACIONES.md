# 🔗 Integración Frontend-Backend: Sistema de Notificaciones

## 📋 Resumen del Sistema Completo

Este documento explica cómo el frontend (Flutter) y el backend (Cloud Functions) trabajan juntos para proporcionar notificaciones push personalizables.

---

## 🎯 Flujo Completo de Notificaciones

### 1. **Configuración Inicial (App Flutter)**

```dart
// Al iniciar la app (main.dart)
await NotificationService().initialize();
```

**Acciones**:
- ✅ Solicita permisos de notificaciones
- ✅ Obtiene token FCM del dispositivo
- ✅ Guarda token en Firestore: `users/{userId}/fcmTokens`
- ✅ Configura handlers de notificaciones

---

### 2. **Usuario Configura Preferencias (Flutter)**

**Pantalla**: `NotificationSettingsScreen`

```dart
// Usuario desactiva notificaciones de likes
await provider.toggleLikes(false);
```

**Acciones**:
- ✅ Actualiza Firestore: `users/{userId}/notificationSettings`
- ✅ También en: `users/{userId}` → `notificationSettings` (para acceso rápido del backend)

**Estructura guardada**:
```javascript
users/{userId}/notificationSettings {
  enablePushNotifications: true,
  enableLikes: false,        // ← Usuario desactivó
  enableComments: true,
  enableFollows: true,
  // ... resto
}
```

---

### 3. **Evento Ocurre en la App (Flutter)**

**Ejemplo**: Usuario da like a una publicación

```dart
// En algún lugar de la app
await likesRepository.addLike(experienceId, userId);
```

**Acción**:
- ✅ Crea documento en Firestore:
```javascript
experiences/{experienceId}/likes/{likeId} {
  userId: "user123",
  timestamp: Timestamp.now()
}
```

---

### 4. **Cloud Function se Activa Automáticamente (Backend)**

**Trigger**: `onLikeCreated`

```javascript
// functions/notifications.js
exports.onLikeCreated = functions.firestore
  .document("experiences/{experienceId}/likes/{likeId}")
  .onCreate(async (snap, context) => {
    // ... lógica
  });
```

**Proceso**:
1. ✅ Detecta nuevo documento en `likes`
2. ✅ Obtiene dueño de la experiencia
3. ✅ **Verifica preferencias**: `isNotificationEnabled(userId, "like")`
4. ✅ Lee `users/{userId}/notificationSettings.enableLikes`
5. ✅ Si está habilitado:
   - Obtiene tokens FCM
   - Guarda notificación en Firestore
   - Envía mensaje FCM
6. ✅ Si está deshabilitado: No hace nada

---

### 5. **Notificación Llega al Dispositivo (Flutter)**

**Sistema Operativo** → **Flutter Local Notifications** → **NotificationService**

**Casos**:

#### **A) App en Foreground (abierta)**
```dart
// NotificationService._handleForegroundMessage()
1. Guarda en Firestore
2. Muestra notificación local
3. Emite evento en stream
```

#### **B) App en Background (minimizada)**
```dart
// firebaseMessagingBackgroundHandler()
1. Firebase muestra notificación del sistema
2. Usuario toca → App abre
```

#### **C) App Cerrada (terminated)**
```dart
1. Firebase muestra notificación
2. Usuario toca → App abre con datos
3. NotificationListener navega automáticamente
```

---

### 6. **Usuario Interactúa con Notificación (Flutter)**

**Widget**: `BiuxNotificationListener`

```dart
// Envuelve toda la app
BiuxNotificationListener(
  child: MaterialApp.router(...)
)
```

**Proceso**:
1. ✅ Escucha stream de NotificationService
2. ✅ Lee `type` de la notificación
3. ✅ Navega a la pantalla correcta:

```dart
switch (type) {
  case 'like':
  case 'comment':
    context.push('/experiences/$relatedId');
    break;
  case 'follow':
    context.push('/users/$senderId');
    break;
  // ... resto
}
```

---

## 🔄 Diagrama de Flujo Completo

```
┌─────────────────────────────────────────────────────────────┐
│                    USUARIO EN LA APP                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ├─→ Configura Preferencias
                       │   └─→ Guarda en Firestore
                       │
                       └─→ Da Like a Publicación
                           └─→ Crea documento en Firestore
                                     ↓
┌─────────────────────────────────────────────────────────────┐
│                   CLOUD FUNCTION (Backend)                   │
│  ┌────────────────────────────────────────────────────┐     │
│  │ 1. Trigger detecta nuevo documento                 │     │
│  │ 2. Lee dueño de la publicación                     │     │
│  │ 3. ✓ Verifica preferencias del usuario             │     │
│  │ 4. Si habilitado:                                  │     │
│  │    - Obtiene tokens FCM                            │     │
│  │    - Guarda notificación en Firestore              │     │
│  │    - Envía mensaje FCM                             │     │
│  └────────────────────────────────────────────────────┘     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ├─→ FCM envía a dispositivo
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│              DISPOSITIVO RECEPTOR (Flutter)                  │
│  ┌────────────────────────────────────────────────────┐     │
│  │ NotificationService recibe mensaje                 │     │
│  │ └─→ Muestra notificación local (si foreground)     │     │
│  │ └─→ Guarda en Firestore                            │     │
│  │ └─→ Emite evento en stream                         │     │
│  └────────────────────────────────────────────────────┘     │
│  ┌────────────────────────────────────────────────────┐     │
│  │ Usuario toca notificación                          │     │
│  │ └─→ BiuxNotificationListener                       │     │
│  │     └─→ Navega a pantalla correcta                 │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Estructura de Datos en Firestore

### Usuario con Configuración Completa

```javascript
users/{userId} {
  username: "juan_ciclista",
  email: "juan@example.com",
  
  // Tokens FCM (guardados por Flutter)
  fcmTokens: [
    "token_dispositivo_1",
    "token_dispositivo_2"
  ],
  
  // Preferencias (guardadas por Flutter)
  notificationSettings: {
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
```

### Notificaciones Recibidas

```javascript
users/{userId}/notifications/{notificationId} {
  title: "Nuevo like",
  body: "A María le gustó tu publicación",
  type: "like",
  senderId: "user456",
  relatedId: "experience789",
  timestamp: Timestamp(2025, 10, 22),
  read: false
}
```

---

## 🔐 Verificación de Preferencias

### Backend (Cloud Functions)

```javascript
// functions/notifications.js
async function isNotificationEnabled(userId, notificationType) {
  // 1. Lee documento de usuario
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
  
  // 2. Obtiene configuración
  const settings = userDoc.data().notificationSettings || {};
  
  // 3. Verifica master switch
  if (settings.enablePushNotifications === false) {
    return false;
  }
  
  // 4. Verifica tipo específico
  switch (notificationType) {
    case 'like':
      return settings.enableLikes !== false;
    case 'comment':
      return settings.enableComments !== false;
    // ... resto
  }
}
```

### Frontend (Flutter)

```dart
// notification_settings_provider.dart
Future<void> toggleLikes(bool enabled) async {
  // 1. Actualiza en Firestore
  await _repository.toggleNotificationType('like', enabled);
  
  // 2. Actualiza estado local
  _settings = _settings!.copyWith(enableLikes: enabled);
  
  // 3. Notifica listeners
  notifyListeners();
}
```

---

## 🧪 Flujo de Testing

### 1. Probar desde Firebase Console

```javascript
// Simular Like
firebase console → Firestore → experiences/{id}/likes
// Agregar documento:
{
  userId: "testUser123",
  timestamp: Timestamp.now()
}
```

**Verificar**:
1. ✅ Cloud Function se ejecuta (ver logs)
2. ✅ Verifica preferencias
3. ✅ Envía notificación si está habilitada
4. ✅ Guarda en `users/{userId}/notifications`
5. ✅ Usuario recibe notificación en dispositivo

### 2. Probar Preferencias

**En la App**:
1. Ve a Settings → Notifications
2. Desactiva "Likes"
3. Pide a alguien que dé like a tu publicación
4. **No deberías recibir notificación**

**Verificar en Backend**:
```bash
firebase functions:log --only onLikeCreated
```

Deberías ver:
```
Notification like disabled for user {userId}
```

---

## 🚀 Checklist de Implementación Completa

### Frontend (Flutter)

- [x] NotificationService implementado
- [x] NotificationListener integrado
- [x] NotificationSettingsScreen creada
- [x] NotificationSettingsProvider configurado
- [x] Rutas agregadas al router
- [x] Provider agregado a main.dart
- [x] Tokens FCM se guardan correctamente
- [x] Preferencias se sincronizan con Firestore

### Backend (Cloud Functions)

- [x] notifications.js creado con 8 triggers
- [x] isNotificationEnabled() implementado
- [x] sendNotificationToUser() implementado
- [x] Limpieza de tokens inválidos
- [x] index.js actualizado con exports
- [ ] Funciones desplegadas a Firebase
- [ ] Logs verificados en Firebase Console

### Testing End-to-End

- [ ] Like → Notificación recibida
- [ ] Comentario → Notificación recibida
- [ ] Seguir → Notificación recibida
- [ ] Preferencias respetadas (desactivar tipo específico)
- [ ] Master switch funciona (desactivar todas)
- [ ] Navegación desde notificación correcta
- [ ] Tokens inválidos se limpian automáticamente

---

## 📝 Próximos Pasos

1. **Desplegar Backend**:
   ```bash
   cd biux-cloud
   .\deploy.ps1
   ```

2. **Probar en Dispositivo Real**:
   - Instala la app
   - Configura preferencias
   - Genera eventos (likes, comentarios)
   - Verifica notificaciones

3. **Monitorear**:
   ```bash
   firebase functions:log
   ```

4. **Optimizar**:
   - Agregar analytics de notificaciones
   - Implementar rate limiting
   - Agregar notificaciones ricas con imágenes

---

**Estado**: ✅ Sistema completo implementado (Frontend + Backend)  
**Pendiente**: Despliegue y testing end-to-end  
**Última actualización**: 22 de octubre de 2025
