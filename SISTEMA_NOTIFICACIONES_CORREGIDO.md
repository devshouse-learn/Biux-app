# 🔔 Sistema de Notificaciones CORREGIDO - Arquitectura

## ✅ Concepto Correcto

**Notificaciones en Firestore**: SIEMPRE se guardan  
**Push Notifications**: Se envían SOLO si el usuario tiene habilitado ese tipo

---

## 🎯 Flujo del Sistema

```
┌──────────────────────────────────────────────────────────────┐
│           APLICACIÓN FLUTTER (Frontend)                       │
│                                                               │
│  Usuario da like → Guarda en Firestore:                      │
│    experiences/{id}/likes/{likeId}                           │
│                                                               │
│  Usuario comenta → Guarda en Firestore:                      │
│    users/{userId}/notifications/{notificationId}             │
│    {                                                          │
│      type: "comment",                                         │
│      title: "Nuevo comentario",                              │
│      body: "Juan: Qué genial!",                              │
│      senderId: "user123",                                     │
│      relatedId: "experience456",                             │
│      timestamp: Timestamp.now(),                             │
│      read: false                                             │
│    }                                                          │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│              CLOUD FUNCTION (Backend)                         │
│  Trigger: onNotificationCreated                              │
│  Path: users/{userId}/notifications/{notificationId}        │
│                                                               │
│  1. ✅ Detecta nueva notificación en Firestore               │
│  2. ✅ Lee el campo "type" de la notificación                │
│  3. ✅ Verifica preferencias del usuario en Firestore:       │
│       users/{userId}/notificationSettings                   │
│  4. ⚡ SI está habilitado → Envía PUSH                       │
│     ⛔ SI está deshabilitado → NO envía PUSH                │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│           DISPOSITIVO (Si push habilitado)                    │
│  - Recibe notificación push                                  │
│  - Muestra en pantalla                                       │
│  - Usuario puede tocar y navegar                             │
└──────────────────────────────────────────────────────────────┘
```

---

## 📦 Estructura en Firestore

### Notificaciones (SIEMPRE se guardan)

```javascript
users/{userId}/notifications/{notificationId} {
  type: "like" | "comment" | "follow" | "ride_invitation" | ...,
  title: "Título de la notificación",
  body: "Mensaje de la notificación",
  senderId: "user123",        // Opcional: Quién generó la notificación
  relatedId: "experience456",  // Opcional: ID relacionado (experiencia, rodada, etc)
  timestamp: Timestamp,
  read: false
}
```

### Preferencias del Usuario

```javascript
users/{userId}/notificationSettings {
  enablePushNotifications: true,   // Master switch
  enableLikes: true,               // Push para likes
  enableComments: true,            // Push para comentarios
  enableFollows: true,             // Push para seguidores
  enableRideInvitations: true,     // Push para invitaciones a rodadas
  enableGroupInvitations: true,    // Push para invitaciones a grupos
  enableStories: true,             // Push para historias
  enableRideReminders: true,       // Push para recordatorios
  enableGroupUpdates: true,        // Push para actualizaciones de grupos
  enableSystemNotifications: true  // Push para sistema
}
```

---

## 🔧 Cloud Function: `onNotificationCreated`

### Trigger

```javascript
exports.onNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    // Se ejecuta AUTOMÁTICAMENTE cuando se crea una notificación
  }
);
```

### Lógica

```javascript
1. Lee la notificación recién creada
2. Obtiene el type (like, comment, follow, etc.)
3. Llama a shouldSendPushNotification(userId, type)
   - Lee users/{userId}/notificationSettings
   - Verifica enablePushNotifications (master)
   - Verifica el campo específico (enableLikes, enableComments, etc.)
4. SI está habilitado:
   - Obtiene fcmTokens del usuario
   - Envía push via FCM
   - Limpia tokens inválidos
5. SI está deshabilitado:
   - Solo registra en logs
   - NO envía push
```

---

## 💡 Ejemplo Completo: Usuario Recibe Comentario

### Paso 1: Flutter guarda el comentario

```dart
// En tu app Flutter
await FirebaseFirestore.instance
  .collection('experiences')
  .doc(experienceId)
  .collection('comments')
  .add({
    userId: currentUserId,
    text: '¡Qué genial!',
    createdAt: Timestamp.now(),
  });
```

### Paso 2: Flutter guarda la notificación

```dart
// Obtener dueño de la experiencia
final experienceDoc = await FirebaseFirestore.instance
  .collection('experiences')
  .doc(experienceId)
  .get();
  
final ownerId = experienceDoc.data()!['userId'];

// Guardar notificación en Firestore
await FirebaseFirestore.instance
  .collection('users')
  .doc(ownerId)
  .collection('notifications')
  .add({
    type: 'comment',
    title: 'Nuevo comentario',
    body: '$currentUserName: ¡Qué genial!',
    senderId: currentUserId,
    relatedId: experienceId,
    timestamp: FieldValue.serverTimestamp(),
    read: false,
  });
```

### Paso 3: Cloud Function detecta la notificación

```javascript
// Backend - Automático
exports.onNotificationCreated = onDocumentCreated(..., async (event) => {
  const notification = event.data.data();
  // notification.type = 'comment'
  // notification.title = 'Nuevo comentario'
  // notification.body = 'Juan: ¡Qué genial!'
  
  const userId = event.params.userId; // ownerId
  
  // Verificar preferencias
  const shouldSend = await shouldSendPushNotification(userId, 'comment');
  // Lee: users/{ownerId}/notificationSettings.enableComments
  
  if (shouldSend) {
    // Enviar push
    await sendPushNotificationIfEnabled(userId, 'comment', notification);
  } else {
    logger.info('Push disabled for comment');
  }
});
```

### Paso 4A: Si PUSH habilitado → Usuario recibe notificación

```
📱 Dispositivo del dueño:
[Nuevo comentario]
Juan: ¡Qué genial!
```

### Paso 4B: Si PUSH deshabilitado → No recibe push

```
⛔ No se envía push
✅ Pero la notificación SÍ está guardada en Firestore
   (aparecerá en el feed de notificaciones de la app)
```

---

## 🎮 Cómo Implementar en Flutter

### Crear Notificación (Siempre)

```dart
Future<void> createNotification({
  required String userId,
  required String type,
  required String title,
  required String body,
  String? senderId,
  String? relatedId,
}) async {
  await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('notifications')
    .add({
      'type': type,
      'title': title,
      'body': body,
      'senderId': senderId,
      'relatedId': relatedId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  
  // ✅ Cloud Function se ejecuta automáticamente
  // ✅ Decide si enviar push según preferencias
}
```

### Ejemplo: Like

```dart
// Usuario A da like a publicación de Usuario B
Future<void> addLike(String experienceId) async {
  // 1. Guardar like
  await FirebaseFirestore.instance
    .collection('experiences')
    .doc(experienceId)
    .collection('likes')
    .doc(currentUserId)
    .set({
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  
  // 2. Obtener dueño de la experiencia
  final experienceDoc = await FirebaseFirestore.instance
    .collection('experiences')
    .doc(experienceId)
    .get();
    
  final ownerId = experienceDoc.data()!['userId'];
  
  // No dar like a uno mismo
  if (ownerId == currentUserId) return;
  
  // 3. Crear notificación
  await createNotification(
    userId: ownerId,
    type: 'like',
    title: 'Nuevo like',
    body: 'A $currentUserName le gustó tu publicación',
    senderId: currentUserId,
    relatedId: experienceId,
  );
  
  // ✅ Listo! El backend se encarga del resto
}
```

---

## 🚀 Despliegue

```powershell
cd biux-cloud
firebase deploy --only functions:onNotificationCreated
```

**Solo hay 1 función ahora**: `onNotificationCreated`

---

## ✅ Ventajas de este Enfoque

1. **Simplicidad**: Una sola Cloud Function  
2. **Escalabilidad**: No importa cuántos tipos de notificaciones agregues  
3. **Consistencia**: Todas las notificaciones se guardan igual  
4. **Control**: El usuario decide qué push recibe  
5. **Auditoría**: Todas las notificaciones están en Firestore  
6. **Eficiencia**: Solo se envía push cuando es necesario

---

## 📊 Comparación: Antes vs Ahora

### ❌ Antes (Incorrecto)

```
Trigger en cada colección:
- onLikeCreated → experiences/{id}/likes/{id}
- onCommentCreated → experiences/{id}/comments/{id}
- onFollowCreated → users/{id}/followers/{id}
...

Problemas:
- 8 Cloud Functions diferentes
- Lógica duplicada
- Difícil de mantener
- No consistente
```

### ✅ Ahora (Correcto)

```
Trigger único:
- onNotificationCreated → users/{userId}/notifications/{id}

Ventajas:
- 1 Cloud Function
- Lógica centralizada
- Fácil de mantener
- Consistente
```

---

## 🧪 Testing

### Test 1: Notificación con Push Habilitado

```javascript
// 1. Usuario A tiene enableComments = true
// 2. Usuario B comenta en publicación de Usuario A
// 3. Flutter guarda notificación en Firestore
// 4. Cloud Function detecta y envía push
// 5. Usuario A recibe push: "Juan: Qué genial!"
```

### Test 2: Notificación con Push Deshabilitado

```javascript
// 1. Usuario A tiene enableComments = false
// 2. Usuario B comenta en publicación de Usuario A
// 3. Flutter guarda notificación en Firestore
// 4. Cloud Function detecta pero NO envía push
// 5. Usuario A NO recibe push
// 6. Pero la notificación SÍ está en Firestore
```

### Test 3: Master Switch Deshabilitado

```javascript
// 1. Usuario A tiene enablePushNotifications = false
// 2. Cualquier tipo de notificación se crea
// 3. Cloud Function detecta pero NO envía push
// 4. Usuario A NO recibe ningún push
// 5. Todas las notificaciones están en Firestore
```

---

## 📝 Resumen

**Notificaciones**: SIEMPRE en Firestore → `users/{userId}/notifications/{id}`  
**Push**: SOLO si `notificationSettings.enable{Type}` === `true`  
**Cloud Function**: `onNotificationCreated` → Trigger único  
**Flutter**: Guarda notificación → Backend decide push automáticamente

**Estado**: ✅ Sistema corregido y listo para desplegar  
**Última actualización**: 22 de octubre de 2025
